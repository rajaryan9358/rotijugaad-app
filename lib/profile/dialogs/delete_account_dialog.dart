import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class DeleteAccountDialog extends StatelessWidget {
  const DeleteAccountDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: context.colors.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'profile.delete_account.title'.tr(),
              style: context.text.bodyMedium!.copyWith(
                color: context.colors.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: context.spacing.sm),
            Text(
              'profile.delete_account.message'.tr(),
              textAlign: TextAlign.center,
              style: context.text.bodySmall!.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: context.spacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.xcolors.failure,
                ),
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: Text('profile.delete_account.button'.tr()),
              ),
            ),
            SizedBox(height: context.spacing.xs),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.secondaryContainer,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
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
