import 'package:flutter/material.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class MessageDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonLabel;
  final String? secondaryButtonLabel;
  final VoidCallback? onSecondaryButtonPressed;

  const MessageDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonLabel = 'Done',
    this.secondaryButtonLabel,
    this.onSecondaryButtonPressed,
  });

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
            Text(
              title,
              style: context.text.bodyMedium!.copyWith(
                color: context.colors.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacing.sm),
            Text(
              message,
              style: context.text.bodySmall!.copyWith(
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(buttonLabel),
              ),
            ),
            if (secondaryButtonLabel != null) ...[
              SizedBox(height: context.spacing.xs),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: onSecondaryButtonPressed,
                  child: Text(secondaryButtonLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
