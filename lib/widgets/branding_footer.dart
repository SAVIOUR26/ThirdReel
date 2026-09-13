import 'package:flutter/material.dart';

import '../core/theme/colors.dart';

/// "Designed by Saviour Najuna · Powered by Thirdsan" — SPEC.md section 4.
class BrandingFooter extends StatelessWidget {
  const BrandingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Designed by Saviour Najuna · Powered by Thirdsan',
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: AppColors.mutedDark,
      ),
    );
  }
}
