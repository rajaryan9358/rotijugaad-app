import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/profile/dialogs/profile_incomplete_dialog.dart';
import 'package:rotijugaad/profile/dialogs/profile_pending_review_dialog.dart';
import 'package:rotijugaad/profile/dialogs/profile_rejected_resubmit_dialog.dart';
import 'package:rotijugaad/profile/screens/edit_employer_profile_screen.dart';
import 'package:rotijugaad/profile/utils/profile_status_helper.dart';
import 'package:rotijugaad/profile/utils/session_refresh_helper.dart';
import 'package:rotijugaad/subscriptions/screens/subscription_screen.dart';
import 'package:rotijugaad/subscriptions/services/subscriptions_service.dart';
import 'package:rotijugaad/utils/result.dart';
import 'package:rotijugaad/utils/shared_pref.dart';

class EmployerProfileActionGuard {
  static bool get isEmployerUser =>
      SharedPrefUtils.readStr(SharedPrefUtils.USER_TYPE).trim().toLowerCase() ==
      'employer';

  static Map<String, dynamic>? get _authUserJson =>
      SharedPrefUtils.readJson(SharedPrefUtils.AUTH_USER_JSON);

  static Map<String, dynamic>? get _authProfileJson =>
      SharedPrefUtils.readJson(SharedPrefUtils.AUTH_PROFILE_JSON);

  static String get verificationStatus =>
      (_authProfileJson?['verification_status'] ??
              _authProfileJson?['verificationStatus'] ??
              '')
          .toString()
          .trim()
          .toLowerCase();

  static String get _normalizedVerificationStatus =>
      verificationStatus == 'init' ? '' : verificationStatus;

  static bool get isProfileCompleted {
    if (SharedPrefUtils.readBool(SharedPrefUtils.AUTH_PROFILE_COMPLETED)) {
      return true;
    }

    return ProfileStatusHelper.isProfileCompleted(
      user: _authUserJson,
      profile: _authProfileJson,
    );
  }

  static bool get isIncomplete =>
      isEmployerUser &&
      (!isProfileCompleted || _normalizedVerificationStatus.isEmpty);

  static bool get isPending =>
      isEmployerUser &&
      isProfileCompleted &&
      _normalizedVerificationStatus == 'pending';

  static bool get isRejected =>
      isEmployerUser &&
      isProfileCompleted &&
      _normalizedVerificationStatus == 'rejected';

  static Future<void> _openCompleteProfile(BuildContext context) async {
    final outcome = await Navigator.push<Object?>(
      context,
      MaterialPageRoute(builder: (_) => const EditEmployerProfileScreen()),
    );

    await handleEditEmployerProfileOutcome(context, outcome);
    await SessionRefreshHelper.refreshCurrentSession(context);
  }

  static Future<void> showIncompleteDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => ProfileIncompleteDialog(
        onCompleteProfile: () {
          Navigator.of(dialogContext).pop();
          _openCompleteProfile(context);
        },
      ),
    );
  }

  static Future<void> showPendingDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const ProfilePendingReviewDialog(),
    );
  }

  static Future<void> _openResubmitProfile(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const EditEmployerProfileScreen(goToVerifyIdentityOnSuccess: false),
      ),
    );
  }

  static Future<void> showRejectedDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => ProfileRejectedResubmitDialog(
        onResubmit: () {
          Navigator.of(dialogContext).pop();
          _openResubmitProfile(context);
        },
      ),
    );
  }

  static Future<bool> ensureAllowed(
    BuildContext context, {
    bool blockPending = true,
  }) async {
    if (!isEmployerUser) return true;

    if (isIncomplete) {
      await showIncompleteDialog(context);
      return false;
    }

    if (blockPending && isPending) {
      await showPendingDialog(context);
      return false;
    }

    if (isRejected) {
      await showRejectedDialog(context);
      return false;
    }

    return true;
  }

  static Future<void> openSubscription(BuildContext context) async {
    if (!await ensureAllowed(context)) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
    );
  }

  static Future<void> showNoAdCreditDialog(
    BuildContext context,
    String message,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: dialogContext.colors.onPrimary,
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
                message,
                style: dialogContext.text.bodyMedium!.copyWith(
                  color: dialogContext.colors.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: dialogContext.spacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final navigator = Navigator.of(dialogContext);
                    navigator.pop();
                    openSubscription(navigator.context);
                  },
                  child: Text('common.buy_subscription'.tr()),
                ),
              ),
              SizedBox(height: dialogContext.spacing.xs),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dialogContext.colors.secondaryContainer,
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'common.cancel'.tr(),
                    style: dialogContext.text.bodyMedium,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<bool> ensureHasAdCredit(BuildContext context) async {
    final employerId = SharedPrefUtils.readInt('auth_employer_id');
    if (employerId <= 0) return false;

    final result = await SubscriptionsService().getEmployerSubscriptions(
      employerId,
    );

    if (!context.mounted) return false;

    switch (result) {
      case Success(value: final data):
        Map<String, dynamic>? toMap(dynamic v) {
          if (v is Map<String, dynamic>) return v;
          if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
          return null;
        }

        int toInt(dynamic v) {
          if (v == null) return 0;
          if (v is int) return v;
          return int.tryParse(v.toString()) ?? 0;
        }

        final current = toMap(
          data['current_subscription'] ?? data['currentSubscription'],
        );
        final status =
            (current?['status'] ?? '').toString().trim().toLowerCase();
        final credits = toMap(current?['credits'] ?? data['credits']);
        final ads = toMap(
          credits?['ads'] ??
              credits?['ad'] ??
              credits?['ad_credits'] ??
              credits?['ad_credit'],
        );
        final available = toInt(
          ads?['available'] ??
              ads?['remaining'] ??
              ads?['balance'] ??
              credits?['ad_credit'] ??
              credits?['ad_credits'],
        );

        if (status != 'active') {
          await showNoAdCreditDialog(
            context,
            'subscriptions.dialog.no_subscription'.tr(),
          );
          return false;
        }
        if (available < 1) {
          await showNoAdCreditDialog(
            context,
            'subscriptions.dialog.no_job_post_credits'.tr(),
          );
          return false;
        }
        return true;

      case Failure(exception: final e):
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.message)));
        return false;
    }
  }
}
