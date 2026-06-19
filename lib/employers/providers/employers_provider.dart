import 'dart:io';

import "package:flutter/scheduler.dart";
import "package:flutter/widgets.dart";

import "../../employers/services/employers_service.dart";
import "../../profile/utils/profile_status_helper.dart";
import "../../utils/custom_exception.dart";
import "../../utils/result.dart";
import "../../utils/shared_pref.dart";

class EmployersProvider extends ChangeNotifier {
  final EmployersService _service;

  bool isLoading = false;
  CustomException? lastError;

  Map<String, dynamic>? employerDetail;

  EmployersProvider({EmployersService? service})
    : _service = service ?? EmployersService();

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

  void clearError() {
    lastError = null;
    _notifySafely();
  }

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  Future<void> _setEmployerFromResponse(Map<String, dynamic> json) async {
    final employer = json["employer"];
    final map = (employer is Map<String, dynamic>) ? employer : json;

    employerDetail = map;
    await SharedPrefUtils.saveJson(SharedPrefUtils.AUTH_PROFILE_JSON, map);

    final profileCompleted = ProfileStatusHelper.isProfileCompleted(
      user: SharedPrefUtils.readJson(SharedPrefUtils.AUTH_USER_JSON),
      profile: map,
    );
    await SharedPrefUtils.saveBool(
      SharedPrefUtils.AUTH_PROFILE_COMPLETED,
      profileCompleted,
    );

    final id = _asInt(map["id"] ?? map["employerId"]);
    if (id != null) {
      await SharedPrefUtils.saveInt("auth_employer_id", id);
    }
  }

  Future<void> refreshEmployerDetail(int employerId) async {
    isLoading = true;
    lastError = null;
    _notifySafely();

    final result = await _service.getEmployerById(employerId);
    switch (result) {
      case Success(value: final json):
        await _setEmployerFromResponse(json);
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    isLoading = false;
    _notifySafely();
  }

  Future<void> refreshEmployerProfile(int employerId) async {
    isLoading = true;
    lastError = null;
    _notifySafely();

    final result = await _service.getEmployerProfile(employerId);
    switch (result) {
      case Success(value: final json):
        await _setEmployerFromResponse(json);
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    isLoading = false;
    _notifySafely();
  }

  Future<bool> saveEmployerPersonalInfo(
    int userId,
    Map<String, dynamic> body,
  ) async {
    isLoading = true;
    lastError = null;
    _notifySafely();

    final result = await _service.saveEmployerPersonalInfo(userId, body);

    var ok = false;
    switch (result) {
      case Success(value: final json):
        await _setEmployerFromResponse(json);
        final employerId = _asInt(
          employerDetail?['id'] ??
              employerDetail?['employerId'] ??
              employerDetail?['employer_id'],
        );
        if (employerId != null && employerId > 0) {
          await refreshEmployerDetail(employerId);
          return true;
        }
        ok = true;
        break;
      case Failure(exception: final e):
        lastError = e;
        ok = false;
        break;
    }

    isLoading = false;
    _notifySafely();
    return ok;
  }

  Future<bool> sendAadhaarOtp({
    required int employerId,
    required String aadhaarNumber,
  }) async {
    isLoading = true;
    lastError = null;
    _notifySafely();

    final result = await _service.sendAadhaarOtp(
      employerId: employerId,
      aadhaarNumber: aadhaarNumber,
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

    isLoading = false;
    _notifySafely();
    return ok;
  }

  Future<bool> verifyAadhaarOtp({
    required int employerId,
    required String aadhaarNumber,
    required String otp,
  }) async {
    isLoading = true;
    lastError = null;
    _notifySafely();

    final result = await _service.verifyAadhaarOtp(
      employerId: employerId,
      aadhaarNumber: aadhaarNumber,
      otp: otp,
    );

    var ok = false;
    switch (result) {
      case Success(value: final json):
        await _setEmployerFromResponse(json);
        ok = true;
        break;
      case Failure(exception: final e):
        lastError = e;
        ok = false;
        break;
    }

    isLoading = false;
    _notifySafely();
    return ok;
  }

  Future<bool> uploadEmployerDocument({
    required int employerId,
    required File file,
  }) async {
    isLoading = true;
    lastError = null;
    _notifySafely();

    final result = await _service.uploadEmployerDocument(
      employerId: employerId,
      file: file,
    );

    var ok = false;
    switch (result) {
      case Success(value: final json):
        await _setEmployerFromResponse(json);
        ok = true;
        break;
      case Failure(exception: final e):
        lastError = e;
        ok = false;
        break;
    }

    isLoading = false;
    _notifySafely();
    return ok;
  }

  void reset() {
    isLoading = false;
    lastError = null;
    employerDetail = null;
    _notifySafely();
  }
}
