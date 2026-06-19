import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:rotijugaad/candidatedetail/widgets/send_interest_job_item.dart';
import 'package:rotijugaad/common/widgets/toolbar.dart';
import 'package:rotijugaad/common/widgets/app_button_child.dart';
import 'package:rotijugaad/common/widgets/app_shimmer_placeholders.dart';
import 'package:rotijugaad/theme/context_ext.dart';

import '../../common/dialogs/primary_dialog.dart';
import '../../employers/services/employers_service.dart';
import '../../jobdetails/dialogs/interest_sent_dialog.dart';
import '../../jobdetails/dialogs/no_credits_dialog.dart';
import '../../jobdetails/dialogs/send_interest_dialog.dart';
import '../../subscriptions/dialogs/no_subscription_dialog.dart';
import '../../subscriptions/dialogs/subscription_ended_dialog.dart';
import '../../utils/custom_exception.dart';
import '../../utils/i18n_terms.dart';
import '../../utils/job_text_utils.dart';
import '../../utils/result.dart';
import '../../utils/shared_pref.dart';
import '../models/send_interest_jobs_models.dart';

enum CandidateActionMode { sendInterest, shortlist }

class SendInterestJobsScreen extends StatefulWidget {
  final int candidateId;
  final CandidateActionMode mode;

  const SendInterestJobsScreen({
    super.key,
    required this.candidateId,
    this.mode = CandidateActionMode.sendInterest,
  });

  bool get isShortlist => mode == CandidateActionMode.shortlist;

  @override
  State<StatefulWidget> createState() => _SendInterestJobsScreenState();
}

class _SendInterestJobsScreenState extends State<SendInterestJobsScreen> {
  final EmployersService _service = EmployersService();

  bool _isLoading = false;
  CustomException? _error;

  EmployerSendInterestJobsResponse? _page;

  final Set<int> _selectedJobIds = <int>{};
  bool _isSubmitting = false;

  String get _screenTitle => widget.isShortlist
      ? 'candidates.detail.shortlist'.tr()
      : 'candidates.send_interest.select_job_title'.tr();

  String get _listIntroText => widget.isShortlist
      ? 'candidates.detail.shortlist'.tr()
      : 'candidates.send_interest.select_job_subtitle'.tr();

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _showSnack(String message) {
    final m = message.trim();
    if (m.isEmpty) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Map<String, dynamic>? _authProfileJson() {
    return SharedPrefUtils.readJson(SharedPrefUtils.AUTH_PROFILE_JSON);
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

  bool _shouldRefreshAfterInterestFailure(String? message) {
    final text = (message ?? '').trim().toLowerCase();
    return text == 'interest already sent for this job' ||
        text == 'interest already received for this job';
  }

  Future<bool> _ensureActiveSubscription() async {
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

  Future<void> _showNoCredits({
    required String title,
    required String message,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => NoCreditsDialog(title: title, message: message),
    );
  }

  Future<void> _load() async {
    final employerId = SharedPrefUtils.readInt('auth_employer_id');
    if (employerId <= 0) {
      setState(() {
        _error = CustomException(
          code: 'NO_EMPLOYER',
          message: 'candidates.send_interest.no_employer_id'.tr(),
        );
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final Result<EmployerSendInterestJobsResponse, CustomException> result =
        widget.isShortlist
        ? await _service.getEmployerJobsForShortlisting(
            employerId,
            widget.candidateId,
            page: 1,
            limit: 50,
          )
        : await _service.getEmployerJobsForSendingInterest(
            employerId,
            widget.candidateId,
            page: 1,
            limit: 50,
          );

    if (!mounted) return;

    switch (result) {
      case Success(value: final value):
        setState(() {
          _page = value;
        });
        break;
      case Failure(exception: final e):
        setState(() {
          _error = e;
        });
        break;
    }

    setState(() {
      _isLoading = false;
    });
  }

  String? _joinLocation(String? city, String? state) {
    final parts = <String>[];
    final c = (city ?? '').trim();
    final s = (state ?? '').trim();
    if (c.isNotEmpty) parts.add(c);
    if (s.isNotEmpty) parts.add(s);
    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  String _salaryText(int? min, int? max, String? type) {
    final t = (type ?? '').trim();
    final localizedType = t.isEmpty ? '' : I18nTerms.fromRaw(context, t);

    String? range;
    if (min != null && max != null) {
      range = '₹$min - ₹$max';
    } else if (min != null) {
      range = 'common.from'.tr(args: ['₹$min']);
    } else if (max != null) {
      range = 'common.up_to'.tr(args: ['₹$max']);
    }

    if (range == null) {
      return localizedType.isEmpty
          ? 'common.salary_not_specified'.tr()
          : localizedType;
    }

    if (localizedType.isEmpty) return range;

    final lower = localizedType.toLowerCase();
    if (lower.startsWith('per ')) {
      return '$range $localizedType';
    }
    if (localizedType.startsWith('/')) {
      return range + localizedType;
    }
    return '$range/$localizedType';
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final selected = _selectedJobIds.toList();
    if (selected.isEmpty) {
      _showSnack('candidates.send_interest.select_at_least_one_job'.tr());
      return;
    }

    final okSub = await _ensureActiveSubscription();
    if (!okSub) return;

    final employerId = SharedPrefUtils.readInt('auth_employer_id');
    if (employerId <= 0) {
      _showSnack('candidates.send_interest.no_employer_id'.tr());
      return;
    }

    final profile = _authProfileJson();

    if (!widget.isShortlist) {
      final credits = profile?['credits'];
      final interestCredits = (credits is Map) ? credits['interest'] : null;
      final available = _asInt(
        profile?['interest_credit'] ??
            (interestCredits is Map ? interestCredits['available'] : null),
      );
      final total = _asInt(
        profile?['total_interest_credit'] ??
            (interestCredits is Map ? interestCredits['total'] : null),
      );

      final requiredCredits = selected.length;

      if (available < requiredCredits) {
        await _showNoCredits(
          title: 'candidates.send_interest.no_interest_credits'.tr(),
          message: 'candidates.send_interest.credits_needed_message'.tr(
            args: [
              '$requiredCredits',
              requiredCredits > 1 ? 's' : '',
              '${selected.length}',
              selected.length > 1 ? 's' : '',
              '$available',
              '$total',
            ],
          ),
        );
        return;
      }

      final confirmed =
          await showDialog<bool>(
            context: context,
            barrierDismissible: true,
            builder: (_) => SendInterestDialog(
              available: available,
              total: total,
              cost: requiredCredits,
            ),
          ) ??
          false;

      if (!confirmed) return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final result = widget.isShortlist
        ? await _service.shortlistCandidateForJobs(
            employerId: employerId,
            candidateId: widget.candidateId,
            jobIds: selected,
          )
        : await _service.sendInterestToCandidateForJobs(
            employerId: employerId,
            candidateId: widget.candidateId,
            jobIds: selected,
          );

    if (!mounted) return;

    var createdCount = 0;

    switch (result) {
      case Success(value: final payload):
        final data = payload['results'] ?? payload['data']?['results'];
        final list = data is List ? data : const [];
        for (final item in list) {
          if (item is Map) {
            final action = (item['action'] ?? '').toString().toLowerCase();
            if (action == 'created') createdCount += 1;
          }
        }

        if (!widget.isShortlist && createdCount > 0 && profile != null) {
          final next = Map<String, dynamic>.from(profile);

          final credits = next['credits'];
          final interestCredits = (credits is Map) ? credits['interest'] : null;

          final remaining = _asInt(
            next['interest_credit'] ??
                (interestCredits is Map ? interestCredits['available'] : null),
          );
          final updated = (remaining - createdCount).clamp(0, remaining);

          next['interest_credit'] = updated;
          if (credits is Map && interestCredits is Map) {
            final nextCredits = Map<String, dynamic>.from(credits);
            final nextInterest = Map<String, dynamic>.from(interestCredits);
            nextInterest['available'] = updated;
            nextCredits['interest'] = nextInterest;
            next['credits'] = nextCredits;
          }

          await SharedPrefUtils.saveJson(
            SharedPrefUtils.AUTH_PROFILE_JSON,
            next,
          );
        }

        if (widget.isShortlist) {
          await showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (_) => PrimaryDialog(
              'candidates.send_interest.shortlisted_success'.tr(),
            ),
          );
        } else {
          await showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (_) => InterestSentDialog(),
          );
        }

        if (!mounted) return;
        Navigator.of(context).pop(true);
        break;
      case Failure(exception: final e):
        if (!widget.isShortlist &&
            _shouldRefreshAfterInterestFailure(e.message)) {
          await showDialog<void>(
            context: context,
            barrierDismissible: true,
            builder: (_) => PrimaryDialog(e.message),
          );

          if (!mounted) return;
          Navigator.of(context).pop(true);
          break;
        }

        _showSnack(e.message);
        break;
    }

    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isHindi = context.locale.languageCode.toLowerCase() == 'hi';
    final results = _page?.results ?? const <EmployerSendInterestJobDto>[];

    return Scaffold(
      backgroundColor: context.colors.onPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Toolbar(_screenTitle, () {
                    Navigator.of(context).pop();
                  }),
                ),
              ],
            ),
            Divider(color: context.xcolors.stroke, height: 1),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: context.spacing.md),
                child: _isLoading
                    ? const AppListShimmer(padding: EdgeInsets.only(top: 12))
                    : (_error != null)
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _error?.message ??
                                  'candidates.send_interest.failed_load_jobs'
                                      .tr(),
                              style: context.text.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: context.spacing.md),
                            ElevatedButton(
                              onPressed: _load,
                              child: Text('common.retry'.tr()),
                            ),
                          ],
                        ),
                      )
                    : (results.isEmpty)
                    ? Center(
                        child: Text(
                          'candidates.send_interest.no_active_jobs_found'.tr(),
                          style: context.text.bodyMedium,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                              top: context.spacing.md,
                              bottom: context.spacing.sm,
                            ),
                            child: Text(
                              _listIntroText,
                              style: context.text.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: results.length,
                              itemBuilder: (context, index) {
                                final item = results[index];
                                final job = item.job;

                                final enabled = item.canSendInterest;
                                final selected = _selectedJobIds.contains(
                                  job.id,
                                );

                                final title =
                                    ((isHindi
                                                ? item.jobProfileHindi
                                                : item.jobProfileEnglish) ??
                                            job.jobProfile)
                                        ?.trim();

                                final org =
                                    ((isHindi
                                                ? item.organizationNameHindi
                                                : item.organizationNameEnglish) ??
                                            item.organizationName ??
                                            job.organizationName)
                                        ?.trim();

                                final loc = _joinLocation(
                                  job.jobCity,
                                  job.jobState,
                                );

                                final salary = _salaryText(
                                  job.salaryMin,
                                  job.salaryMax,
                                  job.salaryType,
                                );

                                final vac = (job.noVacancy != null)
                                    ? formatVacancyCountText(job.noVacancy)
                                    : '';

                                final shift = (job.shiftTimingDisplay ?? '')
                                    .trim();

                                return SendInterestJobItem(
                                  selected: selected,
                                  enabled: enabled,
                                  onChanged: (checked) {
                                    final next = checked == true;
                                    setState(() {
                                      if (next) {
                                        _selectedJobIds.add(job.id);
                                      } else {
                                        _selectedJobIds.remove(job.id);
                                      }
                                    });
                                  },
                                  title: (title?.isNotEmpty ?? false)
                                      ? title!
                                      : '-',
                                  organizationName: org,
                                  location: loc,
                                  shift: shift,
                                  salary: salary,
                                  vacancy: vac,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            Divider(color: context.xcolors.stroke, height: 1),
            Container(
              width: double.infinity,
              margin: EdgeInsets.symmetric(
                horizontal: context.spacing.md,
                vertical: context.spacing.md,
              ),
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: AppButtonChild(
                  isLoading: _isSubmitting,
                  label: widget.isShortlist
                      ? 'candidates.detail.shortlist'.tr()
                      : 'candidates.detail.send_interest'.tr(),
                  loaderColor: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
