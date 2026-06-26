import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/auth/utils/logout_manager.dart';
import 'package:rotijugaad/common/dialogs/primary_dialog.dart';
import 'package:rotijugaad/common/widgets/xicon.dart';
import 'package:rotijugaad/candidates/screens/shortlisted_candidates_screen.dart';
import 'package:rotijugaad/editprofile/screens/edit_profile.dart';
import 'package:rotijugaad/editprofile/screens/documents_screen.dart';
import 'package:rotijugaad/experiences/screens/update_experience_screen.dart';
import 'package:rotijugaad/history/screens/employer_history_screen.dart';
import 'package:rotijugaad/history/screens/history_screen.dart';
import 'package:rotijugaad/preferences/screens/update_preference_screen.dart';
import 'package:rotijugaad/profile/dialogs/delete_account_dialog.dart';
import 'package:rotijugaad/profile/dialogs/profile_incomplete_dialog.dart';
import 'package:rotijugaad/profile/dialogs/logout_dialog.dart';
import 'package:rotijugaad/profile/dialogs/profile_pending_review_dialog.dart';
import 'package:rotijugaad/profile/dialogs/update_language_dialog.dart';
import 'package:rotijugaad/profile/screens/edit_employer_profile_screen.dart';
import 'package:rotijugaad/jobs/screens/help_support_screen.dart';
import 'package:rotijugaad/profile/screens/hired_jobs_screen.dart';
import 'package:rotijugaad/profile/screens/privacy_policy_screen.dart';
import 'package:rotijugaad/profile/screens/refund_policy_screen.dart';
import 'package:rotijugaad/profile/screens/terms_condition_screen.dart';
import 'package:rotijugaad/profile/sheets/change_mobile_sheet.dart';
import 'package:rotijugaad/profile/sheets/refer_sheet.dart';
import 'package:rotijugaad/profile/sheets/kyc_verified_sheet.dart';
import 'package:rotijugaad/profile/sheets/verified_profile_sheet.dart';
import 'package:rotijugaad/profile/utils/session_refresh_helper.dart';
import 'package:rotijugaad/profile/widgets/profile_option_item.dart';
import 'package:rotijugaad/profile/widgets/verification_pending.dart';
import 'package:rotijugaad/profile/widgets/verification_required.dart';
import 'package:rotijugaad/profile/utils/employer_profile_action_guard.dart';
import 'package:rotijugaad/subscriptions/screens/payment_history_screen.dart';
import 'package:rotijugaad/theme/app_icons.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/users/services/users_service.dart';
import 'package:rotijugaad/utils/result.dart';
import 'package:rotijugaad/utils/shared_pref.dart';
import 'package:rotijugaad/employees/providers/employees_provider.dart';
import 'package:rotijugaad/employers/providers/employers_provider.dart';
import 'package:rotijugaad/profile/widgets/verification_rejected.dart';
import 'package:rotijugaad/network/api_client.dart';
import 'package:rotijugaad/verifyidentity/screens/selfie_verification_screen.dart';

import '../dialogs/rate_review_dialog.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDeleteAccountSubmitting = false;

  int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  Future<void> _refreshVerificationStatus() async {
    await SessionRefreshHelper.refreshCurrentSession(context);
  }

  Map<String, dynamic>? get _authUserJson =>
      SharedPrefUtils.readJson(SharedPrefUtils.AUTH_USER_JSON);

  Map<String, dynamic>? get _authProfileJson =>
      SharedPrefUtils.readJson(SharedPrefUtils.AUTH_PROFILE_JSON);

  int? get _userId => _asInt(_authUserJson?["id"]);

  String get _verificationStatus =>
      (_authProfileJson?["verification_status"] ??
              _authProfileJson?["verificationStatus"] ??
              "")
          .toString()
          .trim()
          .toLowerCase();

  String get _kycStatus =>
      (_authProfileJson?["kyc_status"] ?? _authProfileJson?["kycStatus"] ?? "")
          .toString()
          .trim()
          .toLowerCase();

  String get _normalizedVerificationStatus =>
      _verificationStatus == 'init' ? '' : _verificationStatus;

  String get _normalizedKycStatus => _kycStatus == 'init' ? '' : _kycStatus;

  bool get _isEmployeeUser =>
      SharedPrefUtils.readStr(SharedPrefUtils.USER_TYPE).trim().toLowerCase() ==
      'employee';

  bool get _isProfileCompleted =>
      SharedPrefUtils.readBool(SharedPrefUtils.AUTH_PROFILE_COMPLETED);

  bool get _isEmployeePendingReview =>
      _isEmployeeUser &&
      _isProfileCompleted &&
      _verificationStatus == 'pending';

  bool get _isEmployeeProfileIncomplete =>
      _isEmployeeUser &&
      (!_isProfileCompleted || _normalizedVerificationStatus.isEmpty);

  int? get _employeeId =>
      _asInt(_authProfileJson?["id"] ?? _authProfileJson?["employeeId"]);

  String? _resolveProfileImageUrl(String? raw) {
    final value = raw?.trim() ?? '';
    if (value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    if (value.startsWith('/')) {
      return '${ApiClient.baseUrl}$value';
    }
    return '${ApiClient.baseUrl}/$value';
  }

  Future<void> _handleDeleteAccount() async {
    if (_isDeleteAccountSubmitting) return;

    final confirmed =
        await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (context) => const DeleteAccountDialog(),
        ) ??
        false;

    if (!confirmed || !mounted) return;

    final userId = _userId;
    if (userId == null || userId <= 0) {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (_) => PrimaryDialog('errors.unable_to_load_user_id'.tr()),
      );
      return;
    }

    setState(() {
      _isDeleteAccountSubmitting = true;
    });

    final result = await UsersService().submitDeletionRequest(userId);

    if (!mounted) return;

    setState(() {
      _isDeleteAccountSubmitting = false;
    });

    switch (result) {
      case Success():
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => PrimaryDialog(
            'profile.delete_account.submitted'.tr(),
            buttonLabel: 'common.ok'.tr(),
          ),
        );

        if (!mounted) return;
        await LogoutManager.logout(context);
        break;
      case Failure(exception: final e):
        await showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (_) => PrimaryDialog(
            e.message.trim().isNotEmpty
                ? e.message
                : 'profile.delete_account.failed'.tr(),
          ),
        );
        break;
    }
  }

  Future<void> _openEmployeePhotoActions() async {
    if (_normalizedVerificationStatus == 'verified') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('profile.photo.locked_after_verification'.tr()),
        ),
      );
      return;
    }

    final employeeId = _employeeId;
    if (employeeId == null || employeeId <= 0) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => PrimaryDialog('errors.no_employee_id'.tr()),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.spacing.md,
              vertical: context.spacing.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'profile.photo.title'.tr(),
                  style: context.text.titleMedium,
                ),
                SizedBox(height: context.spacing.sm),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.camera_alt_outlined),
                  title: Text('profile.photo.change'.tr()),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    final changed = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) =>
                            SelfieVerificationScreen(employeeId: employeeId),
                      ),
                    );
                    if (!mounted || changed != true) return;
                    await _refreshVerificationStatus();
                    if (!mounted) return;
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showPendingReviewDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const ProfilePendingReviewDialog(),
    );
  }

  Future<void> _showCompleteProfileDialog() {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => ProfileIncompleteDialog(
        title: 'profile.incomplete.title'.tr(),
        message: 'profile.incomplete.message'.tr(),
        laterButtonText: 'profile.incomplete.later'.tr(),
        onLater: () => Navigator.of(dialogContext).pop(),
        onCompleteProfile: () async {
          Navigator.of(dialogContext).pop();
          final updated = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfile(
                mode: EditProfileMode.completeFlow,
                title: 'profile.complete.title'.tr(),
                openKycOnSubmit: true,
              ),
            ),
          );

          if (!mounted || updated != true) return;
          await _refreshVerificationStatus();
          if (!mounted) return;
          setState(() {});
        },
      ),
    );
  }

  Future<void> _openSubscriptionFromProfile() async {
    if (_isEmployeeProfileIncomplete) {
      await _showCompleteProfileDialog();
      return;
    }

    if (_isEmployeePendingReview) {
      await _showPendingReviewDialog();
      return;
    }

    await EmployerProfileActionGuard.openSubscription(context);
  }

  String get _displayName {
    final isHindi = context.locale.languageCode.toLowerCase() == 'hi';

    String? pick(Map<String, dynamic>? map) {
      if (map == null) return null;
      final hi = (map['name_hindi'] ?? map['nameHindi'])?.toString().trim();
      final en = (map['name_english'] ?? map['nameEnglish'] ?? map['name'])
          ?.toString()
          .trim();
      final name = map['name']?.toString().trim();
      final primary = isHindi ? hi : en;
      final fallback = isHindi ? (en ?? name) : (name ?? hi);
      final value = primary ?? fallback ?? hi;
      if (value == null || value.isEmpty) return null;
      return value;
    }

    final profileName = pick(_authProfileJson);
    if (profileName != null) return profileName;

    final userName = pick(_authUserJson);
    if (userName != null) return userName;

    return "";
  }

  String get _rawMobile {
    final userMobile = _authUserJson?["mobile"]?.toString().trim();
    if (userMobile != null && userMobile.isNotEmpty) return userMobile;

    final profileMobile = _authProfileJson?["mobile"]?.toString().trim();
    if (profileMobile != null && profileMobile.isNotEmpty) return profileMobile;

    return "";
  }

  String get _mobileDisplay {
    final m = _rawMobile;
    if (m.isEmpty) return "";
    if (m.startsWith("+")) return m;
    if (m.length == 10 && int.tryParse(m) != null) return "+91 " + m;
    return m;
  }

  String get _planName {
    final plan = _authProfileJson?["SubscriptionPlan"];
    final en = plan is Map
        ? plan["plan_name_english"]?.toString().trim()
        : null;
    final hi = plan is Map ? plan["plan_name_hindi"]?.toString().trim() : null;
    final isHindi =
        SharedPrefUtils.readStr(SharedPrefUtils.APP_LANGUAGE) == "hi";
    final name = (isHindi ? hi : en) ?? en ?? hi;
    return (name != null && name.isNotEmpty) ? name : 'profile.plan.basic'.tr();
  }

  int get _subscriptionPlanId {
    final raw =
        _authProfileJson?["subscription_plan_id"] ??
        _authProfileJson?["subscriptionPlanId"];
    if (raw is int) return raw;
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  bool get _hasSubscriptionPlanId => _subscriptionPlanId > 0;

  DateTime? get _creditExpiryAt =>
      _parseDate(_authProfileJson?["credit_expiry_at"]);

  bool get _hasActiveSubscription {
    final expiry = _creditExpiryAt;
    if (!_hasSubscriptionPlanId || expiry == null) return false;
    return expiry.isAfter(DateTime.now());
  }

  bool get _showCreditsExpiryRow => _creditExpiryAt != null;

  bool get _showUpgradePlanCard => _hasActiveSubscription;

  String get _subscriptionButtonText {
    if (_hasActiveSubscription) {
      final planName = _planName.trim();
      if (planName.isNotEmpty && planName != 'Basic Plan') return planName;
    }
    return 'common.buy_subscription'.tr();
  }

  String get _referralCode =>
      (_authUserJson?["referral_code"] ?? _authUserJson?["referralCode"] ?? "")
          .toString()
          .trim();

  String _fmtNum(dynamic v) {
    if (v == null) return "0";
    if (v is int) return v.toString();
    if (v is double) {
      if (v == v.roundToDouble()) return v.toInt().toString();
      return v.toStringAsFixed(0);
    }
    final n = num.tryParse(v.toString());
    if (n == null) return "0";
    if (n == n.roundToDouble()) return n.toInt().toString();
    return n.toStringAsFixed(0);
  }

  String _fraction(dynamic remaining, dynamic total) =>
      _fmtNum(remaining) + "/" + _fmtNum(total);

  String get _contactCreditsText => _fraction(
    _authProfileJson?["contact_credit"],
    _authProfileJson?["total_contact_credit"],
  );

  String get _interestCreditsText => _fraction(
    _authProfileJson?["interest_credit"],
    _authProfileJson?["total_interest_credit"],
  );

  String get _adCreditsText => _fraction(
    _authProfileJson?["ad_credit"],
    _authProfileJson?["total_ad_credit"],
  );

  String get _contactCreditsLeft => _fmtNum(_authProfileJson?["contact_credit"]);
  String get _interestCreditsLeft => _fmtNum(_authProfileJson?["interest_credit"]);
  String get _adCreditsLeft => _fmtNum(_authProfileJson?["ad_credit"]);

  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is int) {
      final ms = v > 1000000000000 ? v : v * 1000;
      return DateTime.fromMillisecondsSinceEpoch(ms);
    }
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return DateTime.tryParse(s);
  }

  String get _creditsValidTillText {
    final dt = _creditExpiryAt;
    if (dt == null) return '';
    final isExpired = !dt.isAfter(DateTime.now());
    final prefix = isExpired
        ? 'profile.credits_expired_on_prefix'.tr()
        : 'profile.credits_valid_till_prefix'.tr();
    return prefix + DateFormat("d MMM, y").format(dt);
  }

  Widget _buildTopBanner() {
    if (_normalizedKycStatus == "rejected") {
      return const VerificationRejected();
    }
    if (_normalizedKycStatus == "pending") {
      return const VerificationPending();
    }
    if (_kycStatus.isEmpty || _kycStatus == 'init') {
      return const VerificationRequired();
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    // Rebuild when employee/employer detail refreshes so badges update.
    final employeesProvider = context.watch<EmployeesProvider>();
    employeesProvider.employeeDetail;
    employeesProvider.personalInfo;
    context.watch<EmployersProvider>().employerDetail;

    final selfieUrl = _isEmployeeUser
        ? _resolveProfileImageUrl(
            employeesProvider.personalInfo?.selfieLink ??
                employeesProvider.employeeDetail?.selfieLink ??
                _authProfileJson?['selfie_link']?.toString() ??
                _authProfileJson?['selfieLink']?.toString(),
          )
        : null;

    return Scaffold(
      backgroundColor: context.colors.onPrimary,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: context.colors.onPrimary,
              padding: EdgeInsets.symmetric(horizontal: context.spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'profile.screen.title'.tr(),
                    style: context.text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: context.spacing.md),
                ],
              ),
            ),
            _buildTopBanner(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshVerificationStatus,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        color: context.colors.onPrimary,
                        padding: EdgeInsets.symmetric(
                          horizontal: context.spacing.md,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (_isEmployeeUser) ...[
                                  InkWell(
                                    onTap: _openEmployeePhotoActions,
                                    borderRadius: BorderRadius.circular(999),
                                    child: Container(
                                      width: 52,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: context.colors.surface,
                                        border: Border.all(
                                          color: context.xcolors.stroke,
                                        ),
                                      ),
                                      child: ClipOval(
                                        child: selfieUrl != null
                                            ? Image.network(
                                                selfieUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) =>
                                                    Image.asset(
                                                      'assets/images/profile_placeholder.png',
                                                      fit: BoxFit.cover,
                                                    ),
                                              )
                                            : Image.asset(
                                                'assets/images/profile_placeholder.png',
                                                fit: BoxFit.cover,
                                              ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: context.spacing.xs),
                                ],
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          _displayName.isEmpty
                                              ? "—"
                                              : _displayName,
                                          style: context.text.titleMedium,
                                        ),
                                        SizedBox(width: context.spacing.xs),
                                        if (_normalizedVerificationStatus
                                            .isNotEmpty)
                                          InkWell(
                                            onTap:
                                                _normalizedVerificationStatus ==
                                                    "verified"
                                                ? () {
                                                    showModalBottomSheet(
                                                      context: context,
                                                      isScrollControlled: true,
                                                      shape: const RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.vertical(
                                                              top:
                                                                  Radius.circular(
                                                                    20,
                                                                  ),
                                                            ),
                                                      ),
                                                      builder: (context) {
                                                        return const VerifiedProfileSheet();
                                                      },
                                                    );
                                                  }
                                                : null,
                                            child: XIcon(
                                              _normalizedVerificationStatus ==
                                                      "verified"
                                                  ? AppIcon.verified
                                                  : _normalizedVerificationStatus ==
                                                        "pending"
                                                  ? AppIcon.profilePending
                                                  : AppIcon.rejected,
                                              color:
                                                  _normalizedVerificationStatus ==
                                                      "verified"
                                                  ? context.colors.primary
                                                  : _normalizedVerificationStatus ==
                                                        "pending"
                                                  ? context.xcolors.warning
                                                  : context.xcolors.failure,
                                              size: 18,
                                            ),
                                          ),
                                        if (_normalizedVerificationStatus
                                            .isNotEmpty)
                                          SizedBox(width: context.spacing.xs),
                                        if (_normalizedKycStatus == "verified")
                                          InkWell(
                                            onTap: () {
                                              showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                            top:
                                                                Radius.circular(
                                                                  20,
                                                                ),
                                                          ),
                                                    ),
                                                builder: (context) {
                                                  return const KycVerifiedSheet(
                                                    isCurrentUser: true,
                                                  );
                                                },
                                              );
                                            },
                                            child: XIcon(
                                              AppIcon.shield,
                                              color: context.colors.primary,
                                              size: 18,
                                            ),
                                          ),
                                      ],
                                    ),
                                    SizedBox(height: context.spacing.xxs),
                                    Text(
                                      _mobileDisplay.isEmpty
                                          ? "—"
                                          : _mobileDisplay,
                                      style: context.text.bodySmall!.copyWith(
                                        fontWeight: FontWeight.w400,
                                        color: context.colors.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                SizedBox(
                                  height: 40,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      shape: StadiumBorder(),
                                      backgroundColor: context.colors.secondary,
                                      padding: EdgeInsets.symmetric(
                                        vertical: 0,
                                        horizontal: context.spacing.md,
                                      ),
                                    ),
                                    onPressed: () {
                                      _openSubscriptionFromProfile();
                                    },
                                    child: Row(
                                      children: [
                                        XIcon(
                                          AppIcon.crown,
                                          color: context.colors.onPrimary,
                                        ),
                                        SizedBox(width: context.spacing.xs),
                                        Text(
                                          _subscriptionButtonText,
                                          style: context.text.bodyMedium!
                                              .copyWith(
                                                color: context.colors.onPrimary,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: context.spacing.md),
                            Container(
                              decoration: BoxDecoration(
                                color: context.colors.primaryContainer,
                                border: Border.all(
                                  color: context.xcolors.stroke,
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(context.radii.sm),
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: context.spacing.md,
                                vertical: context.spacing.sm,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'profile.credits.contact'.tr(),
                                          style: context.text.bodySmall,
                                        ),
                                        SizedBox(height: context.spacing.xs),
                                        Text(
                                          _contactCreditsText,
                                          style: context.text.bodyMedium!
                                              .copyWith(
                                                color: context.colors.primary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                        SizedBox(height: context.spacing.xs),
                                        Text(
                                          'common.credits_left'.tr(args: [_contactCreditsLeft]),
                                          style: context.text.bodySmall!.copyWith(color: context.colors.secondary),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 64,
                                    color: context.xcolors.stroke,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          SharedPrefUtils.readStr(
                                                SharedPrefUtils.USER_TYPE,
                                              ) ==
                                              "employee"
                                          ? CrossAxisAlignment.end
                                          : CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          'profile.credits.interest'.tr(),
                                          style: context.text.bodySmall,
                                        ),
                                        SizedBox(height: context.spacing.xs),
                                        Text(
                                          _interestCreditsText,
                                          style: context.text.bodyMedium!
                                              .copyWith(
                                                color: context.colors.primary,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                        SizedBox(height: context.spacing.xs),
                                        Text(
                                          'common.credits_left'.tr(args: [_interestCreditsLeft]),
                                          style: context.text.bodySmall!.copyWith(color: context.colors.secondary),
                                        ),
                                      ],
                                    ),
                                  ),

                                  if (SharedPrefUtils.readStr(
                                        SharedPrefUtils.USER_TYPE,
                                      ) ==
                                      "employer") ...[
                                    Container(
                                      width: 1,
                                      height: 40,
                                      color: context.xcolors.stroke,
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            'profile.credits.ads'.tr(),
                                            style: context.text.bodySmall,
                                          ),
                                          SizedBox(height: context.spacing.xs),
                                          Text(
                                            _adCreditsText,
                                            style: context.text.bodyMedium!
                                                .copyWith(
                                                  color: context.colors.primary,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                          ),
                                          SizedBox(height: context.spacing.xs),
                                          Text(
                                            'common.credits_left'.tr(args: [_adCreditsLeft]),
                                            style: context.text.bodySmall!.copyWith(color: context.colors.secondary),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            SizedBox(height: context.spacing.md),
                            if (_showCreditsExpiryRow) ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _creditsValidTillText,
                                      style: context.text.bodyMedium,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (SharedPrefUtils.readStr(
                                            SharedPrefUtils.USER_TYPE,
                                          ) ==
                                          "employee") {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                HistoryScreen(),
                                          ),
                                        );
                                      } else {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                EmployerHistoryScreen(),
                                          ),
                                        );
                                      }
                                    },
                                    child: Text(
                                      'common.view_history'.tr(),
                                      style: context.text.bodyMedium!.copyWith(
                                        color: context.colors.primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: context.spacing.md),
                            ],
                          ],
                        ),
                      ),

                      Container(
                        color: context.colors.background,
                        padding: EdgeInsets.symmetric(
                          horizontal: context.spacing.md,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_showUpgradePlanCard) ...[
                              SizedBox(height: context.spacing.md),
                              InkWell(
                                onTap: () {
                                  _openSubscriptionFromProfile();
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: context.colors.onPrimary,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(context.radii.sm),
                                    ),
                                    border: Border.all(
                                      color: context.xcolors.stroke,
                                      width: 1,
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: context.spacing.md,
                                    vertical: context.spacing.sm,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'profile.upgrade.title'
                                                .tr()
                                                .toUpperCase(),
                                            style: context.text.bodyMedium!
                                                .copyWith(
                                                  color:
                                                      context.colors.secondary,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                          SizedBox(height: context.spacing.xs),
                                          Text(
                                            'profile.upgrade.subtitle'.tr(),
                                            style: context.text.bodySmall,
                                          ),
                                        ],
                                      ),

                                      Icon(Icons.keyboard_arrow_right),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: context.spacing.md),
                            ] else
                              SizedBox(height: context.spacing.md),
                            InkWell(
                              onTap: () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (context) {
                                    return ReferSheet();
                                  },
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: context.colors.onPrimary,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(context.radii.sm),
                                  ),
                                  border: Border.all(
                                    color: context.xcolors.stroke,
                                    width: 1,
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.spacing.md,
                                  vertical: context.spacing.sm,
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'profile.refer.title'
                                                    .tr()
                                                    .toUpperCase(),
                                                style: context.text.bodyMedium!
                                                    .copyWith(
                                                      color: context
                                                          .colors
                                                          .secondary,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                              ),
                                              SizedBox(
                                                height: context.spacing.xs,
                                              ),
                                              Text(
                                                'profile.refer.subtitle'.tr(),
                                                style: context.text.bodySmall,
                                              ),
                                            ],
                                          ),
                                        ),

                                        Icon(Icons.keyboard_arrow_right),
                                      ],
                                    ),

                                    Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: context.spacing.xs,
                                            vertical: context.spacing.sm,
                                          ),
                                          child: XIcon(
                                            AppIcon.copy,
                                            color: context.colors.primary,
                                          ),
                                        ),
                                        Text(
                                          _referralCode.isEmpty
                                              ? "—"
                                              : _referralCode,
                                          style: context.text.bodyMedium!
                                              .copyWith(
                                                color: context.colors.primary,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: context.spacing.md),
                            Text(
                              'profile.sections.account_settings'.tr(),
                              style: context.text.bodyMedium!.copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: context.spacing.sm),
                            if (SharedPrefUtils.readStr(
                                      SharedPrefUtils.USER_TYPE,
                                    ) ==
                                    "employee" ||
                                !EmployerProfileActionGuard.isIncomplete)
                              ProfileOptionItem(
                                AppIcon.editProfile,
                                'profile.actions.edit_profile'.tr(),
                                () async {
                                  final isEmployeeUser =
                                      SharedPrefUtils.readStr(
                                        SharedPrefUtils.USER_TYPE,
                                      ) ==
                                      "employee";

                                  if (!isEmployeeUser &&
                                      EmployerProfileActionGuard.isPending) {
                                    EmployerProfileActionGuard.showPendingDialog(
                                      context,
                                    );
                                    return;
                                  }

                                  if (isEmployeeUser) {
                                    if (_isEmployeePendingReview) {
                                      _showPendingReviewDialog();
                                      return;
                                    }

                                    final updated = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditProfile(
                                          mode: EditProfileMode.formOnly,
                                          title:
                                              'profile.actions.update_profile'
                                                  .tr(),
                                          openKycOnSubmit: false,
                                        ),
                                      ),
                                    );

                                    if (!mounted || updated != true) return;
                                    await _refreshVerificationStatus();
                                    if (!mounted) return;
                                    setState(() {});
                                  } else {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditEmployerProfileScreen(
                                              goToVerifyIdentityOnSuccess:
                                                  false,
                                            ),
                                      ),
                                    );

                                    if (!mounted) return;
                                    await _refreshVerificationStatus();
                                    if (!mounted) return;
                                    setState(() {});
                                  }
                                },
                              ),
                            ProfileOptionItem(
                              AppIcon.changeMobile,
                              'profile.actions.change_mobile'.tr(),
                              () async {
                                if (_isEmployeeProfileIncomplete) {
                                  await _showCompleteProfileDialog();
                                  return;
                                }

                                if (_isEmployeePendingReview) {
                                  await _showPendingReviewDialog();
                                  return;
                                }

                                if (!_isEmployeeUser &&
                                    EmployerProfileActionGuard.isPending) {
                                  await EmployerProfileActionGuard.showPendingDialog(
                                    context,
                                  );
                                  return;
                                }

                                if (!_isEmployeeUser &&
                                    EmployerProfileActionGuard.isRejected) {
                                  await EmployerProfileActionGuard.showRejectedDialog(
                                    context,
                                  );
                                  return;
                                }

                                final changed =
                                    await showModalBottomSheet<bool>(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                      ),
                                      builder: (context) {
                                        return ChangeMobileSheet();
                                      },
                                    );

                                if (changed == true && context.mounted) {
                                  setState(() {});
                                  showDialog(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (context) => PrimaryDialog(
                                      'profile.change_mobile.success'.tr(),
                                    ),
                                  );
                                }
                              },
                            ),

                            if (SharedPrefUtils.readStr(
                                  SharedPrefUtils.USER_TYPE,
                                ) ==
                                "employee")
                              ProfileOptionItem(
                                AppIcon.updateExperience,
                                'profile.actions.update_experiences'.tr(),
                                () async {
                                  if (_isEmployeeProfileIncomplete) {
                                    await _showCompleteProfileDialog();
                                    return;
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UpdateExperienceScreen(),
                                    ),
                                  );
                                },
                              ),
                            if (SharedPrefUtils.readStr(
                                  SharedPrefUtils.USER_TYPE,
                                ) ==
                                "employer")
                              ProfileOptionItem(
                                AppIcon.shortlisted,
                                'profile.actions.shortlisted_candidates'.tr(),
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ShortlistedCandidatesScreen(),
                                    ),
                                  );
                                },
                              ),
                            ProfileOptionItem(
                              AppIcon.changeLanguage,
                              'common.change_language'.tr(),
                              () {
                                showDialog(
                                  context: context,
                                  barrierDismissible:
                                      true, // allows tap outside to close
                                  builder: (context) => UpdateLanguageDialog(),
                                );
                              },
                            ),
                            if (SharedPrefUtils.readStr(
                                  SharedPrefUtils.USER_TYPE,
                                ) ==
                                "employee") ...[
                              SizedBox(height: context.spacing.md),
                              Text(
                                'profile.sections.work_job_history'.tr(),
                                style: context.text.bodyMedium!.copyWith(
                                  color: context.colors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: context.spacing.sm),
                              ProfileOptionItem(
                                AppIcon.updatePreference,
                                'profile.actions.update_preferences'.tr(),
                                () async {
                                  if (_isEmployeeProfileIncomplete) {
                                    await _showCompleteProfileDialog();
                                    return;
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          UpdatePreferenceScreen(),
                                    ),
                                  );
                                },
                              ),
                              ProfileOptionItem(
                                AppIcon.attachment,
                                'profile.actions.additional_documents'.tr(),
                                () async {
                                  if (_isEmployeeProfileIncomplete) {
                                    await _showCompleteProfileDialog();
                                    return;
                                  }

                                  final employeeId = _employeeId;
                                  if (employeeId == null || employeeId <= 0) {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: true,
                                      builder: (context) => PrimaryDialog(
                                        'errors.no_employee_id'.tr(),
                                      ),
                                    );
                                    return;
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Scaffold(
                                        backgroundColor:
                                            context.colors.onPrimary,
                                        appBar: AppBar(
                                          titleSpacing: 0,
                                          title: Text(
                                            'profile.additional_documents.title'
                                                .tr(),
                                            style: context.text.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                          ),
                                        ),
                                        body: SafeArea(
                                          child: Padding(
                                            padding: EdgeInsets.all(
                                              context.spacing.md,
                                            ),
                                            child: DocumentsScreen(
                                              employeeId: employeeId,
                                              showContinueActions: false,
                                              onButtonClicked: () {},
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              ProfileOptionItem(
                                AppIcon.profileHiredJob,
                                'profile.hired_jobs'.tr(),
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HiredJobsScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],

                            ProfileOptionItem(
                              AppIcon.paymentHistory,
                              'profile.actions.payment_history'.tr(),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        PaymentHistoryScreen(),
                                  ),
                                );
                              },
                            ),

                            SizedBox(height: context.spacing.md),
                            Text(
                              'profile.sections.app_privacy'.tr(),
                              style: context.text.bodyMedium!.copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: context.spacing.sm),
                            ProfileOptionItem(
                              AppIcon.privacyPolicy,
                              'profile.actions.privacy_policy'.tr(),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PrivacyPolicyScreen(),
                                  ),
                                );
                              },
                            ),
                            ProfileOptionItem(
                              AppIcon.termsConditions,
                              'profile.actions.terms_conditions'.tr(),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TermsConditionScreen(),
                                  ),
                                );
                              },
                            ),
                            ProfileOptionItem(
                              AppIcon.refundPolicy,
                              'profile.actions.refund_policy'.tr(),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RefundPolicyScreen(),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: context.spacing.md),
                            Text(
                              'profile.sections.general_support'.tr(),
                              style: context.text.bodyMedium!.copyWith(
                                color: context.colors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: context.spacing.sm),
                            ProfileOptionItem(
                              AppIcon.helpSupportFilled,
                              'profile.actions.help_support'.tr(),
                              () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HelpSupportScreen(),
                                  ),
                                );
                              },
                            ),
                            ProfileOptionItem(
                              AppIcon.rateReview,
                              'profile.actions.rate_review'.tr(),
                              () async {
                                final lowRating = await showDialog<bool>(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (_) => const RateReviewDialog(),
                                );
                                if (lowRating == true && context.mounted) {
                                  await showDialog<void>(
                                    context: context,
                                    barrierDismissible: true,
                                    builder: (_) => PrimaryDialog(
                                      'profile.rate_review.submitted'.tr(),
                                    ),
                                  );
                                }
                              },
                            ),
                            ProfileOptionItem(
                              AppIcon.shareApp,
                              'profile.actions.share_app'.tr(),
                              () {
                                showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (context) {
                                    return ReferSheet();
                                  },
                                );
                              },
                            ),
                            ProfileOptionItem(
                              AppIcon.deleteAccount,
                              'profile.delete_account.button'.tr(),
                              _handleDeleteAccount,
                            ),
                            GestureDetector(
                              onTap: () async {
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  barrierDismissible:
                                      true, // allows tap outside to close
                                  builder: (context) => const LogoutDialog(),
                                );
                                if (confirmed == true && context.mounted) {
                                  await LogoutManager.logout(context);
                                }
                              },
                              child: Container(
                                width: double.infinity,
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.spacing.xs,
                                  vertical: context.spacing.md,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    XIcon(
                                      AppIcon.logout,
                                      color: context.xcolors.failure,
                                    ),
                                    SizedBox(width: context.spacing.sm),
                                    Text(
                                      'common.logout'.tr(),
                                      style: context.text.bodyMedium!.copyWith(
                                        color: context.xcolors.failure,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: context.spacing.xxxl),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
