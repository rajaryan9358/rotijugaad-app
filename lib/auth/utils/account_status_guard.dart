import 'package:flutter/material.dart';
import 'package:rotijugaad/auth/screens/auth_screen.dart';
import 'package:rotijugaad/auth/utils/logout_manager.dart';
import 'package:rotijugaad/jobs/screens/help_support_screen.dart';
import 'package:rotijugaad/navigation/app_page_route.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/utils/shared_pref.dart';

class AccountStatusGuard {
  static bool _isFalse(dynamic v) {
    if (v is bool) return v == false;
    return v?.toString().toLowerCase() == 'false';
  }

  /// Returns true if the account was inactive and we logged out + navigated.
  static Future<bool> handleIfInactive(BuildContext context) async {
    final userJson = SharedPrefUtils.readJson(SharedPrefUtils.AUTH_USER_JSON);
    final isActive = userJson?['is_active'];

    if (!_isFalse(isActive)) return false;
    if (!context.mounted) return true;

    final goLogin = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: context.colors.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Account disabled',
                  style: context.text.titleMedium?.copyWith(
                    color: context.colors.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: context.spacing.sm),
                Text(
                  'Your account is disabled. Please contact support.',
                  textAlign: TextAlign.center,
                  style: context.text.bodyMedium?.copyWith(
                    color: context.colors.onPrimaryContainer,
                  ),
                ),
                SizedBox(height: context.spacing.md),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop(true);
                    },
                    child: const Text('Go to Login'),
                  ),
                ),
                SizedBox(height: context.spacing.xs),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).push(
                        MaterialPageRoute(
                          builder: (_) => HelpSupportScreen(),
                        ),
                      );
                    },
                    child: const Text('Contact Support'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (goLogin != true) return true;

    await LogoutManager.clearLocalSession(context);
    if (!context.mounted) return true;

    Navigator.of(context).pushAndRemoveUntil(
      AppPageRoute.slideFade(page: AuthScreen()),
      (_) => false,
    );

    return true;
  }
}
