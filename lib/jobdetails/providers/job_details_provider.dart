import 'package:flutter/widgets.dart';

import '../../jobs/services/jobs_service.dart';
import '../../utils/custom_exception.dart';
import '../../utils/result.dart';
import '../models/job_detail_dto.dart';
import '../services/job_details_service.dart';

class JobDetailsProvider extends ChangeNotifier {
  final JobDetailsService _service;
  final JobsService _jobsService;

  bool isLoading = false;
  bool isActionLoading = false;

  CustomException? lastError;
  JobDetailDto? detail;

  JobDetailsProvider({JobDetailsService? service, JobsService? jobsService})
    : _service = service ?? JobDetailsService(),
      _jobsService = jobsService ?? JobsService();

  Future<void> fetch({required int jobId, required int employeeId}) async {
    isLoading = true;
    lastError = null;
    notifyListeners();

    final result = await _service.getJobDetail(
      jobId: jobId,
      employeeId: employeeId,
    );

    switch (result) {
      case Success(value: final data):
        detail = data;
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> unlockContact({
    required int jobId,
    required int employeeId,
  }) async {
    isActionLoading = true;
    lastError = null;
    notifyListeners();

    final result = await _service.unlockJobContact(
      jobId: jobId,
      employeeId: employeeId,
    );

    bool ok = false;
    switch (result) {
      case Success():
        ok = true;
        break;
      case Failure(exception: final e):
        lastError = e;
        ok = false;
        break;
    }

    isActionLoading = false;
    notifyListeners();

    if (ok) {
      await fetch(jobId: jobId, employeeId: employeeId);
    }

    return ok;
  }

  Future<bool> sendInterest({
    required int jobId,
    required int employeeId,
  }) async {
    isActionLoading = true;
    lastError = null;
    notifyListeners();

    final result = await _service.sendJobInterest(
      jobId: jobId,
      employeeId: employeeId,
    );

    bool ok = false;
    switch (result) {
      case Success():
        ok = true;
        break;
      case Failure(exception: final e):
        lastError = e;
        ok = false;
        break;
    }

    isActionLoading = false;
    notifyListeners();

    if (ok) {
      await fetch(jobId: jobId, employeeId: employeeId);
    }

    return ok;
  }

  Future<bool> unlockApplicationOtp({
    required int jobId,
    required int employeeId,
  }) async {
    isActionLoading = true;
    lastError = null;
    notifyListeners();

    final result = await _service.unlockApplicationOtp(
      jobId: jobId,
      employeeId: employeeId,
    );

    bool ok = false;
    switch (result) {
      case Success():
        ok = true;
        break;
      case Failure(exception: final e):
        lastError = e;
        ok = false;
        break;
    }

    isActionLoading = false;
    notifyListeners();

    if (ok) {
      await fetch(jobId: jobId, employeeId: employeeId);
    }

    return ok;
  }

  Future<bool> reportJob({
    required int jobId,
    required int employeeId,
    required int reasonId,
    String? description,
  }) async {
    isActionLoading = true;
    lastError = null;
    notifyListeners();

    final result = await _service.reportJob(
      jobId: jobId,
      employeeId: employeeId,
      reasonId: reasonId,
      description: description,
    );

    bool ok = false;
    switch (result) {
      case Success():
        ok = true;
        break;
      case Failure(exception: final e):
        lastError = e;
        ok = false;
        break;
    }

    isActionLoading = false;
    notifyListeners();

    if (ok) {
      await fetch(jobId: jobId, employeeId: employeeId);
    }

    return ok;
  }

  Future<void> toggleWishlist({
    required int jobId,
    required int employeeId,
  }) async {
    final previous = detail?.isInWishlist ?? false;
    final optimistic = !previous;

    if (detail != null) {
      detail = detail!.copyWith(isInWishlist: optimistic);
      notifyListeners();
    }

    final result = await _jobsService.toggleWishlist(
      jobId: jobId,
      employeeId: employeeId,
    );

    switch (result) {
      case Success(value: final serverState):
        lastError = null;
        final next = serverState ?? optimistic;
        if (detail != null) {
          detail = detail!.copyWith(isInWishlist: next);
        }
        break;
      case Failure(exception: final e):
        lastError = e;
        if (detail != null) {
          detail = detail!.copyWith(isInWishlist: previous);
        }
        break;
    }

    notifyListeners();
  }

  Future<bool> saveContactCallExperience({
    required int jobId,
    required int employeeId,
    int? callExperienceId,
    String? review,
  }) async {
    isActionLoading = true;
    lastError = null;
    notifyListeners();

    final result = await _service.saveContactCallExperience(
      jobId: jobId,
      employeeId: employeeId,
      callExperienceId: callExperienceId,
      review: review,
    );

    bool ok = false;
    switch (result) {
      case Success():
        ok = true;
        break;
      case Failure(exception: final e):
        lastError = e;
        ok = false;
        break;
    }

    isActionLoading = false;
    notifyListeners();

    if (ok) {
      await fetch(jobId: jobId, employeeId: employeeId);
    }

    return ok;
  }
}
