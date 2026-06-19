import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class NotRegisteredDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onSignup;
  final VoidCallback? onCancel;

  const NotRegisteredDialog({
    super.key,
    this.title = 'Not Registered!',
    required this.message,
    required this.onSignup,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedTitle = title == 'Not Registered!'
        ? 'auth.not_registered.title'.tr()
        : title;

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
              resolvedTitle,
              style: context.text.bodyMedium!.copyWith(
                color: context.colors.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
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
                onPressed: onSignup,
                child: Text('common.sign_up'.tr()),
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
                onPressed: onCancel ?? () => Navigator.of(context).pop(),
                child: Text(
                  'common.cancel'.tr(),
                  style: context.text.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
