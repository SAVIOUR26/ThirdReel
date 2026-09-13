import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';

/// Cover image + play icon + scrub bar reflecting audio length —
/// SPEC.md section 1 & 4. Shared between the mobile and desktop layouts;
/// the desktop pane just gives it more room.
class PreviewPanel extends StatelessWidget {
  const PreviewPanel({
    super.key,
    required this.imagePath,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.onPlayPause,
    required this.onSeek,
  });

  final String? imagePath;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final VoidCallback onPlayPause;
  final ValueChanged<Duration> onSeek;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navyLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.navyBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                if (imagePath != null)
                  Image.file(File(imagePath!), fit: BoxFit.cover)
                else
                  const Icon(Icons.image_outlined, size: 56, color: AppColors.muted),
                if (imagePath != null)
                  _PlayButton(isPlaying: isPlaying, onTap: onPlayPause),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.gold,
                    inactiveTrackColor: AppColors.navyBorder,
                    thumbColor: AppColors.gold,
                    overlayColor: AppColors.gold.withValues(alpha: 0.2),
                    trackHeight: 3,
                  ),
                  child: Slider(
                    min: 0,
                    max: duration.inMilliseconds > 0
                        ? duration.inMilliseconds.toDouble()
                        : 1,
                    value: position.inMilliseconds
                        .clamp(0, duration.inMilliseconds)
                        .toDouble(),
                    onChanged: duration.inMilliseconds > 0
                        ? (value) =>
                            onSeek(Duration(milliseconds: value.round()))
                        : null,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_format(position), style: Theme.of(context).textTheme.bodySmall),
                    Text(_format(duration), style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _format(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class _PlayButton extends StatelessWidget {
  const _PlayButton({required this.isPlaying, required this.onTap});

  final bool isPlaying;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.navy.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Icon(
            isPlaying ? Icons.pause : Icons.play_arrow,
            color: AppColors.cream,
            size: 40,
          ),
        ),
      ),
    );
  }
}
