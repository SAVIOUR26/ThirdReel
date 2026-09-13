import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

/// Picks single-column (mobile) vs two-pane (desktop) using
/// [LayoutBuilder] on window width — SPEC.md section 4. Both layouts
/// share the same set of widgets, just arranged differently.
class AdaptiveLayout extends StatelessWidget {
  const AdaptiveLayout({
    super.key,
    required this.audioCard,
    required this.imageCard,
    required this.previewPanel,
    required this.mergeButton,
    this.onFilesDropped,
  });

  static const breakpoint = 720.0;

  final Widget audioCard;
  final Widget imageCard;
  final Widget previewPanel;
  final Widget mergeButton;

  /// Desktop only: absolute paths of files dropped onto the left rail.
  final ValueChanged<List<String>>? onFilesDropped;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= breakpoint) {
          return _DesktopLayout(
            audioCard: audioCard,
            imageCard: imageCard,
            previewPanel: previewPanel,
            mergeButton: mergeButton,
            onFilesDropped: onFilesDropped,
          );
        }
        return _MobileLayout(
          audioCard: audioCard,
          imageCard: imageCard,
          previewPanel: previewPanel,
          mergeButton: mergeButton,
        );
      },
    );
  }
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({
    required this.audioCard,
    required this.imageCard,
    required this.previewPanel,
    required this.mergeButton,
  });

  final Widget audioCard;
  final Widget imageCard;
  final Widget previewPanel;
  final Widget mergeButton;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          audioCard,
          const SizedBox(height: 12),
          imageCard,
          const SizedBox(height: 20),
          SizedBox(height: 240, child: previewPanel),
          const SizedBox(height: 24),
          mergeButton,
        ],
      ),
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({
    required this.audioCard,
    required this.imageCard,
    required this.previewPanel,
    required this.mergeButton,
    this.onFilesDropped,
  });

  final Widget audioCard;
  final Widget imageCard;
  final Widget previewPanel;
  final Widget mergeButton;
  final ValueChanged<List<String>>? onFilesDropped;

  @override
  Widget build(BuildContext context) {
    Widget rail = Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          audioCard,
          const SizedBox(height: 12),
          imageCard,
          const Spacer(),
          mergeButton,
        ],
      ),
    );

    if (onFilesDropped != null) {
      rail = DropTarget(
        onDragDone: (details) {
          onFilesDropped!(details.files.map((f) => f.path).toList());
        },
        child: rail,
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(width: 260, child: rail),
        const VerticalDivider(width: 1, color: AppColors.navyBorder),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: previewPanel,
          ),
        ),
      ],
    );
  }
}
