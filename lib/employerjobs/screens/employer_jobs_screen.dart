import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:rotijugaad/employerjobs/screens/add_job_screen.dart';
import 'package:rotijugaad/employerjobs/screens/employer_job_details_screen.dart';
import 'package:rotijugaad/employerjobs/widgets/employer_job_item.dart';
import 'package:rotijugaad/employers/services/employers_service.dart';
import 'package:rotijugaad/jobs/models/job_dto.dart';
import 'package:rotijugaad/jobs/widgets/job_item_shimmer.dart';
import 'package:rotijugaad/auth/utils/account_status_guard.dart';
import 'package:rotijugaad/profile/utils/employer_profile_action_guard.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/utils/i18n_terms.dart';
import 'package:rotijugaad/utils/result.dart';
import 'package:rotijugaad/utils/shared_pref.dart';

class EmployerJobsScreen extends StatefulWidget {
  const EmployerJobsScreen({super.key});

  @override
  State<EmployerJobsScreen> createState() => _EmployerJobsScreenState();
}

class _EmployerJobsScreenState extends State<EmployerJobsScreen> {
  final EmployersService _service = EmployersService();

  Future<List<JobDto>>? _jobsFuture;

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  int? _readEmployerId() {
    final profile = SharedPrefUtils.readJson(SharedPrefUtils.AUTH_PROFILE_JSON);
    final user = SharedPrefUtils.readJson(SharedPrefUtils.AUTH_USER_JSON);

    final fromProfile = _asInt(
      profile?['id'] ??
          profile?['employerId'] ??
          profile?['employer_id'] ??
          profile?['employerID'],
    );
    if (fromProfile != null && fromProfile > 0) return fromProfile;

    final nested = profile?['employer'];
    if (nested is Map<String, dynamic>) {
      final fromNested = _asInt(
        nested['id'] ??
            nested['employerId'] ??
            nested['employer_id'] ??
            nested['employerID'],
      );
      if (fromNested != null && fromNested > 0) return fromNested;
    }

    final fromUser = _asInt(user?['employerId'] ?? user?['employer_id']);
    if (fromUser != null && fromUser > 0) return fromUser;

    final stored = SharedPrefUtils.readInt('auth_employer_id');
    if (stored > 0) return stored;

    return null;
  }

  final NumberFormat _moneyFmt = NumberFormat.decimalPattern('en_IN');

  String _verificationStatus(JobDto job) {
    return (job.verificationStatus ?? '').trim().toLowerCase();
  }

  String _formatExpiryDate(DateTime? value) {
    if (value == null) return '—';
    return DateFormat('dd MMM yyyy').format(value);
  }

  bool _isHiringDone(JobDto job) {
    final vacancy = job.noVacancy ?? 0;
    final hired = job.hiredTotal ?? 0;
    return vacancy > 0 && hired >= vacancy;
  }

  String _fmtMoney(int value) => _moneyFmt.format(value);

  String _salaryText(JobDto job) {
    final min = job.salaryMin;
    final max = job.salaryMax;

    final suffix = (job.salaryType ?? '').trim();
    final localizedSuffix = suffix.isEmpty
        ? ''
        : I18nTerms.fromRaw(context, suffix);
    final freq = localizedSuffix.isEmpty ? '' : '/$localizedSuffix';

    if (min == null && max == null) return '—';
    if (min != null && max != null) {
      return '₹${_fmtMoney(min)} - ₹${_fmtMoney(max)}$freq';
    }
    if (min != null) return '₹${_fmtMoney(min)}$freq';
    return '${'common.up_to'.tr(args: ['₹${_fmtMoney(max!)}'])}$freq';
  }

  String _hiredText(JobDto job) {
    final hired = job.hiredTotal ?? 0;
    final vacancy = job.noVacancy ?? 0;
    if (hired <= 0 && vacancy <= 0) return '—';
    if (vacancy > 0) {
      return '${'common.of'.tr(args: [hired.toString(), vacancy.toString()])} ${'terms.hired'.tr()}';
    }
    return '$hired ${'terms.hired'.tr()}';
  }

  String _locationText(JobDto job) {
    final parts = <String>[];
    final address = (job.jobAddress ?? '').trim();
    final city = (job.jobCity ?? '').trim();
    final state = (job.jobState ?? '').trim();
    if (address.isNotEmpty) parts.add(address);
    if (city.isNotEmpty) parts.add(city);
    if (state.isNotEmpty) parts.add(state);
    if (parts.isEmpty) return '—';
    return parts.join(', ');
  }

  String _employerLabel(JobDto job) {
    final orgType = (job.organizationType ?? '').trim().toLowerCase();
    final org = (job.organizationName ?? '').trim();
    final name = (job.employerName ?? '').trim();

    if (orgType == 'firm') {
      return org.isNotEmpty ? org : (name.isNotEmpty ? name : '—');
    }
    if (orgType == 'domestic') {
      return name.isNotEmpty ? name : (org.isNotEmpty ? org : '—');
    }

    if (org.isNotEmpty) return org;
    if (name.isNotEmpty) return name;
    return '—';
  }

  bool _isActive(JobDto job) {
    final status = _statusType(job);
    if (status.isEmpty) return true;
    if (status == 'active' || status == 'published' || status == 'open') {
      return true;
    }
    if (status == 'inactive' || status == 'closed' || status == 'expired') {
      return false;
    }
    return true;
  }

  String _statusType(JobDto job) {
    final status = (job.jobStatus ?? '').trim().toLowerCase();
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

  _EmployerJobCardUi _cardUi(BuildContext context, JobDto job) {
    final statusType = _statusType(job);
    final verificationStatus = _verificationStatus(job);
    final expiryDate = _formatExpiryDate(job.expiredAt);

    if (statusType == 'expired' && _isHiringDone(job)) {
      return _EmployerJobCardUi(
        statusInfo: 'This ad has expired and hiring is complete.',
        cardBackgroundColor: context.xcolors.successBackground,
        badgeBackgroundColor: context.colors.onPrimary,
        badgeForegroundColor: context.xcolors.success,
        infoBackgroundColor: context.xcolors.success,
        infoForegroundColor: context.colors.onPrimary,
      );
    }

    if (statusType == 'expired') {
      return _EmployerJobCardUi(
        statusInfo: 'This ad expired on $expiryDate.',
        cardBackgroundColor: context.xcolors.infoBackground,
        badgeBackgroundColor: context.colors.onPrimary,
        badgeForegroundColor: context.colors.primary,
        infoBackgroundColor: context.colors.primary,
        infoForegroundColor: context.colors.onPrimary,
      );
    }

    if (verificationStatus == 'pending') {
      return _EmployerJobCardUi(
        statusInfo: 'Approval is pending, so this job is currently inactive.',
        cardBackgroundColor: context.xcolors.warningBackground,
        badgeBackgroundColor: context.colors.onPrimary,
        badgeForegroundColor: context.xcolors.warning,
        infoBackgroundColor: context.xcolors.warning,
        infoForegroundColor: context.colors.onPrimary,
      );
    }

    if (verificationStatus == 'rejected') {
      return _EmployerJobCardUi(
        statusInfo: 'Approval was rejected, so this job remains inactive.',
        cardBackgroundColor: context.xcolors.failureBackground,
        badgeBackgroundColor: context.colors.onPrimary,
        badgeForegroundColor: context.colors.error,
        infoBackgroundColor: context.colors.error,
        infoForegroundColor: context.colors.onPrimary,
      );
    }

    if (verificationStatus == 'approved') {
      return _EmployerJobCardUi(
        statusInfo: statusType == 'active'
            ? 'Approved and live until $expiryDate.'
            : 'Approved until $expiryDate, but currently inactive.',
        cardBackgroundColor: statusType == 'active'
            ? context.xcolors.successBackground
            : context.colors.primaryContainer,
        badgeBackgroundColor: context.colors.onPrimary,
        badgeForegroundColor: statusType == 'active'
            ? context.xcolors.success
            : context.colors.secondary,
        infoBackgroundColor: statusType == 'active'
            ? context.xcolors.success
            : context.colors.secondary,
        infoForegroundColor: context.colors.onPrimary,
      );
    }

    if (statusType == 'inactive') {
      return _EmployerJobCardUi(
        statusInfo: 'This job is currently inactive.',
        cardBackgroundColor: context.colors.primaryContainer,
        badgeBackgroundColor: context.colors.onPrimary,
        badgeForegroundColor: context.colors.secondary,
        infoBackgroundColor: context.colors.secondary,
        infoForegroundColor: context.colors.onPrimary,
      );
    }

    return _EmployerJobCardUi(
      statusInfo: 'This job is currently active.',
      cardBackgroundColor: context.xcolors.successBackground,
      badgeBackgroundColor: context.colors.onPrimary,
      badgeForegroundColor: context.xcolors.success,
      infoBackgroundColor: context.xcolors.success,
      infoForegroundColor: context.colors.onPrimary,
    );
  }

  Future<List<JobDto>> _loadJobs() async {
    final employerId = _readEmployerId();
    if (employerId == null || employerId <= 0) {
      throw Exception('Employer id not found. Please login again.');
    }

    final result = await _service.getEmployerJobs(employerId);
    switch (result) {
      case Success(value: final resp):
        return resp.jobs;
      case Failure(exception: final e):
        throw e;
    }
  }

  @override
  void initState() {
    super.initState();
    _jobsFuture = _loadJobs();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) AccountStatusGuard.handleIfInactive(context);
    });
  }

  void _refreshJobs() {
    setState(() {
      _jobsFuture = _loadJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.onPrimary,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: context.spacing.md,
                vertical: context.spacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'employer_jobs.title'.tr(),
                    style: context.text.titleMedium!.copyWith(
                      color: context.colors.onPrimaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.spacing.md,
                          vertical: 0,
                        ),
                      ),
                      onPressed: () async {
                        if (!await EmployerProfileActionGuard.ensureAllowed(
                          context,
                          blockPending: false,
                        )) {
                          return;
                        }
                        if (!context.mounted) return;
                        if (!await EmployerProfileActionGuard.ensureHasAdCredit(
                          context,
                        )) {
                          return;
                        }
                        if (!context.mounted) return;
                        final didChange = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AddJobScreen(),
                          ),
                        );
                        if (didChange == true && mounted) {
                          _refreshJobs();
                        }
                      },
                      child: Text('employer_jobs.add_new_job'.tr()),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              color: context.xcolors.stroke.withValues(alpha: 0.5),
              height: 1,
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: context.spacing.md),
                child: FutureBuilder<List<JobDto>>(
                  future: _jobsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return ListView.builder(
                        itemCount: 6,
                        itemBuilder: (context, index) =>
                            const JobItemShimmer(horizontalPadding: 0),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          snapshot.error.toString(),
                          style: context.text.bodyMedium!.copyWith(
                            color: context.colors.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }

                    final jobs = snapshot.data ?? const <JobDto>[];
                    if (jobs.isEmpty) {
                      return Center(
                        child: Text(
                          'employer_jobs.no_jobs_found'.tr(),
                          style: context.text.bodyMedium!.copyWith(
                            color: context.colors.onBackground.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: jobs.length,
                      itemBuilder: (context, index) {
                        final job = jobs[index];

                        final title = (job.jobProfile ?? '').trim().isNotEmpty
                            ? job.jobProfile!.trim()
                            : 'employer_jobs.job_fallback'.tr(
                                args: [job.id.toString()],
                              );

                        final subtitle = _employerLabel(job);
                        final cardUi = _cardUi(context, job);

                        return InkWell(
                          onTap: () async {
                            final didChange = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EmployerJobDetailsScreen(jobId: job.id),
                              ),
                            );
                            if (didChange == true && mounted) {
                              _refreshJobs();
                            }
                          },
                          child: EmployerJobItem(
                            isActive: _isActive(job),
                            statusType: _statusType(job),
                            title: title,
                            subtitle: subtitle.isEmpty ? '—' : subtitle,
                            location: _locationText(job),
                            salary: _salaryText(job),
                            hired: _hiredText(job),
                            statusInfo: cardUi.statusInfo,
                            cardBackgroundColor: cardUi.cardBackgroundColor,
                            badgeBackgroundColor: cardUi.badgeBackgroundColor,
                            badgeForegroundColor: cardUi.badgeForegroundColor,
                            infoBackgroundColor: cardUi.infoBackgroundColor,
                            infoForegroundColor: cardUi.infoForegroundColor,
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
      ),
    );
  }
}

class _EmployerJobCardUi {
  final String statusInfo;
  final Color cardBackgroundColor;
  final Color badgeBackgroundColor;
  final Color badgeForegroundColor;
  final Color infoBackgroundColor;
  final Color infoForegroundColor;

  const _EmployerJobCardUi({
    required this.statusInfo,
    required this.cardBackgroundColor,
    required this.badgeBackgroundColor,
    required this.badgeForegroundColor,
    required this.infoBackgroundColor,
    required this.infoForegroundColor,
  });
}
