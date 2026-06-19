import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/common/widgets/employee_identity_badges.dart';
import 'package:rotijugaad/jobdetails/dialogs/dial_dialog.dart';
import 'package:rotijugaad/jobdetails/dialogs/interest_sent_dialog.dart';
import 'package:rotijugaad/jobdetails/dialogs/no_credits_dialog.dart';
import 'package:rotijugaad/jobdetails/screens/call_experience_screen.dart';
import 'package:rotijugaad/network/api_client.dart';
import 'package:rotijugaad/subscriptions/dialogs/no_subscription_dialog.dart';
import 'package:rotijugaad/subscriptions/dialogs/subscription_ended_dialog.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:rotijugaad/jobdetails/dialogs/send_interest_dialog.dart';
import 'package:rotijugaad/jobdetails/providers/job_details_provider.dart';
import 'package:rotijugaad/jobdetails/sheets/match_otp_sheet.dart';
import 'package:rotijugaad/jobdetails/sheets/report_job_sheet.dart';
import 'package:rotijugaad/jobdetails/widgets/info_chip.dart';
import 'package:rotijugaad/jobdetails/widgets/job_details_shimmer.dart';
import 'package:rotijugaad/jobdetails/widgets/otp_card.dart';
import 'package:rotijugaad/profile/dialogs/profile_incomplete_dialog.dart';
import 'package:rotijugaad/profile/dialogs/profile_pending_review_dialog.dart';
import 'package:rotijugaad/profile/dialogs/profile_rejected_resubmit_dialog.dart';
import 'package:rotijugaad/theme/app_icons.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/utils/i18n_terms.dart';
import 'package:rotijugaad/utils/job_text_utils.dart';
import 'package:rotijugaad/utils/shared_pref.dart';

import '../../common/widgets/icon_text.dart';
import '../../common/widgets/toolbar.dart';
import '../../common/widgets/xicon.dart';
import '../../editprofile/screens/edit_profile.dart';
import '../dialogs/get_contact_dialog.dart';
import '../models/job_detail_dto.dart';

class JobDetailsScreen extends StatefulWidget {
  final int? jobId;
  final int? employeeId;

  const JobDetailsScreen({super.key, this.jobId, this.employeeId});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen>
    with WidgetsBindingObserver {
  late final JobDetailsProvider _provider;
  bool _openCallExperienceOnResume = false;

  Map<String, dynamic>? get _authUserJson =>
      SharedPrefUtils.readJson(SharedPrefUtils.AUTH_USER_JSON);

  Map<String, dynamic>? get _authProfileJson =>
      SharedPrefUtils.readJson(SharedPrefUtils.AUTH_PROFILE_JSON);

  String _shareOwnerName(BuildContext context) {
    String? pick(Map<String, dynamic>? map) {
      if (map == null) return null;
      final hi = (map['name_hindi'] ?? map['nameHindi'])?.toString().trim();
      final en = (map['name_english'] ?? map['nameEnglish'] ?? map['name'])
          ?.toString()
          .trim();
      final primary = en;
      final fallback = hi;
      final value = (primary?.isNotEmpty == true ? primary : fallback) ?? '';
      return value.trim().isEmpty ? null : value.trim();
    }

    return pick(_authProfileJson) ?? pick(_authUserJson) ?? 'Dost';
  }

  String _jobShareMessage(BuildContext context, String link) {
    final ownerName = _shareOwnerName(context);
    return [
      '$ownerName ne ek job share ki hai.',
      'Agar aap interested ho to yahan details check karo:',
      link,
    ].join('\n');
  }

  String get _verificationStatus =>
      ((_authProfileJson?['verification_status'] ??
                  _authProfileJson?['verificationStatus'] ??
                  '')
              .toString()
              .trim()
              .toLowerCase() ==
          'init')
      ? ''
      : (_authProfileJson?['verification_status'] ??
                _authProfileJson?['verificationStatus'] ??
                '')
            .toString()
            .trim()
            .toLowerCase();

  bool get _isProfileCompleted =>
      SharedPrefUtils.readBool(SharedPrefUtils.AUTH_PROFILE_COMPLETED);

  bool get _isEmployeeProfileIncomplete =>
      !_isProfileCompleted || _verificationStatus.isEmpty;

  bool get _isEmployeePendingReview =>
      _isProfileCompleted && _verificationStatus == 'pending';

  bool get _isEmployeeRejected =>
      _isProfileCompleted && _verificationStatus == 'rejected';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);
    _provider = JobDetailsProvider();

    final jobId = widget.jobId;
    final employeeId = widget.employeeId;
    if (jobId != null && employeeId != null && jobId > 0 && employeeId > 0) {
      _provider.fetch(jobId: jobId, employeeId: employeeId);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (!_openCallExperienceOnResume) return;
    if (!mounted) return;

    _openCallExperienceOnResume = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final jid = widget.jobId;
      final eid = widget.employeeId;
      if (jid == null || eid == null || jid <= 0 || eid <= 0) return;

      Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => CallExperienceScreen(
            jobId: jid,
            employeeId: eid,
            provider: _provider,
          ),
        ),
      ).then((shared) {
        if (shared == true) {
          _provider.fetch(jobId: jid, employeeId: eid);
        }
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _provider.dispose();
    super.dispose();
  }

  static String? _joinLocation(String? city, String? state) {
    final parts = <String>[];
    if (city != null && city.trim().isNotEmpty) parts.add(city.trim());
    if (state != null && state.trim().isNotEmpty) parts.add(state.trim());
    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  static String? _composeAddress(
    String? org,
    String? address,
    String? city,
    String? state,
  ) {
    final parts = <String>[];

    final o = (org ?? "").trim();
    if (o.isNotEmpty) parts.add(o);

    final a = (address ?? "").trim();
    if (a.isNotEmpty) parts.add(a);

    final loc = _joinLocation(city, state);
    if (loc != null && loc.trim().isNotEmpty) parts.add(loc.trim());

    if (parts.isEmpty) return null;
    return parts.join(", ");
  }

  static String _formatTime12(String? raw) {
    final v = (raw ?? '').trim();
    if (v.isEmpty) return '';

    final parts = v.split(':');
    if (parts.isEmpty) return v;

    final h = int.tryParse(parts[0]);
    final m = parts.length > 1 ? int.tryParse(parts[1]) : 0;
    if (h == null || h < 0 || h > 23) return v;

    final minute = (m ?? 0).clamp(0, 59);
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = (h % 12 == 0) ? 12 : (h % 12);

    final mm = minute.toString().padLeft(2, '0');
    return '$hour12:$mm $period';
  }

  static String? _workTimeRangeText(String? start, String? end) {
    final s = _formatTime12(start).trim();
    final e = _formatTime12(end).trim();
    if (s.isEmpty && e.isEmpty) return null;
    if (s.isEmpty) return e;
    if (e.isEmpty) return s;
    return '$s - $e';
  }

  String _workDaysDisplayText(BuildContext context, List<String> rawDays) {
    const full = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    const abbr = <String>['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    int? parseDayIndex(String raw) {
      final s = raw.trim().toLowerCase();
      if (s.isEmpty) return null;

      final n = int.tryParse(s);
      if (n != null) return n;

      switch (s) {
        case 'mon':
        case 'monday':
          return 1;
        case 'tue':
        case 'tues':
        case 'tuesday':
          return 2;
        case 'wed':
        case 'wednesday':
          return 3;
        case 'thu':
        case 'thur':
        case 'thurs':
        case 'thursday':
          return 4;
        case 'fri':
        case 'friday':
          return 5;
        case 'sat':
        case 'saturday':
          return 6;
        case 'sun':
        case 'sunday':
          return 7;
        default:
          return null;
      }
    }

    final workedSet = <int>{};
    for (final raw in rawDays) {
      final d = parseDayIndex(raw);
      if (d == null) continue;
      if (d < 1 || d > 7) continue;
      workedSet.add(d);
    }

    if (workedSet.isEmpty) return '';

    String fullName(int d) => I18nTerms.fromRaw(context, full[d - 1]);
    String abbrName(int d) => I18nTerms.fromRaw(context, abbr[d - 1]);

    final days = workedSet.toList()..sort();

    final count = days.length;
    final dayWord = count == 1
        ? I18nTerms.fromRaw(context, 'day')
        : I18nTerms.fromRaw(context, 'days');

    if (count == 1) {
      return 'job_details.work_days_single'.tr(
        args: [count.toString(), dayWord, fullName(days.first)],
      );
    }

    var isConsecutive = true;
    for (var i = 1; i < days.length; i++) {
      if (days[i] != days[i - 1] + 1) {
        isConsecutive = false;
        break;
      }
    }

    final String body;
    if (isConsecutive) {
      body = '${abbrName(days.first)}-${abbrName(days.last)}';
    } else {
      body = days.map(abbrName).join(', ');
    }

    return 'job_details.work_days_range'.tr(
      args: [count.toString(), dayWord, body],
    );
  }

  String _sanitizePhone(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty || value.startsWith('-')) return '';
    final digits = value.replaceAll(RegExp(r'\D+'), '');
    if (digits.isEmpty) return '';
    return value;
  }

  Future<bool> _ensureActiveSubscription(
    BuildContext context,
    String? subscriptionStatus,
    DateTime? creditExpiryAt,
  ) async {
    final expiry = creditExpiryAt;
    if (expiry != null && expiry.isAfter(DateTime.now())) return true;

    final s = (subscriptionStatus ?? "").trim().toLowerCase();
    if (s == "active") return true;

    final isExpired = expiry != null && !expiry.isAfter(DateTime.now());

    final Widget dialog = (isExpired || s == "ended" || s == "expired")
        ? const SubscriptionEndedDialog()
        : const NoSubscriptionDialog();

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => dialog,
    );

    return false;
  }

  Future<void> _showNoCredits(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => NoCreditsDialog(title: title, message: message),
    );
  }

  void _showSnack(BuildContext context, String message) {
    final t = message.trim();
    if (t.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  Future<bool> _guardEmployeeVerification(BuildContext context) async {
    if (_isEmployeeProfileIncomplete) {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => ProfileIncompleteDialog(
          title: 'profile.incomplete.title'.tr(),
          message: 'profile.incomplete.message'.tr(),
          laterButtonText: 'profile.incomplete.later'.tr(),
          onLater: () => Navigator.of(dialogContext).pop(),
          onCompleteProfile: () {
            Navigator.of(dialogContext).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditProfile(
                  mode: EditProfileMode.completeFlow,
                  title: 'profile.complete.title'.tr(),
                  openKycOnSubmit: true,
                ),
              ),
            );
          },
        ),
      );
      return false;
    }

    if (_isEmployeePendingReview) {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (_) => const ProfilePendingReviewDialog(),
      );
      return false;
    }

    if (_isEmployeeRejected) {
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) => ProfileRejectedResubmitDialog(
          onResubmit: () {
            Navigator.of(dialogContext).pop();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => EditProfile(
                  mode: EditProfileMode.completeFlow,
                  title: 'profile.resubmit.title'.tr(),
                  openKycOnSubmit: true,
                ),
              ),
            );
          },
        ),
      );
      return false;
    }

    return true;
  }

  Future<void> _launchDialer(
    BuildContext context,
    String phone, {
    required bool shouldOpenCallExperience,
  }) async {
    final p = phone.trim();
    if (p.isEmpty) {
      _showSnack(context, "Phone number not available.");
      return;
    }

    final uri = Uri(scheme: "tel", path: p);

    try {
      _openCallExperienceOnResume = shouldOpenCallExperience;
      final ok = await launchUrl(uri);
      if (!ok) {
        _openCallExperienceOnResume = false;
        _showSnack(context, "Could not open dialer.");
      }
    } catch (_) {
      _openCallExperienceOnResume = false;
      _showSnack(context, "Could not open dialer.");
    }
  }

  Future<void> _handleGetContact(
    BuildContext context,
    JobDetailsProvider provider,
    int jobId,
    int employeeId,
  ) async {
    final detail = provider.detail;
    if (detail == null) return;
    if (detail.isContactUnlocked) return;

    final canProceed = await _guardEmployeeVerification(context);
    if (!canProceed) return;

    final okSub = await _ensureActiveSubscription(
      context,
      detail.subscriptionStatus,
      detail.creditExpiryAt,
    );
    if (!okSub) return;

    if (detail.contactCreditAvailable <= 0) {
      await _showNoCredits(
        context,
        title: 'candidates.detail.no_contact_credits'.tr(),
        message:
            "You have 0/${detail.contactCreditTotal} contact credits remaining.",
      );
      return;
    }

    final confirmed =
        await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (_) => GetContactDialog(
            available: detail.contactCreditAvailable,
            total: detail.contactCreditTotal,
          ),
        ) ??
        false;

    if (!confirmed) return;

    final ok = await provider.unlockContact(
      jobId: jobId,
      employeeId: employeeId,
    );
    if (!ok) {
      _showSnack(
        context,
        provider.lastError?.message ??
            'candidates.detail.failed_unlock_contact'.tr(),
      );
      return;
    }

    final refreshed = provider.detail;
    final phone = (refreshed?.employerPhone ?? "").trim();
    final address = _composeAddress(
      refreshed?.organizationName ?? refreshed?.employerName,
      refreshed?.jobAddress,
      refreshed?.jobCity,
      refreshed?.jobState,
    );

    final shouldDial =
        await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (_) => DialDialog(
            phone: phone,
            address: address,
            lat: refreshed?.lat,
            lng: refreshed?.lng,
          ),
        ) ??
        false;

    if (shouldDial) {
      final alreadyShared = refreshed?.isCallExperienceShared ?? false;
      await _launchDialer(
        context,
        phone,
        shouldOpenCallExperience: !alreadyShared,
      );
    }
  }

  Future<void> _handleSendInterest(
    BuildContext context,
    JobDetailsProvider provider,
    int jobId,
    int employeeId,
  ) async {
    final detail = provider.detail;
    if (detail == null) return;
    if (detail.hasInterest) return;

    final canProceed = await _guardEmployeeVerification(context);
    if (!canProceed) return;

    final okSub = await _ensureActiveSubscription(
      context,
      detail.subscriptionStatus,
      detail.creditExpiryAt,
    );
    if (!okSub) return;

    if (detail.interestCreditAvailable <= 0) {
      await _showNoCredits(
        context,
        title: 'candidates.send_interest.no_interest_credits'.tr(),
        message:
            "You have 0/${detail.interestCreditTotal} interest credits remaining.",
      );
      return;
    }

    final confirmed =
        await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (_) => SendInterestDialog(
            available: detail.interestCreditAvailable,
            total: detail.interestCreditTotal,
          ),
        ) ??
        false;

    if (!confirmed) return;

    final ok = await provider.sendInterest(
      jobId: jobId,
      employeeId: employeeId,
    );
    if (!ok) {
      final errorMessage =
          provider.lastError?.message ??
          'job_details.failed_send_interest'.tr();
      _showSnack(context, errorMessage);
      if (_shouldRefreshAfterInterestFailure(errorMessage)) {
        await provider.fetch(jobId: jobId, employeeId: employeeId);
      }
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => InterestSentDialog(),
    );
  }

  bool _shouldRefreshAfterInterestFailure(String? message) {
    final text = (message ?? '').trim().toLowerCase();
    return text == 'interest already sent for this job' ||
        text == 'interest already received for this job';
  }

  String _salaryText(double? min, double? max, String? type) {
    final t = (type ?? '').trim();

    final fmt = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: 0,
    );

    String? range;
    if (min != null && max != null) {
      range = fmt.format(min) + ' - ' + fmt.format(max);
    } else if (min != null) {
      range = '${'common.from'.tr()} ${fmt.format(min)}';
    } else if (max != null) {
      range = 'common.up_to'.tr(args: [fmt.format(max)]);
    }

    if (range == null) {
      return t.isEmpty
          ? 'common.salary_not_specified'.tr()
          : I18nTerms.fromRaw(context, t);
    }

    if (t.isEmpty) return range;

    final localizedType = I18nTerms.fromRaw(context, t);
    final lower = t.toLowerCase();
    if (lower.startsWith('per ')) {
      return '$range $localizedType';
    }
    if (t.startsWith('/')) {
      return '$range/$localizedType';
    }
    return '$range/$localizedType';
  }

  String _postedOnText(DateTime? createdAt) {
    if (createdAt == null) return 'job_details.posted_not_available'.tr();
    return 'job_details.posted_on'.tr(
      args: [
        DateFormat(
          'd MMM, y',
          context.locale.toString(),
        ).format(createdAt.toLocal()),
      ],
    );
  }

  String _formatExperienceLabel(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return value;

    final lower = value.toLowerCase();
    final alreadyFormatted =
        lower.contains('experienced') || value.contains('अनुभवी');
    if (alreadyFormatted) return I18nTerms.fromRaw(context, value);

    final looksLikeRange =
        RegExp(r'\d').hasMatch(value) &&
        (lower.contains('year') || value.contains('वर्ष'));
    if (!looksLikeRange) return I18nTerms.fromRaw(context, value);

    return '${'terms.experienced'.tr()} ($value)';
  }

  String _formatGenderLabel(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return value;

    final lower = value.toLowerCase();
    if (lower == 'any' ||
        lower == 'both' ||
        value == 'कोई भी' ||
        value == 'दोनों') {
      return '${'terms.male'.tr()}/${'terms.female'.tr()}';
    }

    return I18nTerms.fromRaw(context, value);
  }

  List<Widget> _buildWhoCanApplyChips(JobDetailDto detail) {
    return _chips([
      ...detail.qualifications,
      ...detail.experiences.map(_formatExperienceLabel),
      ...detail.genders.map(_formatGenderLabel),
    ]);
  }

  List<Widget> _chips(List<String> items) {
    final out = <Widget>[];
    for (final item in items) {
      final t = item.trim();
      if (t.isEmpty) continue;
      out.add(InfoChip(I18nTerms.fromRaw(context, t)));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<JobDetailsProvider>(
        builder: (context, provider, _) {
          final detail = provider.detail;
          final jobId = widget.jobId;
          final employeeId = widget.employeeId;

          final hasIds =
              jobId != null &&
              employeeId != null &&
              jobId > 0 &&
              employeeId > 0;

          final isLoading = provider.isLoading && detail == null;

          final hasInterest = detail?.hasInterest ?? false;
          final isContactUnlocked = detail?.isContactUnlocked ?? false;

          final isOtpUnlocked = detail?.otpUnlockedAt != null;
          final otp = (detail?.otp ?? '').trim();

          final isWishlisted = detail?.isInWishlist ?? false;

          final title = detail?.jobProfile ?? 'employer_jobs.job_details'.tr();
          final designation = (detail?.jobDesignation ?? '').trim();
          final revealOrg = (detail?.showOrganization ?? true) || (detail?.isContactUnlocked ?? false);
          final org = revealOrg ? (detail?.organizationName ?? detail?.employerName) : null;
          final businessCategory = (detail?.businessCategory ?? '').trim();
          final showOrganizationType = businessCategory.isNotEmpty;

          final location =
              _joinLocation(detail?.jobCity, detail?.jobState) ?? '-';

          final salaryText = _salaryText(
            detail?.salaryMin,
            detail?.salaryMax,
            detail?.salaryType,
          );

          final vacancies = detail?.noVacancy;
          final vacancyText = (vacancies == null)
              ? null
              : formatVacancyCountText(vacancies, padToTwoDigits: true);

          final employerPhone = _sanitizePhone(detail?.employerPhone);

          final contactUnlockedAt = detail?.contactUnlockedAt;
          final contactUnlockedLabel = contactUnlockedAt == null
              ? null
              : 'history.unlocked_on'.tr(
                  args: [
                    DateFormat(
                      'h:mm a MMM d, y',
                      context.locale.toString(),
                    ).format(contactUnlockedAt.toLocal()),
                  ],
                );

          final interestAt = detail?.interestStatusAt;
          final isInterestSent = detail?.isInterestSent ?? false;
          final isInterestReceived = detail?.isInterestReceived ?? false;
          final interestAtLabel = interestAt == null
              ? null
              : (isInterestReceived
                        ? 'job_details.received_on'
                        : 'job_details.sent_on')
                    .tr(
                      args: [
                        DateFormat(
                          'd MMM, y • h:mm a',
                          context.locale.toString(),
                        ).format(interestAt.toLocal()),
                      ],
                    );

          final interestStatus = (detail?.interestStatus ?? '')
              .trim()
              .toLowerCase();

          final isRejectedInterest = interestStatus == 'rejected';

          final String statusLabel;
          if (interestStatus == 'hired') {
            statusLabel = I18nTerms.fromRaw(context, 'hired');
          } else if (interestStatus == 'rejected') {
            statusLabel = I18nTerms.fromRaw(context, 'rejected');
          } else if (isInterestSent) {
            statusLabel = I18nTerms.fromRaw(context, 'applied');
          } else {
            statusLabel = I18nTerms.fromRaw(context, 'active');
          }

          final AppIcon statusIcon;
          final Color statusBackground;
          final Color statusForeground;
          if (interestStatus == 'hired') {
            statusIcon = AppIcon.hired;
            statusBackground = context.xcolors.hiredStatusBackground;
            statusForeground = context.xcolors.hiredStatusForeground;
          } else if (interestStatus == 'rejected') {
            statusIcon = AppIcon.rejected;
            statusBackground = context.xcolors.failureBackground;
            statusForeground = context.xcolors.failure;
          } else if (isInterestSent) {
            statusIcon = AppIcon.applied;
            statusBackground = context.xcolors.infoBackground;
            statusForeground = context.xcolors.info;
          } else {
            statusIcon = AppIcon.activeJob;
            statusBackground = context.xcolors.successBackground;
            statusForeground = context.xcolors.success;
          }

          final interestTitle = isInterestReceived
              ? 'job_details.received_interest'.tr()
              : 'job_details.sent_interest'.tr();

          final workTimeRange = _workTimeRangeText(
            detail?.workStartTime,
            detail?.workEndTime,
          );

          final jobDaysText = _workDaysDisplayText(
            context,
            detail?.jobDays ?? const <String>[],
          );

          Future<void> openMatchOtpSheet() async {
            final jid = jobId;
            final eid = employeeId;
            if (jid == null || eid == null) return;

            await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (_) {
                return ChangeNotifierProvider.value(
                  value: provider,
                  child: MatchOtpSheet(jobId: jid, employeeId: eid),
                );
              },
            );
          }

          Widget sectionTitle(AppIcon icon, String text) {
            return Row(
              children: [
                XIcon(icon, color: context.colors.primary),
                SizedBox(width: context.spacing.sm),
                Text(
                  text,
                  style: context.text.titleMedium!.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            );
          }

          Widget cardContainer({required Widget child}) {
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(context.spacing.md),
              decoration: BoxDecoration(
                color: context.colors.onPrimary,
                borderRadius: BorderRadius.circular(context.radii.lg),
                border: Border.all(color: context.xcolors.stroke),
              ),
              child: child,
            );
          }

          return Scaffold(
            backgroundColor: context.colors.onPrimary,
            body: SafeArea(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Toolbar('employer_jobs.job_details'.tr(), () {
                        Navigator.of(context).pop();
                      }),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              final slug = provider.detail?.slug;
                              final s = (slug ?? '').trim();
                              if (s.isEmpty) {
                                _showSnack(
                                  context,
                                  'job_details.link_unavailable'.tr(),
                                );
                                return;
                              }

                              final base = ApiClient.baseUrl.endsWith('/')
                                  ? ApiClient.baseUrl.substring(
                                      0,
                                      ApiClient.baseUrl.length - 1,
                                    )
                                  : ApiClient.baseUrl;
                              final link =
                                  '$base/app/jobs/${Uri.encodeComponent(s)}';
                              Share.share(_jobShareMessage(context, link));
                            },
                            icon: XIcon(AppIcon.shareJob),
                          ),
                          IconButton(
                            onPressed: hasIds
                                ? () {
                                    final jid = jobId;
                                    final eid = employeeId;
                                    provider.toggleWishlist(
                                      jobId: jid,
                                      employeeId: eid,
                                    );
                                  }
                                : null,
                            icon: XIcon(
                              isWishlisted
                                  ? AppIcon.wishlist
                                  : AppIcon.bookmarkJob,
                              color: isWishlisted
                                  ? context.colors.primary
                                  : null,
                            ),
                          ),
                          IconButton(
                            onPressed: hasIds
                                ? () {
                                    final d = provider.detail;

                                    if (d?.isReported == true) {
                                      final reportedAt = d?.reportedAt;
                                      final dateText = reportedAt == null
                                          ? '-'
                                          : DateFormat(
                                              'd MMM, y',
                                            ).format(reportedAt.toLocal());

                                      showModalBottomSheet<void>(
                                        context: context,
                                        isScrollControlled: true,
                                        shape: const RoundedRectangleBorder(
                                          borderRadius: BorderRadius.vertical(
                                            top: Radius.circular(20),
                                          ),
                                        ),
                                        builder: (_) {
                                          return Padding(
                                            padding: EdgeInsets.only(
                                              left: context.spacing.lg,
                                              right: context.spacing.lg,
                                              top: context.spacing.lg,
                                              bottom: context.spacing.lg,
                                            ),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    XIcon(
                                                      AppIcon.success,
                                                      color: context
                                                          .xcolors
                                                          .success,
                                                    ),
                                                    SizedBox(
                                                      width: context.spacing.sm,
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        'job_details.already_reported_on'
                                                            .tr(
                                                              args: [dateText],
                                                            ),
                                                        style: context
                                                            .text
                                                            .bodyMedium!
                                                            .copyWith(
                                                              color: context
                                                                  .colors
                                                                  .onPrimaryContainer,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ),
                                                    ),
                                                    IconButton(
                                                      onPressed: () {
                                                        Navigator.of(
                                                          context,
                                                        ).pop();
                                                      },
                                                      icon: XIcon(
                                                        AppIcon.clear,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  height: context.spacing.md,
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                                      return;
                                    }

                                    showModalBottomSheet<void>(
                                      context: context,
                                      isScrollControlled: true,
                                      shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(20),
                                        ),
                                      ),
                                      builder: (_) {
                                        return ChangeNotifierProvider.value(
                                          value: provider,
                                          child: ReportJobSheet(
                                            jobId: jobId,
                                            employeeId: employeeId,
                                          ),
                                        );
                                      },
                                    );
                                  }
                                : null,
                            icon: XIcon(AppIcon.jobInfo),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: isLoading
                        ? const JobDetailsShimmer()
                        : (detail == null)
                        ? Center(
                            child: Text(
                              'job_details.not_available'.tr(),
                              style: context.text.bodyMedium,
                            ),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: context.spacing.lg,
                                    vertical: context.spacing.md,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  title,
                                                  style: context
                                                      .text
                                                      .titleMedium!
                                                      .copyWith(
                                                        color: context
                                                            .colors
                                                            .primary,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                ),
                                                if (revealOrg) ...[
                                                SizedBox(
                                                  height: context.spacing.xs,
                                                ),
                                                Row(
                                                  children: [
                                                    if (org != null)
                                                    Flexible(
                                                      child: Text(
                                                        org,
                                                        style: context
                                                            .text
                                                            .titleMedium!
                                                            .copyWith(
                                                              color: context
                                                                  .colors
                                                                  .secondary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                      ),
                                                    ),
                                                    if (detail
                                                        .isEmployerVerified) ...[
                                                      if (org != null)
                                                      SizedBox(
                                                        width:
                                                            context.spacing.xs,
                                                      ),
                                                      const KycVerifiedBadgeIcon(
                                                        size: 18,
                                                        isCurrentUser: false,
                                                      ),
                                                    ],
                                                  ],
                                                ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          if ((detail.profileImage ?? '')
                                              .trim()
                                              .isNotEmpty)
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    context.radii.md,
                                                  ),
                                              child: Image.network(
                                                detail.profileImage!,
                                                width: 56,
                                                height: 56,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) {
                                                  return Container(
                                                    width: 56,
                                                    height: 56,
                                                    color: context
                                                        .colors
                                                        .primaryContainer,
                                                    alignment: Alignment.center,
                                                    child: XIcon(
                                                      AppIcon.company,
                                                      color: context
                                                          .colors
                                                          .primary,
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                          else
                                            Container(
                                              width: 56,
                                              height: 56,
                                              decoration: BoxDecoration(
                                                color: context
                                                    .colors
                                                    .primaryContainer,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      context.radii.md,
                                                    ),
                                              ),
                                              alignment: Alignment.center,
                                              child: XIcon(
                                                AppIcon.company,
                                                color: context.colors.primary,
                                              ),
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: context.spacing.xs),
                                      IconText(
                                        XIcon(
                                          AppIcon.location,
                                          color: context.colors.primary,
                                          size: 16,
                                        ),
                                        location,
                                        color:
                                            context.colors.onPrimaryContainer,
                                      ),
                                      SizedBox(height: context.spacing.xs),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: IconText(
                                              XIcon(
                                                AppIcon.salary,
                                                color: context.colors.primary,
                                                size: 16,
                                              ),
                                              salaryText,
                                              color: context
                                                  .colors
                                                  .onPrimaryContainer,
                                            ),
                                          ),
                                          if (vacancyText != null) ...[
                                            SizedBox(width: context.spacing.xs),
                                            IconText(
                                              XIcon(
                                                AppIcon.vacancy,
                                                color: context.colors.primary,
                                                size: 16,
                                              ),
                                              vacancyText,
                                              color: context
                                                  .colors
                                                  .onPrimaryContainer,
                                            ),
                                          ],
                                        ],
                                      ),
                                      SizedBox(height: context.spacing.xs),
                                      Text(
                                        _postedOnText(detail.createdAt),
                                        style: context.text.bodySmall!.copyWith(
                                          color:
                                              context.colors.onPrimaryContainer,
                                        ),
                                      ),

                                      if (hasInterest) ...[
                                        SizedBox(height: context.spacing.sm),
                                        cardContainer(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        interestTitle,
                                                        style: context
                                                            .text
                                                            .titleMedium!
                                                            .copyWith(
                                                              color: context
                                                                  .colors
                                                                  .primary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ),
                                                      if (interestAtLabel !=
                                                          null) ...[
                                                        SizedBox(
                                                          height: context
                                                              .spacing
                                                              .xs,
                                                        ),
                                                        Text(
                                                          interestAtLabel,
                                                          style: context
                                                              .text
                                                              .bodySmall!
                                                              .copyWith(
                                                                color: context
                                                                    .colors
                                                                    .onPrimaryContainer,
                                                              ),
                                                        ),
                                                      ],
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      Container(
                                                        padding:
                                                            EdgeInsets.symmetric(
                                                              horizontal:
                                                                  context
                                                                      .spacing
                                                                      .md,
                                                              vertical: context
                                                                  .spacing
                                                                  .sm,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color:
                                                              statusBackground,
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                context
                                                                    .radii
                                                                    .sm,
                                                              ),
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            XIcon(
                                                              statusIcon,
                                                              color:
                                                                  statusForeground,
                                                              size: 16,
                                                            ),
                                                            SizedBox(
                                                              width: context
                                                                  .spacing
                                                                  .xs,
                                                            ),
                                                            Text(
                                                              statusLabel,
                                                              style: context
                                                                  .text
                                                                  .bodySmall!
                                                                  .copyWith(
                                                                    color:
                                                                        statusForeground,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              if (!isOtpUnlocked &&
                                                  !isRejectedInterest) ...[
                                                SizedBox(
                                                  height: context.spacing.md,
                                                ),
                                                SizedBox(
                                                  width: double.infinity,
                                                  height: 44,
                                                  child: ElevatedButton(
                                                    onPressed:
                                                        (!hasIds ||
                                                            provider
                                                                .isActionLoading)
                                                        ? null
                                                        : () =>
                                                              openMatchOtpSheet(),
                                                    child: Text(
                                                      'job_details.hire'.tr(),
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: context.spacing.xs,
                                                ),
                                                Center(
                                                  child: Text(
                                                    'job_details.free_gifts_after_hiring'
                                                        .tr(),
                                                    style: context
                                                        .text
                                                        .bodySmall!
                                                        .copyWith(
                                                          color: context
                                                              .colors
                                                              .secondary,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ],
                                              if (isOtpUnlocked &&
                                                  !isRejectedInterest) ...[
                                                SizedBox(
                                                  height: context.spacing.md,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Text(
                                                      'job_details.matching_otp'
                                                          .tr(),
                                                      style: context
                                                          .text
                                                          .bodyMedium!
                                                          .copyWith(
                                                            color: context
                                                                .colors
                                                                .secondary,
                                                          ),
                                                    ),
                                                    OtpCard(
                                                      otp.isNotEmpty
                                                          ? otp
                                                          : '----',
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],

                                      SizedBox(height: context.spacing.lg),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'job_details.about_job'.tr(),
                                                style: context.text.titleMedium!
                                                    .copyWith(
                                                      color: context
                                                          .colors
                                                          .primary,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                              if (designation.isNotEmpty) ...[
                                                SizedBox(
                                                  height:
                                                      context.spacing.xxs,
                                                ),
                                                Text(
                                                  designation,
                                                  style: context
                                                      .text
                                                      .bodyMedium!
                                                      .copyWith(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                      ),
                                                ),
                                              ],
                                            ],
                                          ),
                                          if (showOrganizationType)
                                            Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: context.spacing.md,
                                                vertical: context.spacing.xs,
                                              ),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      context.radii.lg,
                                                    ),
                                                border: Border.all(
                                                  color:
                                                      context.colors.secondary,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  XIcon(
                                                    AppIcon.company,
                                                    color: context
                                                        .colors
                                                        .secondary,
                                                  ),
                                                  SizedBox(
                                                    width: context.spacing.xs,
                                                  ),
                                                  Text(
                                                    businessCategory,
                                                    style: context
                                                        .text
                                                        .bodySmall!
                                                        .copyWith(
                                                          color: context
                                                              .colors
                                                              .secondary,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: context.spacing.xs),
                                      Text(
                                        (detail.descriptionEnglish ?? '')
                                                .trim()
                                                .isNotEmpty
                                            ? detail.descriptionEnglish!.trim()
                                            : 'job_details.description_not_available'
                                                  .tr(),
                                        style: context.text.bodyMedium!
                                            .copyWith(
                                              color: context
                                                  .colors
                                                  .onPrimaryContainer,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  color: context.colors.background,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: context.spacing.lg,
                                    vertical: context.spacing.sm,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (workTimeRange != null ||
                                          jobDaysText.trim().isNotEmpty ||
                                          detail.shifts.isNotEmpty) ...[
                                        SizedBox(height: context.spacing.xl),
                                        sectionTitle(
                                          AppIcon.time,
                                          'job_details.work_time_job_type'.tr(),
                                        ),
                                        SizedBox(height: context.spacing.sm),
                                        Wrap(
                                          spacing: context.spacing.sm,
                                          runSpacing: context.spacing.sm,
                                          children: [
                                            if (workTimeRange != null)
                                              InfoChip(
                                                'job_details.shift'.tr(
                                                  args: [workTimeRange],
                                                ),
                                              ),
                                            if (jobDaysText.trim().isNotEmpty)
                                              InfoChip(jobDaysText),
                                            ..._chips(detail.shifts),
                                          ],
                                        ),
                                      ],

                                      if (detail.qualifications.isNotEmpty ||
                                          detail.experiences.isNotEmpty ||
                                          detail.genders.isNotEmpty) ...[
                                        SizedBox(height: context.spacing.xl),
                                        sectionTitle(
                                          AppIcon.jobFor,
                                          'job_details.who_can_apply'.tr(),
                                        ),
                                        SizedBox(height: context.spacing.sm),
                                        Wrap(
                                          spacing: context.spacing.sm,
                                          runSpacing: context.spacing.sm,
                                          children: _buildWhoCanApplyChips(
                                            detail,
                                          ),
                                        ),
                                      ],

                                      if (detail.skills.isNotEmpty) ...[
                                        SizedBox(height: context.spacing.xl),
                                        sectionTitle(
                                          AppIcon.jobInfo,
                                          'job_details.skills'.tr(),
                                        ),
                                        SizedBox(height: context.spacing.sm),
                                        Wrap(
                                          spacing: context.spacing.sm,
                                          runSpacing: context.spacing.sm,
                                          children: _chips(detail.skills),
                                        ),
                                      ],

                                      if (detail.benefits.isNotEmpty ||
                                          (detail.otherBenefitEnglish ?? '')
                                              .trim()
                                              .isNotEmpty) ...[
                                        SizedBox(height: context.spacing.xl),
                                        sectionTitle(
                                          AppIcon.incentives,
                                          'job_details.incentives'.tr(),
                                        ),
                                        SizedBox(height: context.spacing.sm),
                                        if (detail.benefits.isNotEmpty)
                                          Wrap(
                                            spacing: context.spacing.sm,
                                            runSpacing: context.spacing.sm,
                                            children: _chips(detail.benefits),
                                          )
                                        else
                                          Text(
                                            detail.otherBenefitEnglish!.trim(),
                                            style: context.text.bodyMedium!
                                                .copyWith(
                                                  color: context
                                                      .colors
                                                      .onPrimaryContainer,
                                                ),
                                          ),
                                      ],

                                      SizedBox(height: context.spacing.xl),
                                      if (isContactUnlocked)
                                        cardContainer(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'history.contact_details'.tr(),
                                                style: context.text.titleMedium!
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: context
                                                          .colors
                                                          .onPrimaryContainer,
                                                    ),
                                              ),
                                              if (contactUnlockedLabel !=
                                                  null) ...[
                                                SizedBox(
                                                  height: context.spacing.xs,
                                                ),
                                                Text(
                                                  contactUnlockedLabel,
                                                  style: context.text.bodySmall!
                                                      .copyWith(
                                                        color: context
                                                            .colors
                                                            .onPrimaryContainer,
                                                      ),
                                                ),
                                              ],
                                              SizedBox(
                                                height: context.spacing.xs,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      XIcon(
                                                        AppIcon.callFilled,
                                                        color: context
                                                            .colors
                                                            .primary,
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            context.spacing.sm,
                                                      ),
                                                      Text(
                                                        employerPhone.isNotEmpty
                                                            ? employerPhone
                                                            : '-',
                                                        style: context
                                                            .text
                                                            .bodyMedium!
                                                            .copyWith(
                                                              color: context
                                                                  .colors
                                                                  .primary,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                  if (employerPhone.isNotEmpty)
                                                    TextButton(
                                                      onPressed: () => _launchDialer(
                                                        context,
                                                        employerPhone,
                                                        shouldOpenCallExperience:
                                                            !detail
                                                                .isCallExperienceShared,
                                                      ),
                                                      child: Text(
                                                        'candidates.detail.call_now'
                                                            .tr(),
                                                        style: context
                                                            .text
                                                            .bodyMedium!
                                                            .copyWith(
                                                              color: context
                                                                  .colors
                                                                  .secondary,
                                                            ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: context.spacing.xs,
                                              ),
                                              Text(
                                                'job_details.calling_hours'
                                                    .tr(),
                                                style: context.text.bodySmall!
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: context
                                                          .colors
                                                          .onPrimaryContainer,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        )
                                      else
                                        SizedBox(),
                                      SizedBox(height: context.spacing.lg),
                                      if (isContactUnlocked)
                                        cardContainer(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'job_details.address_details'
                                                    .tr(),
                                                style: context.text.titleMedium!
                                                    .copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: context
                                                          .colors
                                                          .onPrimaryContainer,
                                                    ),
                                              ),
                                              if (contactUnlockedLabel !=
                                                  null) ...[
                                                SizedBox(
                                                  height: context.spacing.xs,
                                                ),
                                                Text(
                                                  contactUnlockedLabel,
                                                  style: context.text.bodySmall!
                                                      .copyWith(
                                                        color: context
                                                            .colors
                                                            .onPrimaryContainer,
                                                      ),
                                                ),
                                              ],
                                              SizedBox(
                                                height: context.spacing.sm,
                                              ),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      _composeAddress(
                                                            detail.organizationName ??
                                                                detail.employerName,
                                                            detail.jobAddress,
                                                            detail.jobCity,
                                                            detail.jobState,
                                                          ) ??
                                                          '-',
                                                      style: context.text.bodyMedium!
                                                          .copyWith(
                                                            color: context.colors.primary,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                    ),
                                                  ),
                                                  if (detail.lat != null && detail.lng != null) ...[
                                                    SizedBox(width: context.spacing.sm),
                                                    GestureDetector(
                                                      onTap: () async {
                                                        final uri = Uri.parse(
                                                          'https://www.google.com/maps/search/?api=1&query=${detail.lat},${detail.lng}',
                                                        );
                                                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                                                      },
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          XIcon(
                                                            AppIcon.location,
                                                            size: 22,
                                                            color: context.colors.secondary,
                                                          ),
                                                          Text(
                                                            'job_details.directions'.tr(),
                                                            style: context.text.labelSmall?.copyWith(
                                                              color: context.colors.secondary,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      SizedBox(
                                        height: context.spacing.xxxl * 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),

                  Container(
                    color: context.colors.onPrimary,
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spacing.md,
                      vertical: context.spacing.sm,
                    ),
                    child: Row(
                      children: [
                        if (hasIds && !isContactUnlocked)
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: context.colors.primary,
                                side: BorderSide(color: context.colors.primary),
                              ),
                              onPressed: (!hasIds || provider.isActionLoading)
                                  ? null
                                  : () {
                                      _handleGetContact(
                                        context,
                                        provider,
                                        jobId,
                                        employeeId,
                                      );
                                    },
                              child: Text('candidates.detail.get_contact'.tr()),
                            ),
                          ),

                        if (hasIds && !isContactUnlocked && !hasInterest)
                          SizedBox(width: 10),
                        if (hasIds && !hasInterest)
                          Expanded(
                            child: ElevatedButton(
                              onPressed: provider.isActionLoading
                                  ? null
                                  : () => _handleSendInterest(
                                      context,
                                      provider,
                                      jobId,
                                      employeeId,
                                    ),
                              child: Text(
                                'candidates.detail.send_interest'.tr(),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
