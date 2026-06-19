import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class ProfileIncompleteDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onCompleteProfile;
  final VoidCallback? onLater;
  final String laterButtonText;

  const ProfileIncompleteDialog({
    super.key,
    this.title = 'Your profile is not completed',
    this.message = 'Complete your profile to continue',
    required this.onCompleteProfile,
    this.onLater,
    this.laterButtonText = 'Do it later',
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
                onPressed: onCompleteProfile,
                child: const Text('Complete Profile'),
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
                onPressed: onLater ?? () => Navigator.of(context).pop(),
                child: Text(laterButtonText, style: context.text.bodyMedium),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
