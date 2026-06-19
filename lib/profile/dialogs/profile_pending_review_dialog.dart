import 'package:flutter/material.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class ProfilePendingReviewDialog extends StatelessWidget {
  final String title;
  final String message;

  const ProfilePendingReviewDialog({
    super.key,
    this.title = 'Profile submitted for review',
    this.message = 'Your profile has been submitted and is waiting for review.',
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
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Waiting for review'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
