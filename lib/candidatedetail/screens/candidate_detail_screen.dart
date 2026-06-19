import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:rotijugaad/network/api_client.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/widgets/toolbar.dart';
import '../../common/widgets/app_button_child.dart';
import '../../common/widgets/employee_identity_badges.dart';
import '../../common/widgets/app_shimmer_placeholders.dart';
import '../../common/widgets/xicon.dart';
import '../../jobdetails/dialogs/dial_dialog.dart';
import '../../jobdetails/dialogs/get_contact_dialog.dart';
import '../../jobdetails/dialogs/no_credits_dialog.dart';
import '../../profile/utils/employer_profile_action_guard.dart';
import '../../subscriptions/dialogs/no_subscription_dialog.dart';
import '../../subscriptions/dialogs/subscription_ended_dialog.dart';
import '../../theme/app_icons.dart';
import '../../theme/context_ext.dart';
import '../../utils/shared_pref.dart';
import '../providers/candidate_detail_provider.dart';
import '../sheets/report_candidate_sheet.dart';
import 'candidate_about_screen.dart';
import 'candidate_experience_screen.dart';
import 'candidate_preference_screen.dart';
import 'employer_call_experience_screen.dart';
import 'send_interest_jobs_screen.dart';

class CandidateDetailScreen extends StatefulWidget {
  final int candidateId;

  const CandidateDetailScreen({super.key, required this.candidateId});

  @override
  State<CandidateDetailScreen> createState() => _CandidateDetailScreenState();
}

class _CandidateDetailScreenState extends State<CandidateDetailScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final TabController _tabController;
  late final CandidateDetailProvider _provider;

  bool _openCallExperienceOnResume = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tabController = TabController(length: 3, vsync: this);
    _provider = CandidateDetailProvider(candidateId: widget.candidateId)
      ..ensureLoaded();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    if (!_openCallExperienceOnResume) return;
    if (!mounted) return;

    _openCallExperienceOnResume = false;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) =>
              EmployerCallExperienceScreen(candidateId: widget.candidateId),
        ),
      ).then((shared) {
        if (shared == true && mounted) {
          _provider.load();
        }
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    _provider.dispose();
    super.dispose();
  }

  void _showSnack(BuildContext context, String message) {
    final t = message.trim();
    if (t.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  Map<String, dynamic>? _authProfileJson() {
    return SharedPrefUtils.readJson(SharedPrefUtils.AUTH_PROFILE_JSON);
  }

  Map<String, dynamic>? _authUserJson() {
    return SharedPrefUtils.readJson(SharedPrefUtils.AUTH_USER_JSON);
  }

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

    return pick(_authProfileJson()) ?? pick(_authUserJson()) ?? 'Dost';
  }

  String _candidateShareMessage(BuildContext context, String link) {
    final ownerName = _shareOwnerName(context);
    return [
      '$ownerName ne ek candidate profile share ki hai.',
      'Agar aap interested ho to yahan details check karo:',
      link,
    ].join('\n');
  }

  int _asInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    if (v is num) return v.toInt();

    final s = (v ?? "").toString().trim();
    if (s.isEmpty) return fallback;

    final i = int.tryParse(s);
    if (i != null) return i;

    final d = double.tryParse(s);
    return d?.toInt() ?? fallback;
  }

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

  Future<bool> _ensureActiveSubscription(BuildContext context) async {
    final profile = _authProfileJson();
    final raw =
        (profile?['subscription_status'] ?? profile?['subscriptionStatus'])
            ?.toString();
    if (raw == null || raw.trim().isEmpty) {
      return true;
    }

    final s = raw.trim().toLowerCase();
    if (s == 'active') return true;

    final Widget dialog = (s == 'ended' || s == 'expired')
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

  Future<void> _launchDialer(
    BuildContext context,
    String phone, {
    required bool shouldOpenCallExperience,
  }) async {
    final p = phone.trim();
    if (p.isEmpty) {
      _showSnack(context, 'support.phone_unavailable'.tr());
      return;
    }

    final uri = Uri(scheme: 'tel', path: p);

    try {
      _openCallExperienceOnResume = shouldOpenCallExperience;
      final ok = await launchUrl(uri);
      if (!ok) {
        _openCallExperienceOnResume = false;
        _showSnack(context, 'support.could_not_open_dialer'.tr());
      }
    } catch (_) {
      _openCallExperienceOnResume = false;
      _showSnack(context, 'support.could_not_open_dialer'.tr());
    }
  }

  Future<void> _handleGetContact(
    BuildContext context,
    CandidateDetailProvider provider,
  ) async {
    final detail = provider.detail;
    if (detail == null) return;
    if (provider.isContactUnlocked) return;

    final canProceed = await EmployerProfileActionGuard.ensureAllowed(context);
    if (!canProceed) return;

    final okSub = await _ensureActiveSubscription(context);
    if (!okSub) return;

    final profile = _authProfileJson();
    final credits = profile?['credits'];
    final contactCredits = (credits is Map) ? credits['contact'] : null;
    final available = _asInt(
      profile?['contact_credit'] ??
          (contactCredits is Map ? contactCredits['available'] : null),
    );
    final total = _asInt(
      profile?['total_contact_credit'] ??
          (contactCredits is Map ? contactCredits['total'] : null),
    );

    if (available <= 0) {
      await _showNoCredits(
        context,
        title: 'candidates.detail.no_contact_credits'.tr(),
        message: 'candidates.detail.contact_credits_remaining'.tr(
          args: ['0', '$total'],
        ),
      );
      return;
    }

    final confirmed =
        await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (_) => GetContactDialog(available: available, total: total),
        ) ??
        false;

    if (!confirmed) return;

    final ok = await provider.unlockContact();
    if (!context.mounted) return;

    if (!ok) {
      _showSnack(
        context,
        provider.unlockError?.message ??
            'candidates.detail.failed_unlock_contact'.tr(),
      );
      return;
    }

    if (profile != null) {
      final next = Map<String, dynamic>.from(profile);

      final credits = next['credits'];
      final contactCredits = (credits is Map) ? credits['contact'] : null;

      final remaining = _asInt(
        next['contact_credit'] ??
            (contactCredits is Map ? contactCredits['available'] : null),
      );
      final updated = (remaining - 1).clamp(0, remaining);

      next['contact_credit'] = updated;
      if (credits is Map && contactCredits is Map) {
        final nextCredits = Map<String, dynamic>.from(credits);
        final nextContact = Map<String, dynamic>.from(contactCredits);
        nextContact['available'] = updated;
        nextCredits['contact'] = nextContact;
        next['credits'] = nextCredits;
      }

      await SharedPrefUtils.saveJson(SharedPrefUtils.AUTH_PROFILE_JSON, next);
    }

    final refreshed = provider.detail;
    final phone = (refreshed?.employee.mobile ?? '').trim();
    final emp = refreshed?.employee;

    final cityPart = (emp?.currentCityEnglish ?? emp?.currentCity ?? '').trim();
    final statePart = (emp?.currentStateEnglish ?? emp?.currentState ?? '').trim();
    final address = [cityPart, statePart].where((s) => s.isNotEmpty).join(', ');

    final shouldDial =
        await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (_) => DialDialog(
            phone: phone,
            address: address.isNotEmpty ? address : null,
            lat: emp?.lat,
            lng: emp?.lng,
          ),
        ) ??
        false;

    if (shouldDial) {
      final alreadyShared = refreshed?.contact.isCallExperienceShared ?? false;
      await _launchDialer(
        context,
        phone,
        shouldOpenCallExperience: !alreadyShared,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<CandidateDetailProvider>(
        builder: (context, provider, _) {
          final detail = provider.detail;

          if (detail == null) {
            final message =
                provider.error?.message ??
                (provider.isLoading
                    ? 'candidates.detail.loading'.tr()
                    : 'candidates.detail.failed_load'.tr());

            return Scaffold(
              backgroundColor: context.colors.onPrimary,
              body: SafeArea(
                child: Column(
                  children: [
                    Toolbar('candidates.detail.title'.tr(), () {
                      Navigator.of(context).pop();
                    }),
                    Divider(color: context.xcolors.stroke, height: 1),
                    Expanded(
                      child: provider.isLoading
                          ? const AppFormShimmer()
                          : Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(message, style: context.text.bodyMedium),
                                  SizedBox(height: context.spacing.md),
                                  ElevatedButton(
                                    onPressed: provider.load,
                                    child: Text('common.retry'.tr()),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          }

          final employee = detail.employee;
          final isHindi = context.locale.languageCode.toLowerCase() == 'hi';
          final rawName =
              ((isHindi ? employee.nameHindi : employee.nameEnglish) ??
                      employee.name ??
                      '')
                  .trim();
          final name = rawName.isEmpty
              ? 'candidates.detail.fallback_name'.tr(
                  args: ['${widget.candidateId}'],
                )
              : rawName;

          final kyc = (employee.kycStatus ?? '').trim().toLowerCase();
          final isKycVerified = kyc == 'verified';
          final selfieUrl = _resolveProfileImageUrl(employee.selfieLink);

          final isContactUnlocked = provider.isContactUnlocked;

          return Scaffold(
            backgroundColor: context.colors.onPrimary,
            body: SafeArea(
              child: DefaultTabController(
                length: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Toolbar('candidates.detail.title'.tr(), () {
                            Navigator.of(context).pop();
                          }),
                        ),
                        IconButton(
                          onPressed: () {
                            final slug = detail.employee.slug;
                            final s = (slug ?? '').trim();
                            if (s.isEmpty) {
                              _showSnack(context, 'Link not available.');
                              return;
                            }

                            final base = ApiClient.baseUrl.endsWith('/')
                                ? ApiClient.baseUrl.substring(
                                    0,
                                    ApiClient.baseUrl.length - 1,
                                  )
                                : ApiClient.baseUrl;
                            final link =
                                '$base/app/candidates/${Uri.encodeComponent(s)}';
                            Share.share(_candidateShareMessage(context, link));
                          },
                          icon: XIcon(AppIcon.shareJob),
                        ),
                        IconButton(
                          onPressed: () {
                            showModalBottomSheet<bool>(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              builder: (context) => ReportCandidateSheet(
                                candidateId: widget.candidateId,
                                alreadyReported: detail.report.isReported,
                                reportedAt: detail.report.reportedAt,
                              ),
                            ).then((reported) {
                              if (reported == true && context.mounted) {
                                provider.load();
                              }
                            });
                          },
                          icon: XIcon(AppIcon.jobInfo),
                        ),
                      ],
                    ),
                    Divider(color: context.xcolors.stroke, height: 1),
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: context.spacing.md,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: context.spacing.md),
                          ClipOval(
                            child: selfieUrl != null
                                ? Image.network(
                                    selfieUrl,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Image.asset(
                                      'assets/images/profile_placeholder.png',
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Image.asset(
                                    'assets/images/profile_placeholder.png',
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                          SizedBox(height: context.spacing.sm),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  name,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.text.bodyMedium,
                                ),
                              ),
                              if (isKycVerified) ...[
                                SizedBox(width: context.spacing.xs),
                                const KycVerifiedBadgeIcon(size: 20),
                              ],
                              SizedBox(width: context.spacing.xs),
                              EmployeeGenderIcon(
                                gender: employee.gender,
                                size: 18,
                              ),
                            ],
                          ),
                          SizedBox(height: context.spacing.sm),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: provider.isShortlistLoading
                                  ? null
                                  : () async {
                                      final canProceed =
                                          await EmployerProfileActionGuard.ensureAllowed(
                                            context,
                                          );
                                      if (!canProceed) return;

                                      final ok = await provider
                                          .toggleShortlist();

                                      if (!context.mounted) return;
                                      if (!ok) {
                                        _showSnack(
                                          context,
                                          provider.shortlistError?.message ??
                                              'candidates.shortlist.failed'
                                                  .tr(),
                                        );
                                        return;
                                      }

                                      _showSnack(
                                        context,
                                        provider.isShortlisted
                                            ? 'candidates.shortlist.added'.tr()
                                            : 'candidates.shortlist.removed'
                                                  .tr(),
                                      );
                                    },
                              icon: provider.isShortlistLoading
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: context.colors.primary,
                                      ),
                                    )
                                  : XIcon(
                                      provider.isShortlisted
                                          ? AppIcon.shortlisted
                                          : AppIcon.shortlist,
                                      color: context.colors.primary,
                                      size: 18,
                                    ),
                              label: Text(
                                provider.isShortlisted
                                    ? 'candidates.detail.unshortlist'.tr()
                                    : 'candidates.detail.shortlist'.tr(),
                              ),
                            ),
                          ),
                          SizedBox(height: context.spacing.xs),
                          TabBar(
                            controller: _tabController,
                            labelColor: context.colors.onBackground,
                            labelStyle: context.text.bodyMedium!.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            unselectedLabelStyle: context.text.bodyMedium!
                                .copyWith(fontWeight: FontWeight.w500),
                            unselectedLabelColor: context.colors.onSurface,
                            dividerColor: context.xcolors.stroke,
                            indicatorColor: context.colors.primary,
                            indicatorWeight: 2,
                            tabs: [
                              Tab(text: 'candidates.detail.tabs.about'.tr()),
                              Tab(
                                text: 'candidates.detail.tabs.experience'.tr(),
                              ),
                              Tab(
                                text: 'candidates.detail.tabs.preferences'.tr(),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: context.spacing.xs,
                        ),
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            CandidateAboutScreen(
                              employee: employee,
                              isContactUnlocked: isContactUnlocked,
                              onCallNow: (phone) {
                                final alreadyShared =
                                    detail.contact.isCallExperienceShared;
                                _launchDialer(
                                  context,
                                  phone,
                                  shouldOpenCallExperience: !alreadyShared,
                                );
                              },
                            ),
                            CandidateExperienceScreen(
                              experiences: detail.experiences,
                            ),
                            CandidatePreferenceScreen(
                              jobProfiles: detail.jobProfiles,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Divider(color: context.xcolors.stroke, height: 1),
                    Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: context.spacing.md,
                        vertical: context.spacing.md,
                      ),
                      child: Row(
                        children: [
                          if (!isContactUnlocked)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: provider.isUnlockingContact
                                    ? null
                                    : () =>
                                          _handleGetContact(context, provider),
                                child: AppButtonChild(
                                  label: 'candidates.detail.get_contact'.tr(),
                                  isLoading: provider.isUnlockingContact,
                                  textStyle: context.text.labelLarge?.copyWith(
                                    color: context.colors.primary,
                                  ),
                                  loaderColor: context.colors.primary,
                                ),
                              ),
                            ),
                          if (!isContactUnlocked)
                            SizedBox(width: context.spacing.md),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final canProceed =
                                    await EmployerProfileActionGuard.ensureAllowed(
                                      context,
                                    );
                                if (!canProceed || !context.mounted) return;

                                final ok = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SendInterestJobsScreen(
                                      candidateId: widget.candidateId,
                                    ),
                                  ),
                                );

                                if (!context.mounted) return;
                                if (ok == true) {
                                  provider.load();
                                  return;
                                }
                              },
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
            ),
          );
        },
      ),
    );
  }
}
