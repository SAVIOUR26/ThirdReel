import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:gal/gal.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// A picked source file, decoupled from `file_picker`'s own `PlatformFile`
/// so files dropped via `desktop_drop` can be represented the same way.
class PickedFile {
  const PickedFile({required this.name, required this.path});

  final String name;
  final String path;
}

/// Picks source files and saves the merged output — SPEC.md section 3.
///
/// Picking is the same on both platforms (`file_picker`). Saving the
/// finished MP4 is platform-specific: Android gets it into the device
/// gallery (`gal`), Windows lets the user choose a destination folder.
class FileService {
  static const audioExtensions = ['mp3', 'wav', 'm4a'];
  static const imageExtensions = ['png', 'jpg', 'jpeg'];

  Future<PickedFile?> pickAudio() => _pick(audioExtensions, 'Choose an audio track');

  Future<PickedFile?> pickImage() => _pick(imageExtensions, 'Choose a cover image');

  Future<PickedFile?> _pick(List<String> extensions, String dialogTitle) async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: extensions,
      dialogTitle: dialogTitle,
    );
    if (file?.path == null) return null;
    return PickedFile(name: file!.name, path: file.path!);
  }

  /// A scratch path FFmpeg can write the merged file to before it's saved
  /// to its final destination.
  Future<String> tempOutputPath() async {
    final dir = await getTemporaryDirectory();
    final name = 'thirdreel_${DateTime.now().millisecondsSinceEpoch}.mp4';
    return p.join(dir.path, name);
  }

  /// Moves the file at [tempOutputPath] to its final home and returns that
  /// path, or null if the user cancelled (Windows only — Android always
  /// saves to the gallery).
  Future<String?> saveOutput(String tempOutputPath) async {
    if (Platform.isAndroid) {
      await Gal.putVideo(tempOutputPath, album: 'ThirdReel');
      return tempOutputPath;
    }

    final folder = await FilePicker.getDirectoryPath(
      dialogTitle: 'Choose where to save the video',
    );
    if (folder == null) return null;

    final destination = p.join(folder, p.basename(tempOutputPath));
    await File(tempOutputPath).copy(destination);
    return destination;
  }
}
