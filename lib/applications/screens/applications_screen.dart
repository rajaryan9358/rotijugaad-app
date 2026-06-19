import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:rotijugaad/applications/widgets/application_item.dart';
import 'package:rotijugaad/jobs/models/job_dto.dart';
import 'package:rotijugaad/jobs/widgets/job_item_shimmer.dart';
import 'package:rotijugaad/network/api_client.dart';
import 'package:rotijugaad/network/api_service.dart';
import 'package:rotijugaad/theme/context_ext.dart';
import 'package:rotijugaad/utils/i18n_terms.dart';

import '../../jobdetails/screens/job_details_screen.dart';
import '../../utils/custom_exception.dart';
import '../../utils/result.dart';
import '../../utils/shared_pref.dart';

class ApplicationsScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ApplicationsScreenState();
}

class _ApplicationRow {
  final JobDto job;
  final String status;
  final DateTime? appliedAt;
  final bool isJobExpired;

  const _ApplicationRow({
    required this.job,
    required this.status,
    required this.isJobExpired,
    this.appliedAt,
  });
}

class _ApplicationsScreenState extends State<ApplicationsScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  final ApiService _api = ApiService();

  int? _employeeId;

  bool _loadingSent = true;
  bool _loadingReceived = true;
  String? _errorSent;
  String? _errorReceived;

  List<_ApplicationRow> _sent = const [];
  List<_ApplicationRow> _received = const [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchCurrentTab();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    _fetchCurrentTab();
  }

  int? _readEmployeeId() {
    final profile = SharedPrefUtils.readJson(SharedPrefUtils.AUTH_PROFILE_JSON);
    final raw = profile?['id'];
    if (raw is int) return raw;
    return int.tryParse((raw ?? '').toString());
  }

  static DateTime? _parseUtc(String s) {
    final trimmed = s.trim();
    if (trimmed.isEmpty) return null;
    final hasOffset = trimmed.endsWith('Z') || trimmed.contains('+') ||
        RegExp(r'T\d{2}:\d{2}:\d{2}.*-\d{2}').hasMatch(trimmed);
    return DateTime.tryParse(hasOffset ? trimmed : '${trimmed}Z');
  }

  bool _isJobExpired(JobDto job) {
    if (job.isExpired) return true;
    final s = (job.jobStatus ?? '').trim().toLowerCase();
    return s == 'expired';
  }

  String _displayStatus({
    required bool isSentTab,
    required bool jobExpired,
    required String? applicationStatus,
  }) {
    if (jobExpired) return I18nTerms.fromRaw(context, 'expired');

    final s = (applicationStatus ?? '').trim().toLowerCase();
    switch (s) {
      case 'pending':
        return I18nTerms.fromRaw(context, isSentTab ? 'applied' : 'active');
      case 'shortlisted':
        return I18nTerms.fromRaw(context, 'shortlisted');
      case 'rejected':
        return I18nTerms.fromRaw(context, 'rejected');
      case 'hired':
        return I18nTerms.fromRaw(context, 'hired');
      default:
        return I18nTerms.fromRaw(context, isSentTab ? 'applied' : 'active');
    }
  }

  List<_ApplicationRow> _parseRows(
    Map<String, dynamic>? json, {
    required bool isSentTab,
  }) {
    final map = json ?? const <String, dynamic>{};
    final results = (map['results'] is List)
        ? (map['results'] as List)
        : const [];

    return results
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .map((item) {
          final app = item['application'];
          final job = item['job'];

          final appStatus = app is Map ? app['status']?.toString() : null;
          final sentAtRaw = app is Map
              ? (app['sent_at'] ?? app['created_at'])
              : null;
          final appliedAt = sentAtRaw == null
              ? null
              : _parseUtc(sentAtRaw.toString());

          final jobDto = JobDto.fromJson(
            job is Map
                ? job.cast<String, dynamic>()
                : const <String, dynamic>{},
          );

          final jobExpired = _isJobExpired(jobDto);
          final status = _displayStatus(
            isSentTab: isSentTab,
            jobExpired: jobExpired,
            applicationStatus: appStatus,
          );

          return _ApplicationRow(
            job: jobDto,
            status: status,
            appliedAt: appliedAt,
            isJobExpired: jobExpired,
          );
        })
        .where((row) => row.job.id > 0)
        .toList(growable: false);
  }

  Future<int?> _ensureEmployeeId() async {
    final employeeId = _readEmployeeId();
    if (employeeId == null || employeeId <= 0) {
      if (mounted) {
        setState(() {
          _employeeId = null;
          _loadingSent = false;
          _loadingReceived = false;
          _errorSent = 'errors.no_employee_id'.tr();
          _errorReceived = 'errors.no_employee_id'.tr();
          _sent = const [];
          _received = const [];
        });
      }
      return null;
    }

    _employeeId = employeeId;
    return employeeId;
  }

  Future<void> _fetchCurrentTab() async {
    final employeeId = await _ensureEmployeeId();
    if (employeeId == null) return;

    if (_tabController.index == 1) {
      await _fetchReceived(employeeId);
    } else {
      await _fetchSent(employeeId);
    }
  }

  Future<void> _fetchSent(int employeeId) async {
    setState(() {
      _loadingSent = true;
      _errorSent = null;
    });

    final result = await _api.getJson<List<_ApplicationRow>>(
      endpoint: ApiClient.employeeApplicationsSent(employeeId),
      queryParameters: const {'page': '1', 'limit': '50'},
      fromJson: (json) => _parseRows(json, isSentTab: true),
    );

    if (!mounted) return;

    if (result is Success<List<_ApplicationRow>, CustomException>) {
      setState(() {
        _loadingSent = false;
        _sent = result.value;
      });
      return;
    }

    if (result is Failure<List<_ApplicationRow>, CustomException>) {
      setState(() {
        _loadingSent = false;
        _errorSent = result.exception.message;
        _sent = const [];
      });
    }
  }

  Future<void> _fetchReceived(int employeeId) async {
    setState(() {
      _loadingReceived = true;
      _errorReceived = null;
    });

    final result = await _api.getJson<List<_ApplicationRow>>(
      endpoint: ApiClient.employeeApplicationsReceived(employeeId),
      queryParameters: const {'page': '1', 'limit': '50'},
      fromJson: (json) => _parseRows(json, isSentTab: false),
    );

    if (!mounted) return;

    if (result is Success<List<_ApplicationRow>, CustomException>) {
      setState(() {
        _loadingReceived = false;
        _received = result.value;
      });
      return;
    }

    if (result is Failure<List<_ApplicationRow>, CustomException>) {
      setState(() {
        _loadingReceived = false;
        _errorReceived = result.exception.message;
        _received = const [];
      });
    }
  }

  Widget _buildTab({
    required bool loading,
    required String? error,
    required List<_ApplicationRow> rows,
    required String emptyText,
    required Future<void> Function() onRefresh,
  }) {
    Widget child;

    if (loading) {
      child = ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: context.spacing.md),
        itemCount: 6,
        itemBuilder: (context, index) => const JobItemShimmer(),
      );
    } else if (error != null) {
      child = ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(context.spacing.md),
                child: Text(
                  error,
                  style: context.text.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      );
    } else if (rows.isEmpty) {
      child = ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Text(emptyText, style: context.text.bodyMedium),
            ),
          ),
        ],
      );
    } else {
      child = ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(top: context.spacing.md),
        itemCount: rows.length,
        itemBuilder: (context, index) {
          final row = rows[index];
          return InkWell(
            onTap: () {
              final employeeId = _employeeId;
              if (employeeId == null || employeeId <= 0) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JobDetailsScreen(
                    jobId: row.job.id,
                    employeeId: employeeId,
                  ),
                ),
              );
            },
            child: ApplicationItem(
              job: row.job,
              status: row.status,
              appliedAt: row.appliedAt,
              isGreyed: row.isJobExpired,
            ),
          );
        },
      );
    }

    return RefreshIndicator(onRefresh: onRefresh, child: child);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: context.colors.onPrimary,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).viewPadding.top,
                left: context.spacing.md,
                right: context.spacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: context.spacing.sm),
                  Text(
                    'nav.applications'.tr(),
                    style: context.text.titleMedium!.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    labelColor: context.colors.onBackground,
                    labelStyle: context.text.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: context.text.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    unselectedLabelColor: context.colors.onSurface,
                    dividerColor: Colors.transparent,
                    indicatorColor: context.colors.primary,
                    indicatorWeight: 2,
                    tabs: [
                      Tab(text: 'applications.tabs.sent'.tr()),
                      Tab(text: 'applications.tabs.received'.tr()),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: context.spacing.xs),
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTab(
                      loading: _loadingSent,
                      error: _errorSent,
                      rows: _sent,
                      emptyText: 'applications.empty.sent'.tr(),
                      onRefresh: () async {
                        final employeeId = await _ensureEmployeeId();
                        if (employeeId == null) return;
                        await _fetchSent(employeeId);
                      },
                    ),
                    _buildTab(
                      loading: _loadingReceived,
                      error: _errorReceived,
                      rows: _received,
                      emptyText: 'applications.empty.received'.tr(),
                      onRefresh: () async {
                        final employeeId = await _ensureEmployeeId();
                        if (employeeId == null) return;
                        await _fetchReceived(employeeId);
                      },
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
}
