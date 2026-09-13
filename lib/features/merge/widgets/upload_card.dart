import 'package:flutter/material.dart';

import '../../../core/theme/colors.dart';

/// One of the two upload cards (Audio track / Cover image) — SPEC.md
/// section 4. Shows the filename once picked, with a check icon.
class UploadCard extends StatelessWidget {
  const UploadCard({
    super.key,
    required this.icon,
    required this.label,
    required this.fileName,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String? fileName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isLoaded = fileName != null;

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                icon,
                color: isLoaded ? AppColors.gold : AppColors.muted,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 2),
                    Text(
                      fileName ?? 'Tap to choose',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              if (isLoaded)
                const Icon(Icons.check_circle, color: AppColors.success),
            ],
          ),
        ),
      ),
    );
  }
}
