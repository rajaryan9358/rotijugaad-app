import 'package:flutter/material.dart';
import 'package:rotijugaad/theme/context_ext.dart';

import '../../theme/app_icons.dart';
import '../widgets/xicon.dart';

class PrimaryDialog extends StatefulWidget {
  final String? title;
  final String message;
  final String buttonLabel;
  final AppIcon icon;
  final Color? iconColor;
  final bool showIcon;

  const PrimaryDialog(
    this.message, {
    super.key,
    this.title,
    this.buttonLabel = 'Done',
    this.icon = AppIcon.success,
    this.iconColor,
    this.showIcon = true,
  });

  @override
  State<StatefulWidget> createState() => _PrimaryDialogState();
}

class _PrimaryDialogState extends State<PrimaryDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colors.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.showIcon) ...[
              XIcon(
                widget.icon,
                size: 48,
                color: widget.iconColor ?? context.xcolors.success,
              ),
              SizedBox(height: context.spacing.sm),
            ],
            if ((widget.title ?? '').trim().isNotEmpty) ...[
              Text(
                widget.title!.trim(),
                style: context.text.titleMedium!.copyWith(
                  color: context.colors.onPrimaryContainer,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: context.spacing.xs),
              Text(
                widget.message,
                style: context.text.bodyMedium!.copyWith(
                  color: context.colors.onPrimaryContainer,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ] else
              Text(
                widget.message,
                style: context.text.bodyMedium!.copyWith(
                  color: context.colors.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            SizedBox(height: context.spacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(widget.buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
