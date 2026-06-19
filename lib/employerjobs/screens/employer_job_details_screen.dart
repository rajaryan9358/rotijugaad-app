import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:rotijugaad/common/widgets/toolbar.dart';
import 'package:rotijugaad/common/widgets/xicon.dart';
import 'package:rotijugaad/applicants/models/applicants_models.dart';
import 'package:rotijugaad/applicants/dialogs/verify_hire_otp_dialog.dart';
import 'package:rotijugaad/employerjobs/providers/employer_job_details_provider.dart';
import 'package:rotijugaad/employerjobs/screens/add_job_screen.dart';
import 'package:rotijugaad/employers/services/employers_service.dart';
import 'package:rotijugaad/jobdetails/widgets/job_details_shimmer.dart';
import 'package:rotijugaad/jobs/models/job_dto.dart';
import 'package:rotijugaad/theme/app_icons.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/utils/i18n_terms.dart';
import 'package:rotijugaad/utils/job_text_utils.dart';
import 'package:rotijugaad/utils/result.dart';
import 'package:rotijugaad/utils/shared_pref.dart';

import '../../applicants/sheets/applicant_detail_sheet.dart';
import '../../applicants/widgets/applicant_filter_chip.dart';
import '../../applicants/widgets/received_sent_applicant_item.dart';
import '../../applicants/widgets/shortlisted_hired_rejected_applicant_item.dart';
import '../../common/widgets/app_loading_indicator.dart';
import '../../common/widgets/app_shimmer_placeholders.dart';
import '../../common/widgets/icon_text.dart';

class EmployerJobDetailsScreen extends StatefulWidget {
  final int jobId;

  const EmployerJobDetailsScreen({super.key, required this.jobId});

  @override
  State<StatefulWidget> createState() => _EmployerJobDetailsScreenState();
}

class _EmployerJobDetailsScreenState extends State<EmployerJobDetailsScreen> {
  final ScrollController _scrollController = ScrollController();
  final NumberFormat _moneyFmt = NumberFormat.decimalPattern('en_IN');
  final EmployersService _service = EmployersService();
  bool _didMutate = false;
  bool _isUpdatingApplicantStatus = false;

  String _jobStatusType(String? raw) {
    final status = (raw ?? '').trim().toLowerCase();
    if (status.isEmpty) return 'active';
    if (status == 'expired' || status.contains('expire')) return 'expired';
    if (status == 'inactive' || status == 'closed' || status == 'unpublished') {
      return 'inactive';
    }
    if (status == 'active' || status == 'published' || status == 'open') {
      return 'active';
    }
    return 'active';
  }

  String _statusLabel(BuildContext context, String? raw) {
    return I18nTerms.fromRaw(context, _jobStatusType(raw));
  }

  String _filterLabel(BuildContext context, String filter) {
    switch (filter) {
      case 'Received Interests':
        return 'filters.received_interests'.tr();
      case 'Sent Interests':
        return 'filters.sent_interests'.tr();
      case 'Hired':
        return 'filters.hired'.tr();
      case 'Rejected':
        return 'filters.rejected'.tr();
      default:
        return filter;
    }
  }

  String _subtitleText(JobDto? job) {
    final orgType = (job?.organizationType ?? '').trim().toLowerCase();
    final org = (job?.organizationName ?? '').trim();
    final name = (job?.employerName ?? '').trim();

    if (orgType == 'firm') {
      return org.isNotEmpty ? org : name;
    }
    if (orgType == 'domestic') {
      return name.isNotEmpty ? name : org;
    }
    return org.isNotEmpty ? org : name;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final pos = _scrollController.position;
    if (pos.maxScrollExtent <= 0) return;

    final nearBottom = pos.pixels >= (pos.maxScrollExtent - 300);
    if (!nearBottom) return;

    context.read<EmployerJobDetailsProvider>().loadMoreIfNeeded();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  String _locationText(EmployerJobDetailsProvider provider) {
    final job = provider.job;
    final parts = [
      (job?.jobAddress ?? '').trim(),
      (job?.jobCity ?? '').trim(),
      (job?.jobState ?? '').trim(),
    ].where((e) => e.isNotEmpty).toList();

    return parts.isEmpty ? '-' : parts.join(', ');
  }

  String _salaryText(
    BuildContext context,
    EmployerJobDetailsProvider provider,
  ) {
    final job = provider.job;
    final min = job?.salaryMin;
    final max = job?.salaryMax;
    final freq = (job?.salaryType ?? '').trim();

    if (min == null && max == null) return '-';

    String range;
    if (min != null && max != null) {
      range = '₹${_moneyFmt.format(min)} - ₹${_moneyFmt.format(max)}';
    } else if (min != null) {
      range = '₹${_moneyFmt.format(min)}+';
    } else {
      range = 'common.up_to'.tr(args: ['₹${_moneyFmt.format(max)}']);
    }

    if (freq.isEmpty) return range;
    final freqLabel = I18nTerms.fromRaw(context, freq);
    return '$range/$freqLabel';
  }

  String _vacancyText(EmployerJobDetailsProvider provider) {
    final v = provider.job?.noVacancy;
    if (v == null) return '-';
    return formatVacancyCountText(v, padToTwoDigits: true);
  }

  void _setUpdatingApplicantStatus(bool value) {
    if (!mounted) return;
    setState(() {
      _isUpdatingApplicantStatus = value;
    });
  }

  Future<void> _openApplicantDetail(
    BuildContext context,
    EmployerJobDetailsProvider provider,
    ApplicantRecord record,
  ) async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return ApplicantDetailSheet(record: record);
      },
    );

    if (!mounted || result == null) return;

    final status = (result['status'] ?? '').toString().trim();
    if (status.isEmpty) return;

    String? otp;
    if (status == 'hired') {
      otp = await showDialog<String>(
        context: context,
        barrierDismissible: true,
        builder: (context) => const VerifyHireOtpDialog(),
      );

      if (!mounted) return;

      final normalizedOtp = (otp ?? '').trim();
      if (normalizedOtp.isEmpty) return;
      otp = normalizedOtp;
    }

    await _updateApplicantStatus(
      context,
      provider,
      record: record,
      status: status,
      otp: otp,
    );
  }

  Future<void> _updateApplicantStatus(
    BuildContext context,
    EmployerJobDetailsProvider provider, {
    required ApplicantRecord record,
    required String status,
    String? otp,
  }) async {
    final employerId = SharedPrefUtils.readInt('auth_employer_id');
    final jobInterestId = record.jobInterest.id;

    if (employerId <= 0 || jobInterestId == null || jobInterestId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to process request.')),
      );
      return;
    }

    _setUpdatingApplicantStatus(true);

    try {
      final result = await _service.updateApplicantStatus(
        employerId: employerId,
        jobInterestId: jobInterestId,
        status: status,
        otp: otp,
      );

      if (!mounted) return;

      switch (result) {
        case Success(value: final value):
          final message =
              (value['message'] ??
                      (status == 'hired'
                          ? 'Candidate hired successfully'
                          : 'Application rejected successfully'))
                  .toString()
                  .trim();

          _didMutate = true;
          await provider.refresh();
          await provider.loadJobDetail();

          if (!mounted || message.isEmpty) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          break;
        case Failure(exception: final e):
          final message = e.message.trim().isEmpty
              ? 'Unable to process request.'
              : e.message.trim();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          break;
      }
    } finally {
      _setUpdatingApplicantStatus(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          EmployerJobDetailsProvider(jobId: widget.jobId)..ensureLoaded(),
      child: Consumer<EmployerJobDetailsProvider>(
        builder: (context, provider, _) {
          final job = provider.job;

          final title = (job?.jobProfile ?? '').trim().isNotEmpty
              ? job!.jobProfile!.trim()
              : 'Job #${widget.jobId}';

          final subtitle = _subtitleText(job);
          final jobStatusType = _jobStatusType(job?.jobStatus);
          final isActive = jobStatusType == 'active';
          final isExpired = jobStatusType == 'expired';
          final status = _statusLabel(context, job?.jobStatus);

          final itemCount =
              provider.items.length +
              ((provider.isLoadingMore || provider.isLoading) &&
                      provider.items.isNotEmpty
                  ? 1
                  : 0);

          return WillPopScope(
            onWillPop: () async {
              Navigator.of(context).pop(_didMutate);
              return false;
            },
            child: Scaffold(
              backgroundColor: context.colors.onPrimary,
              body: SafeArea(
                child: Stack(
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Toolbar(
                                'employer_jobs.job_details'.tr(),
                                () {
                                  Navigator.of(context).pop(_didMutate);
                                },
                              ),
                            ),
                            IconButton(
                              onPressed: job == null
                                  ? null
                                  : () async {
                                      final didChange =
                                          await Navigator.push<bool>(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AddJobScreen(
                                                    isEdit: true,
                                                    jobId: widget.jobId,
                                                  ),
                                            ),
                                          );
                                      if (didChange == true && mounted) {
                                        _didMutate = true;
                                        await provider.loadJobDetail();
                                      }
                                    },
                              icon: XIcon(AppIcon.edit),
                            ),
                          ],
                        ),
                        Expanded(
                          child: (provider.isLoadingJob && job == null)
                              ? const JobDetailsShimmer()
                              : Column(
                                  children: [
                                    SizedBox(height: context.spacing.sm),
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: context.spacing.md,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    title,
                                                    style: context
                                                        .text
                                                        .bodyLarge!
                                                        .copyWith(
                                                          color: context
                                                              .colors
                                                              .primary,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                  ),
                                                  if (subtitle.isNotEmpty)
                                                    Row(
                                                      children: [
                                                        Text(
                                                          subtitle,
                                                          style: context
                                                              .text
                                                              .bodyMedium!
                                                              .copyWith(
                                                                color: context
                                                                    .colors
                                                                    .secondary,
                                                              ),
                                                        ),
                                                        SizedBox(
                                                          width: context
                                                              .spacing
                                                              .xs,
                                                        ),
                                                        if ((job?.verificationStatus ??
                                                                '')
                                                            .trim()
                                                            .isNotEmpty)
                                                          XIcon(
                                                            AppIcon.verified,
                                                            color: context
                                                                .colors
                                                                .primary,
                                                            size: 14,
                                                          ),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                              SizedBox(
                                                height: 40,
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    elevation: 0,
                                                    disabledBackgroundColor:
                                                        isActive
                                                        ? context
                                                              .colors
                                                              .secondary
                                                        : context
                                                              .colors
                                                              .primaryContainer,
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          horizontal: context
                                                              .spacing
                                                              .md,
                                                          vertical: 0,
                                                        ),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                Radius.circular(
                                                                  context
                                                                      .radii
                                                                      .sm,
                                                                ),
                                                              ),
                                                          side: BorderSide(
                                                            color: isActive
                                                                ? context
                                                                      .colors
                                                                      .secondary
                                                                : context
                                                                      .xcolors
                                                                      .stroke,
                                                            width: 1,
                                                          ),
                                                        ),
                                                  ),
                                                  onPressed: null,
                                                  child: Row(
                                                    children: [
                                                      XIcon(
                                                        AppIcon.activeJob,
                                                        color: isActive
                                                            ? context
                                                                  .colors
                                                                  .onPrimary
                                                            : context
                                                                  .colors
                                                                  .onBackground
                                                                  .withValues(
                                                                    alpha: 0.5,
                                                                  ),
                                                        size: 16,
                                                      ),
                                                      SizedBox(
                                                        width:
                                                            context.spacing.xs,
                                                      ),
                                                      Text(
                                                        status,
                                                        style: context
                                                            .text
                                                            .bodyMedium!
                                                            .copyWith(
                                                              color: isActive
                                                                  ? context
                                                                        .colors
                                                                        .onPrimary
                                                                  : context
                                                                        .colors
                                                                        .onBackground
                                                                        .withValues(
                                                                          alpha:
                                                                              0.5,
                                                                        ),
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: context.spacing.sm),
                                          IconText(
                                            XIcon(AppIcon.location, size: 16),
                                            _locationText(provider),
                                          ),
                                          SizedBox(height: context.spacing.sm),
                                          Row(
                                            children: [
                                              IconText(
                                                XIcon(AppIcon.salary, size: 16),
                                                _salaryText(context, provider),
                                              ),
                                              SizedBox(
                                                width: context.spacing.md,
                                              ),
                                              IconText(
                                                XIcon(
                                                  AppIcon.vacancy,
                                                  size: 16,
                                                ),
                                                _vacancyText(provider),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: context.spacing.md),
                                          SizedBox(
                                            height: 40,
                                            child: ListView.builder(
                                              itemCount:
                                                  provider.filters.length,
                                              shrinkWrap: true,
                                              scrollDirection: Axis.horizontal,
                                              itemBuilder: (context, index) {
                                                final filter =
                                                    provider.filters[index];
                                                final display = _filterLabel(
                                                  context,
                                                  filter,
                                                );
                                                return ApplicantFilterChip(
                                                  display,
                                                  filter ==
                                                      provider.selectedFilter,
                                                  () {
                                                    provider.setFilter(filter);
                                                    WidgetsBinding.instance
                                                        .addPostFrameCallback((
                                                          _,
                                                        ) {
                                                          if (!mounted) return;
                                                          if (_scrollController
                                                              .hasClients) {
                                                            _scrollController
                                                                .jumpTo(0);
                                                          }
                                                        });
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                          if (provider.jobError != null) ...[
                                            SizedBox(
                                              height: context.spacing.sm,
                                            ),
                                            Text(
                                              provider.jobError!.message,
                                              style: context.text.bodyMedium!
                                                  .copyWith(
                                                    color: context.colors.error,
                                                  ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: context.spacing.sm),
                                    Divider(
                                      color: context.xcolors.stroke.withValues(
                                        alpha: 0.5,
                                      ),
                                      height: 1,
                                    ),
                                    Expanded(
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: context.spacing.sm,
                                        ),
                                        color: context.colors.background,
                                        child: Builder(
                                          builder: (context) {
                                            if (provider.isLoading &&
                                                provider.items.isEmpty) {
                                              return const AppListShimmer();
                                            }

                                            if (provider.lastError != null &&
                                                provider.items.isEmpty) {
                                              return Center(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      provider
                                                          .lastError!
                                                          .message,
                                                      style: context
                                                          .text
                                                          .bodyMedium,
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                    SizedBox(
                                                      height:
                                                          context.spacing.md,
                                                    ),
                                                    ElevatedButton(
                                                      onPressed:
                                                          provider.refresh,
                                                      child: Text(
                                                        'common.retry'.tr(),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            }

                                            if (provider.items.isEmpty) {
                                              return Center(
                                                child: Text(
                                                  'applicants.empty'.tr(),
                                                  style: context
                                                      .text
                                                      .bodyMedium!
                                                      .copyWith(
                                                        color: context
                                                            .colors
                                                            .onBackground
                                                            .withValues(
                                                              alpha: 0.6,
                                                            ),
                                                      ),
                                                ),
                                              );
                                            }

                                            return ListView.builder(
                                              controller: _scrollController,
                                              itemCount: itemCount,
                                              itemBuilder: (context, index) {
                                                if (index >=
                                                    provider.items.length) {
                                                  return Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                          vertical: context
                                                              .spacing
                                                              .md,
                                                        ),
                                                    child: const Center(
                                                      child:
                                                          AppLoadingIndicator.page(),
                                                    ),
                                                  );
                                                }

                                                final record =
                                                    provider.items[index];
                                                final filter =
                                                    provider.selectedFilter;

                                                final isInterestTab =
                                                    filter ==
                                                        'Received Interests' ||
                                                    filter == 'Sent Interests';
                                                final disableTap =
                                                    isExpired && isInterestTab;

                                                final widget =
                                                    (filter ==
                                                            'Received Interests' ||
                                                        filter ==
                                                            'Sent Interests')
                                                    ? ReceivedSentApplicantItem(
                                                        record: record,
                                                        disabled: disableTap,
                                                        jobStatusOverride:
                                                            provider
                                                                .job
                                                                ?.jobStatus,
                                                        showJobStatus: false,
                                                        showEmployeePreferenceMeta:
                                                            filter ==
                                                                'Received Interests' ||
                                                            filter ==
                                                                'Sent Interests',
                                                        showEmployeeJobProfiles:
                                                            filter ==
                                                            'Received Interests',
                                                        useSentOnLabel:
                                                            filter ==
                                                            'Sent Interests',
                                                      )
                                                    : ShortlistedHiredRejectedApplicantItem(
                                                        record: record,
                                                        statusLabel: filter,
                                                        showStatusLabel: false,
                                                      );

                                                return InkWell(
                                                  onTap: disableTap
                                                      ? null
                                                      : () {
                                                          _openApplicantDetail(
                                                            context,
                                                            provider,
                                                            record,
                                                          );
                                                        },
                                                  child: widget,
                                                );
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ],
                    ),
                    if (_isUpdatingApplicantStatus)
                      Positioned.fill(
                        child: ColoredBox(
                          color: Colors.black26,
                          child: const Center(
                            child: AppLoadingIndicator.page(),
                          ),
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
