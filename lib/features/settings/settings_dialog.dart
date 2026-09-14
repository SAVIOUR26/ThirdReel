import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../core/services/settings_service.dart';
import '../../core/theme/colors.dart';
import '../../widgets/branding_footer.dart';

/// The merge screen's gear icon opens this. Holds the one real preference
/// the app has (export quality) plus app/version info.
Future<void> showSettingsDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (context) => const SettingsDialog(),
  );
}

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  final _settingsService = SettingsService();

  VideoQuality? _quality;
  String? _version;

  @override
  void initState() {
    super.initState();
    _settingsService.getVideoQuality().then((q) {
      if (mounted) setState(() => _quality = q);
    });
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _version = info.version);
    });
  }

  Future<void> _selectQuality(VideoQuality quality) async {
    setState(() => _quality = quality);
    await _settingsService.setVideoQuality(quality);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.navyLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: AppColors.navyBorder),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.muted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Export quality',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              for (final quality in VideoQuality.values)
                _QualityOption(
                  quality: quality,
                  selected: _quality == quality,
                  onTap: () => _selectQuality(quality),
                ),
              const SizedBox(height: 20),
              const Divider(height: 1, color: AppColors.navyBorder),
              const SizedBox(height: 16),
              Text(
                _version == null ? 'ThirdReel' : 'ThirdReel v$_version',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              const BrandingFooter(),
            ],
          ),
        ),
      ),
    );
  }
}

class _QualityOption extends StatelessWidget {
  const _QualityOption({
    required this.quality,
    required this.selected,
    required this.onTap,
  });

  final VideoQuality quality;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.gold : AppColors.muted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(quality.label, style: Theme.of(context).textTheme.bodyLarge),
                Text(
                  quality.description,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
