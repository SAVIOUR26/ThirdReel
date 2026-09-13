import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';

/// Full-width primary button, flat gold fill, no gradient — SPEC.md
/// section 4. Doubles as a progress indicator while merging.
class MergeButton extends StatelessWidget {
  const MergeButton({
    super.key,
    required this.enabled,
    required this.isMerging,
    required this.progress,
    required this.onPressed,
  });

  final bool enabled;
  final bool isMerging;
  final double progress;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled && !isMerging ? onPressed : null,
        child: isMerging
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      value: progress > 0 ? progress : null,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('Merging… ${(progress * 100).round()}%'),
                ],
              )
            : const Text('Merge and export'),
      ),
    );
  }
}
