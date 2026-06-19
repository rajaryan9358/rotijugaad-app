import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../utils/custom_exception.dart';
import '../../utils/result.dart';
import '../models/get_all_jobs_request.dart';
import '../models/get_all_jobs_response.dart';
import '../models/job_dto.dart';
import '../services/jobs_service.dart';

class JobsProvider extends ChangeNotifier {
  final JobsService _service;

  bool isLoadingAll = false;
  bool isLoadingRecommended = false;
  bool isLoadingInterviewerOtp = false;
  CustomException? lastError;

  GetAllJobsResponse? allJobs;
  List<JobDto> recommendedJobs = const [];

  JobsProvider({JobsService? service}) : _service = service ?? JobsService();

  void _notifySafely() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (hasListeners == false) return;
        super.notifyListeners();
      });
      return;
    }

    super.notifyListeners();
  }

  void clearError() {
    lastError = null;
    _notifySafely();
  }

  Future<void> fetchAllJobs({required GetAllJobsRequest request}) async {
    isLoadingAll = true;
    lastError = null;
    _notifySafely();

    final result = await _service.getAllJobs(request: request);

    switch (result) {
      case Success(value: final resp):
        allJobs = resp;
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    isLoadingAll = false;
    _notifySafely();
  }

  Future<void> fetchRecommendedJobs(
    int employeeId, {
    GetAllJobsRequest? request,
  }) async {
    isLoadingRecommended = true;
    lastError = null;
    _notifySafely();

    final result = await _service.getRecommendedJobs(
      employeeId,
      request: request,
    );

    switch (result) {
      case Success(value: final resp):
        recommendedJobs = resp.jobs;
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    isLoadingRecommended = false;
    _notifySafely();
  }

  JobDto? _findInAll(int jobId) {
    final list = allJobs?.jobs;
    if (list == null) return null;
    for (final j in list) {
      if (j.id == jobId) return j;
    }
    return null;
  }

  JobDto? _findInRecommended(int jobId) {
    for (final j in recommendedJobs) {
      if (j.id == jobId) return j;
    }
    return null;
  }

  void _setWishlistForJob(int jobId, bool value) {
    final currentAll = allJobs;
    if (currentAll != null) {
      final updatedJobs = currentAll.jobs
          .map((j) => j.id == jobId ? j.copyWith(isInWishlist: value) : j)
          .toList(growable: false);

      allJobs = GetAllJobsResponse(
        page: currentAll.page,
        limit: currentAll.limit,
        total: currentAll.total,
        jobs: updatedJobs,
      );
    }

    recommendedJobs = recommendedJobs
        .map((j) => j.id == jobId ? j.copyWith(isInWishlist: value) : j)
        .toList(growable: false);
  }

  Future<void> toggleWishlist({
    required int jobId,
    required int employeeId,
  }) async {
    final previous =
        _findInAll(jobId)?.isInWishlist ??
        _findInRecommended(jobId)?.isInWishlist ??
        false;

    final optimistic = !previous;
    lastError = null;
    _setWishlistForJob(jobId, optimistic);
    _notifySafely();

    final result = await _service.toggleWishlist(
      jobId: jobId,
      employeeId: employeeId,
    );

    switch (result) {
      case Success(value: final serverState):
        final next = serverState ?? optimistic;
        _setWishlistForJob(jobId, next);
        break;
      case Failure(exception: final e):
        lastError = e;
        _setWishlistForJob(jobId, previous);
        break;
    }

    _notifySafely();
  }

  Future<int?> sendInterviewerContactOtp({
    required int employerId,
    required String interviewerContact,
  }) async {
    isLoadingInterviewerOtp = true;
    lastError = null;
    _notifySafely();

    final result = await _service.sendInterviewerContactOtp(
      employerId: employerId,
      interviewerContact: interviewerContact,
    );

    int? verificationId;
    switch (result) {
      case Success(value: final json):
        dynamic v = json['verification_id'] ?? json['verificationId'];

        // ApiService already passes the payload `data` map to fromJson.
        // Backwards-compat: accept nested `data` in case some endpoint wraps.
        if (v == null && json['data'] is Map) {
          final m = (json['data'] as Map).cast<String, dynamic>();
          v = m['verification_id'] ?? m['verificationId'];
        }

        if (v is int) {
          verificationId = v;
        } else {
          verificationId = int.tryParse(v?.toString() ?? '');
        }
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    isLoadingInterviewerOtp = false;
    _notifySafely();
    return verificationId;
  }

  Future<bool> verifyInterviewerContactOtp({
    required int employerId,
    required String interviewerContact,
    required String otp,
    int? verificationId,
  }) async {
    isLoadingInterviewerOtp = true;
    lastError = null;
    _notifySafely();

    final result = await _service.verifyInterviewerContactOtp(
      employerId: employerId,
      interviewerContact: interviewerContact,
      otp: otp,
      verificationId: verificationId,
    );

    var ok = false;
    switch (result) {
      case Success():
        ok = true;
        break;
      case Failure(exception: final e):
        lastError = e;
        ok = false;
        break;
    }

    isLoadingInterviewerOtp = false;
    _notifySafely();
    return ok;
  }

  void reset() {
    isLoadingAll = false;
    isLoadingRecommended = false;
    isLoadingInterviewerOtp = false;
    lastError = null;

    allJobs = null;
    recommendedJobs = const [];

    _notifySafely();
  }
}
