import 'dart:async';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:share_plus/share_plus.dart';

import '../../core/services/file_service.dart';
import '../../core/services/merge_service.dart';
import '../../core/services/settings_service.dart';
import '../../widgets/branding_footer.dart';
import '../layout/adaptive_layout.dart';
import '../settings/settings_dialog.dart';
import 'widgets/merge_button.dart';
import 'widgets/preview_panel.dart';
import 'widgets/upload_card.dart';

/// Adapts to mobile / desktop layout via [AdaptiveLayout] — SPEC.md
/// section 4. Owns all merge-flow state; the layout only decides how the
/// shared widgets are arranged.
class MergeScreen extends StatefulWidget {
  const MergeScreen({super.key});

  @override
  State<MergeScreen> createState() => _MergeScreenState();
}

class _MergeScreenState extends State<MergeScreen> {
  final _fileService = FileService();
  final _mergeService = MergeService();
  final _settingsService = SettingsService();
  final _audioPlayer = AudioPlayer();

  PickedFile? _audioFile;
  PickedFile? _imageFile;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;
  bool _isMerging = false;
  double _progress = 0;

  StreamSubscription<Duration>? _durationSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<PlayerState>? _stateSub;

  @override
  void initState() {
    super.initState();
    _durationSub = _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _positionSub = _audioPlayer.onPositionChanged.listen((pos) {
      if (mounted) setState(() => _position = pos);
    });
    _stateSub = _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });
  }

  @override
  void dispose() {
    _durationSub?.cancel();
    _positionSub?.cancel();
    _stateSub?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  bool get _isDesktop => Platform.isWindows;

  Future<void> _pickAudio() async {
    final file = await _fileService.pickAudio();
    if (file == null) return;
    await _loadAudio(file);
  }

  Future<void> _pickImage() async {
    final file = await _fileService.pickImage();
    if (file == null) return;
    setState(() => _imageFile = file);
  }

  Future<void> _loadAudio(PickedFile file) async {
    setState(() {
      _audioFile = file;
      _duration = Duration.zero;
      _position = Duration.zero;
    });
    await _audioPlayer.stop();
    await _audioPlayer.setSourceDeviceFile(file.path);
  }

  void _handleDroppedFiles(List<String> paths) {
    for (final path in paths) {
      final ext = p.extension(path).replaceFirst('.', '').toLowerCase();
      if (FileService.audioExtensions.contains(ext)) {
        _loadAudio(PickedFile(name: p.basename(path), path: path));
      } else if (FileService.imageExtensions.contains(ext)) {
        setState(() {
          _imageFile = PickedFile(name: p.basename(path), path: path);
        });
      }
    }
  }

  void _togglePlayback() {
    if (_audioFile == null) return;
    if (_isPlaying) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.resume();
    }
  }

  Future<void> _merge() async {
    final audioPath = _audioFile?.path;
    final imagePath = _imageFile?.path;
    if (audioPath == null || imagePath == null || _isMerging) return;

    setState(() {
      _isMerging = true;
      _progress = 0;
    });

    final tempPath = await _fileService.tempOutputPath();
    final quality = await _settingsService.getVideoQuality();
    final result = await _mergeService.merge(
      imagePath: imagePath,
      audioPath: audioPath,
      outputPath: tempPath,
      audioDuration: _duration,
      qValue: quality.qValue,
      onProgress: (fraction) {
        if (mounted) setState(() => _progress = fraction);
      },
    );

    if (!mounted) return;
    setState(() => _isMerging = false);

    if (result.status != MergeStatus.success) {
      if (result.status == MergeStatus.failed) {
        _showMessage(result.errorMessage ?? 'Merge failed.');
      }
      return;
    }

    final savedPath = await _fileService.saveOutput(result.outputPath);
    if (!mounted || savedPath == null) return;

    _showMessage(
      _isDesktop ? 'Saved to $savedPath' : 'Saved to your gallery',
      action: SnackBarAction(
        label: 'Share',
        onPressed: () => SharePlus.instance.share(
          ShareParams(files: [XFile(savedPath)]),
        ),
      ),
    );
  }

  void _showMessage(String message, {SnackBarAction? action}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), action: action),
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Scaffold(
      appBar: AppBar(
        title: const Text('ThirdReel'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => showSettingsDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: AdaptiveLayout(
              audioCard: UploadCard(
                icon: Icons.audiotrack,
                label: 'Audio track',
                fileName: _audioFile?.name,
                onTap: _pickAudio,
              ),
              imageCard: UploadCard(
                icon: Icons.image_outlined,
                label: 'Cover image',
                fileName: _imageFile?.name,
                onTap: _pickImage,
              ),
              previewPanel: PreviewPanel(
                imagePath: _imageFile?.path,
                isPlaying: _isPlaying,
                position: _position,
                duration: _duration,
                onPlayPause: _togglePlayback,
                onSeek: _audioPlayer.seek,
              ),
              mergeButton: MergeButton(
                enabled: _audioFile != null && _imageFile != null,
                isMerging: _isMerging,
                progress: _progress,
                onPressed: _merge,
              ),
              onFilesDropped: _isDesktop ? _handleDroppedFiles : null,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: BrandingFooter(),
          ),
        ],
      ),
    );

    if (!_isDesktop) return content;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.keyO, control: true):
            _pickAudio,
        const SingleActivator(LogicalKeyboardKey.keyO, meta: true):
            _pickAudio,
        const SingleActivator(LogicalKeyboardKey.keyI, control: true):
            _pickImage,
        const SingleActivator(LogicalKeyboardKey.keyI, meta: true):
            _pickImage,
        const SingleActivator(LogicalKeyboardKey.enter, control: true):
            _merge,
        const SingleActivator(LogicalKeyboardKey.enter, meta: true): _merge,
      },
      child: Focus(autofocus: true, child: content),
    );
  }
}
