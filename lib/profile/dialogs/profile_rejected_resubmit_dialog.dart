import 'package:flutter/material.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class ProfileRejectedResubmitDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onResubmit;

  const ProfileRejectedResubmitDialog({
    super.key,
    required this.onResubmit,
    this.title = 'Profile verification is rejected',
    this.message =
        'Your profile verification was rejected. Please resubmit your profile to continue.',
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
              textAlign: TextAlign.center,
              style: context.text.bodySmall!.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: context.spacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onResubmit,
                child: const Text('Resubmit'),
              ),
            ),
            SizedBox(height: context.spacing.xs),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.secondaryContainer,
                  elevation: 0,
                ),
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel', style: context.text.bodyMedium),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
