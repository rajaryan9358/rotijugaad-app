import 'package:flutter/material.dart';
import 'package:rotijugaad/profile/utils/employer_profile_action_guard.dart';
import 'package:rotijugaad/theme/context_ext.dart';

class NoSubscriptionDialog extends StatelessWidget {
  const NoSubscriptionDialog({super.key});

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
              "You don't have any subscription!",
              style: context.text.bodyMedium!.copyWith(
                color: context.colors.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacing.sm),
            Text(
              'Buy a subscription to get access to contact details and send interests',
              textAlign: TextAlign.center,
              style: context.text.bodySmall!.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: context.spacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final navigator = Navigator.of(context);
                  navigator.pop();
                  EmployerProfileActionGuard.openSubscription(
                    navigator.context,
                  );
                },
                child: const Text('Buy Subscription'),
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
