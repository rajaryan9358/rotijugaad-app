import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:rotijugaad/applicants/models/applicants_models.dart';
import 'package:rotijugaad/applicants/dialogs/verify_hire_otp_dialog.dart';
import 'package:rotijugaad/applicants/sheets/applicant_detail_sheet.dart';
import 'package:rotijugaad/applicants/widgets/applicant_filter_chip.dart';
import 'package:rotijugaad/applicants/widgets/received_sent_applicant_item.dart';
import 'package:rotijugaad/applicants/widgets/shortlisted_hired_rejected_applicant_item.dart';
import 'package:rotijugaad/employerjobs/screens/employer_job_details_screen.dart';
import 'package:rotijugaad/employers/services/employers_service.dart';
import 'package:rotijugaad/common/widgets/app_loading_indicator.dart';
import 'package:rotijugaad/common/widgets/app_shimmer_placeholders.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/utils/result.dart';
import 'package:rotijugaad/utils/shared_pref.dart';

import '../providers/applicants_provider.dart';

class ApplicantsScreen extends StatefulWidget {
  const ApplicantsScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {
  final EmployersService _service = EmployersService();
  bool _isUpdatingApplicantStatus = false;
  final filters = const [
    'Received Interests',
    'Sent Interests',
    'Hired',
    'Rejected',
  ];

  String _filterLabel(String filter) {
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

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ApplicantsProvider>().ensureLoaded();
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final pos = _scrollController.position;
    if (pos.maxScrollExtent <= 0) return;

    final nearBottom = pos.pixels >= (pos.maxScrollExtent - 300);
    if (!nearBottom) return;

    context.read<ApplicantsProvider>().loadMoreIfNeeded();
  }

  void _setUpdatingApplicantStatus(bool value) {
    if (!mounted) return;
    setState(() {
      _isUpdatingApplicantStatus = value;
    });
  }

  Future<void> _openApplicantDetail(ApplicantRecord record) async {
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

    await _updateApplicantStatus(record: record, status: status, otp: otp);
  }

  Future<void> _updateApplicantStatus({
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

          await context.read<ApplicantsProvider>().refresh();

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
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ApplicantsProvider>();

    return Scaffold(
      backgroundColor: context.colors.onPrimary,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: context.spacing.sm,
                    vertical: context.spacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'applicants.title'.tr(),
                        style: context.text.titleMedium!.copyWith(
                          color: context.colors.primary,
                        ),
                      ),
                      SizedBox(height: context.spacing.sm),
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          itemCount: filters.length,
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            final filterKey = filters[index];
                            final display = _filterLabel(filterKey);
                            return ApplicantFilterChip(
                              display,
                              filterKey == provider.selectedFilter,
                              () {
                                provider.setFilter(filterKey);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spacing.sm,
                    ),
                    color: context.colors.background,
                    child: Builder(
                      builder: (context) {
                        if (provider.isLoading && provider.items.isEmpty) {
                          return AppApplicantsListShimmer(
                            filter: provider.selectedFilter,
                            padding: const EdgeInsets.only(top: 12),
                            cardMargin: EdgeInsets.symmetric(
                              vertical: context.spacing.sm,
                              horizontal: context.spacing.sm,
                            ),
                            cardPadding: EdgeInsets.symmetric(
                              vertical: context.spacing.sm,
                              horizontal: context.spacing.sm,
                            ),
                          );
                        }

                        if (provider.lastError != null &&
                            provider.items.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  provider.lastError!.message,
                                  style: context.text.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: context.spacing.md),
                                ElevatedButton(
                                  onPressed: provider.refresh,
                                  child: Text('common.retry'.tr()),
                                ),
                              ],
                            ),
                          );
                        }

                        if (provider.items.isEmpty) {
                          return Center(
                            child: Text(
                              'applicants.empty'.tr(),
                              style: context.text.bodyMedium!.copyWith(
                                color: context.colors.onBackground.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          );
                        }

                        final itemCount =
                            provider.items.length +
                            (provider.isLoadingMore ? 1 : 0);

                        return ListView.builder(
                          controller: _scrollController,
                          itemCount: itemCount,
                          itemBuilder: (context, index) {
                            if (index >= provider.items.length) {
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: context.spacing.md,
                                ),
                                child: const Center(
                                  child: AppLoadingIndicator.page(),
                                ),
                              );
                            }

                            final record = provider.items[index];

                            if (provider.selectedFilter ==
                                    'Received Interests' ||
                                provider.selectedFilter == 'Sent Interests') {
                              final raw = (record.job.status ?? '').trim();
                              final isExpired = raw.toLowerCase().contains(
                                'expire',
                              );

                              return InkWell(
                                onTap: isExpired
                                    ? null
                                    : () {
                                        _openApplicantDetail(record);
                                      },
                                child: ReceivedSentApplicantItem(
                                  record: record,
                                  disabled: isExpired,
                                  useSentOnLabel: provider.selectedFilter == 'Sent Interests',
                                ),
                              );
                            }

                            return InkWell(
                              onTap: () {
                                final jobId =
                                    record.jobInterest.jobId ?? record.job.id;
                                if (jobId == null) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EmployerJobDetailsScreen(jobId: jobId),
                                  ),
                                );
                              },
                              child: ShortlistedHiredRejectedApplicantItem(
                                record: record,
                                statusLabel: provider.selectedFilter,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
            if (_isUpdatingApplicantStatus)
              Positioned.fill(
                child: ColoredBox(
                  color: Colors.black26,
                  child: const Center(child: AppLoadingIndicator.page()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
