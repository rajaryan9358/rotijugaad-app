import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../applicants/models/applicants_models.dart';
import '../../jobs/models/job_dto.dart';
import '../../jobs/services/jobs_service.dart';
import '../../utils/custom_exception.dart';
import '../../utils/result.dart';
import '../../utils/shared_pref.dart';

class EmployerJobDetailsProvider extends ChangeNotifier {
  final JobsService _service;
  final int jobId;

  EmployerJobDetailsProvider({required this.jobId, JobsService? service})
    : _service = service ?? JobsService();

  final List<String> filters = const [
    'Received Interests',
    'Sent Interests',
    'Hired',
    'Rejected',
  ];

  String selectedFilter = 'Received Interests';

  JobDto? job;
  bool isLoadingJob = false;
  CustomException? jobError;

  bool isLoading = false;
  bool isLoadingMore = false;
  CustomException? lastError;

  int _page = 1;
  final int _limit = 20;
  int _total = 0;
  final List<ApplicantRecord> _items = [];

  List<ApplicantRecord> get items => List.unmodifiable(_items);

  bool get hasMore {
    if (_total <= 0) return false;
    return _items.length < _total;
  }

  void _notifySafely() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!hasListeners) return;
        super.notifyListeners();
      });
      return;
    }

    super.notifyListeners();
  }

  void ensureLoaded() {
    if (job == null && !isLoadingJob) {
      loadJobDetail();
    }
    if (_items.isEmpty && !isLoading) {
      refresh();
    }
  }

  void setFilter(String filter) {
    if (filter == selectedFilter) return;
    selectedFilter = filter;

    _page = 1;
    _total = 0;
    _items.clear();
    lastError = null;

    _notifySafely();
    refresh();
  }

  Future<void> loadJobDetail() async {
    if (isLoadingJob) return;

    final employerId = SharedPrefUtils.readInt('auth_employer_id');
    if (employerId <= 0) {
      jobError = CustomException(
        code: 'NO_EMPLOYER',
        message: 'Employer ID not found. Please sign in again.',
      );
      _notifySafely();
      return;
    }

    isLoadingJob = true;
    jobError = null;
    _notifySafely();

    final result = await _service.getEmployerJobDetail(
      employerId: employerId,
      jobId: jobId,
    );

    switch (result) {
      case Success(value: final value):
        job = value;
        break;
      case Failure(exception: final e):
        jobError = e;
        break;
    }

    isLoadingJob = false;
    _notifySafely();
  }

  Future<void> refresh() async {
    if (isLoading) return;

    isLoading = true;
    lastError = null;
    _notifySafely();

    await _loadPage(1, append: false);

    isLoading = false;
    _notifySafely();
  }

  Future<void> loadMoreIfNeeded() async {
    if (isLoading || isLoadingMore) return;
    if (!hasMore) return;

    isLoadingMore = true;
    lastError = null;
    _notifySafely();

    await _loadPage(_page + 1, append: true);

    isLoadingMore = false;
    _notifySafely();
  }

  Future<void> _loadPage(int page, {required bool append}) async {
    final employerId = SharedPrefUtils.readInt('auth_employer_id');
    if (employerId <= 0) {
      lastError = CustomException(
        code: 'NO_EMPLOYER',
        message: 'Employer ID not found. Please sign in again.',
      );
      return;
    }

    Result<ApplicantsPageResponse, CustomException> result;

    switch (selectedFilter) {
      case 'Received Interests':
        result = await _service.getEmployerJobApplicantsReceived(
          employerId: employerId,
          jobId: jobId,
          page: page,
          limit: _limit,
        );
        break;
      case 'Sent Interests':
        result = await _service.getEmployerJobApplicantsSent(
          employerId: employerId,
          jobId: jobId,
          page: page,
          limit: _limit,
        );
        break;
      case 'Shortlisted':
        result = await _service.getEmployerJobApplicantsShortlisted(
          employerId: employerId,
          jobId: jobId,
          page: page,
          limit: _limit,
        );
        break;
      case 'Hired':
        result = await _service.getEmployerJobApplicantsHired(
          employerId: employerId,
          jobId: jobId,
          page: page,
          limit: _limit,
        );
        break;
      case 'Rejected':
      default:
        result = await _service.getEmployerJobApplicantsRejected(
          employerId: employerId,
          jobId: jobId,
          page: page,
          limit: _limit,
        );
        break;
    }

    switch (result) {
      case Success(value: final resp):
        _page = resp.page;
        _total = resp.total;
        if (!append) _items.clear();
        _items.addAll(resp.results);
        break;
      case Failure(exception: final e):
        lastError = e;
        if (!append) {
          _page = 1;
          _total = 0;
          _items.clear();
        }
        break;
    }
  }
}
