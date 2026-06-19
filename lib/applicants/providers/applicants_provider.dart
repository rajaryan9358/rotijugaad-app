import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../employers/services/employers_service.dart';
import '../../utils/custom_exception.dart';
import '../../utils/result.dart';
import '../../utils/shared_pref.dart';
import '../models/applicants_models.dart';

class ApplicantsProvider extends ChangeNotifier {
  final EmployersService _service;

  ApplicantsProvider({EmployersService? service})
    : _service = service ?? EmployersService();

  String selectedFilter = 'Received Interests';

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
    if (_items.isNotEmpty) return;
    refresh();
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

  void reset() {
    selectedFilter = 'Received Interests';

    isLoading = false;
    isLoadingMore = false;
    lastError = null;

    _page = 1;
    _total = 0;
    _items.clear();

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
        result = await _service.getEmployerReceivedApplicants(
          employerId,
          page: page,
          limit: _limit,
        );
        break;
      case 'Sent Interests':
        result = await _service.getEmployerSentApplicants(
          employerId,
          page: page,
          limit: _limit,
        );
        break;
      case 'Hired':
        result = await _service.getEmployerHiredApplicants(
          employerId,
          page: page,
          limit: _limit,
        );
        break;
      case 'Rejected':
        result = await _service.getEmployerRejectedApplicants(
          employerId,
          page: page,
          limit: _limit,
        );
        break;
      default:
        result = await _service.getEmployerApplicants(
          employerId,
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
