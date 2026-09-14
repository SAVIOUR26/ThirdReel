import 'dart:async';

import 'package:ffmpeg_kit_flutter_new_min/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_min/return_code.dart';

enum MergeStatus { success, cancelled, failed }

class MergeResult {
  const MergeResult({
    required this.status,
    required this.outputPath,
    this.errorMessage,
  });

  final MergeStatus status;
  final String outputPath;
  final String? errorMessage;
}

/// Wraps `ffmpeg_kit_flutter_new_min` — the LGPL-only build of
/// ffmpeg_kit_flutter_new, see SPEC.md section 3.
///
/// The LGPL packages exclude GPL-licensed codecs (x264/x265/xvidcore/
/// vid.stab), so the video stream is encoded with FFmpeg's native `mpeg4`
/// encoder instead of the `libx264` used in SPEC.md's reference command.
/// Everything else — scale/pad/format filter chain, aac audio, `-shortest`,
/// faststart — matches the spec exactly.
class MergeService {
  /// Runs the merge and resolves once FFmpeg finishes.
  ///
  /// [audioDuration] is used only to turn FFmpeg's statistics callback into
  /// a 0..1 [onProgress] fraction; pass null to skip progress reporting.
  Future<MergeResult> merge({
    required String imagePath,
    required String audioPath,
    required String outputPath,
    Duration? audioDuration,
    int qValue = 3,
    void Function(double fraction)? onProgress,
  }) {
    final completer = Completer<MergeResult>();

    final arguments = <String>[
      '-y',
      '-loop', '1',
      '-framerate', '10',
      '-i', imagePath,
      '-i', audioPath,
      '-vf',
      'scale=1280:720:force_original_aspect_ratio=decrease,'
          'pad=1280:720:(ow-iw)/2:(oh-ih)/2,format=yuv420p',
      '-c:v', 'mpeg4',
      '-q:v', '$qValue',
      '-c:a', 'aac',
      '-b:a', '192k',
      '-shortest',
      '-movflags', '+faststart',
      outputPath,
    ];

    FFmpegKit.executeWithArgumentsAsync(
      arguments,
      (session) async {
        if (completer.isCompleted) return;
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          completer.complete(
            MergeResult(status: MergeStatus.success, outputPath: outputPath),
          );
        } else if (ReturnCode.isCancel(returnCode)) {
          completer.complete(
            MergeResult(status: MergeStatus.cancelled, outputPath: outputPath),
          );
        } else {
          final failLog = await session.getFailStackTrace();
          completer.complete(
            MergeResult(
              status: MergeStatus.failed,
              outputPath: outputPath,
              errorMessage: failLog ?? 'FFmpeg exited with code $returnCode',
            ),
          );
        }
      },
      null,
      audioDuration == null || onProgress == null
          ? null
          : (statistics) {
              final totalMs = audioDuration.inMilliseconds;
              if (totalMs <= 0) return;
              final fraction = (statistics.getTime() / totalMs).clamp(0.0, 1.0);
              onProgress(fraction);
            },
    );

    return completer.future;
  }

  Future<void> cancel() => FFmpegKit.cancel();
}
