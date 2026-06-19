import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter/scheduler.dart";
import "package:flutter/widgets.dart";

import "../../masters/models/job_profile_dtos.dart";
import "../../profile/utils/profile_status_helper.dart";
import "../../utils/custom_exception.dart";
import "../../utils/result.dart";
import "../../utils/shared_pref.dart";
import "../../utils/location_service.dart";
import "../models/employee_dtos.dart";
import "../services/employees_service.dart";

class EmployeesProvider extends ChangeNotifier {
  final EmployeesService _service;

  bool isLoading = false;
  CustomException? lastError;

  EmployeeDto? personalInfo;
  EmployeeDto? employeeDetail;
  List<JobProfileDto> jobProfiles = const [];
  List<EmployeeExperienceDto> experiences = const [];
  List<EmployeeDocumentDto> documents = const [];

  EmployeesProvider({EmployeesService? service})
    : _service = service ?? EmployeesService();

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

  Future<void> _persistAuthProfile(EmployeeDto emp) async {
    await SharedPrefUtils.saveJson(SharedPrefUtils.AUTH_PROFILE_JSON, emp.raw);
    await SharedPrefUtils.saveBool(
      SharedPrefUtils.AUTH_PROFILE_COMPLETED,
      ProfileStatusHelper.isProfileCompleted(
        user: SharedPrefUtils.readJson(SharedPrefUtils.AUTH_USER_JSON),
        profile: emp.raw,
      ),
    );
  }

  Future<EmployeeDto?> _refreshEmployeeDetailNoNotify(int employeeId) async {
    final result = await _service.getEmployeeById(employeeId);

    switch (result) {
      case Success(value: final resp):
        employeeDetail = resp.employee;
        personalInfo = resp.employee;
        await _persistAuthProfile(resp.employee);
        return resp.employee;
      case Failure(exception: final e):
        lastError = e;
        // If the employee record doesn't exist on the server, clear the stale
        // cached profile so the jobs/profile screens don't read a phantom
        // verification_status from a previous session.
        if (e.code == 'FC_02') {
          await SharedPrefUtils.saveStr(SharedPrefUtils.AUTH_PROFILE_JSON, '');
          await SharedPrefUtils.saveBool(
            SharedPrefUtils.AUTH_PROFILE_COMPLETED,
            false,
          );
        }
        return null;
    }
  }

  Future<void> _refreshExperiencesNoNotify(int employeeId) async {
    final result = await _service.getExperiences(employeeId);

    switch (result) {
      case Success(value: final resp):
        experiences = resp.experiences;
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }
  }

  Future<void> _refreshDocumentsNoNotify(int employeeId) async {
    final result = await _service.getDocuments(employeeId);

    switch (result) {
      case Success(value: final resp):
        documents = resp.documents;
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }
  }

  Future<void> refreshEmployeeDetail(int employeeId) async {
    isLoading = true;
    lastError = null;
    _notifySafely();

    await _refreshEmployeeDetailNoNotify(employeeId);

    isLoading = false;
    _notifySafely();
  }

  Future<void> fetchPersonalInfo(int userId) async {
    isLoading = true;
    lastError = null;
    _notifySafely();

    final result = await _service.getPersonalInfo(userId);

    switch (result) {
      case Success(value: final emp):
        personalInfo = emp;
        employeeDetail = emp;
        await _persistAuthProfile(emp);
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    isLoading = false;
    _notifySafely();
  }

  Future<EmployeeDto?> savePersonalInfo({
    required int userId,
    required Map<String, dynamic> body,
  }) async {
    isLoading = true;
    lastError = null;
    _notifySafely();

    final payload = Map<String, dynamic>.from(body);

    final shouldCaptureLocation =
        !payload.containsKey('lat') && !payload.containsKey('lng');

    if (shouldCaptureLocation) {
      try {
        final point = await LocationService.getCurrentLatLng();
        if (point != null) {
          payload['lat'] = point.lat;
          payload['lng'] = point.lng;
        }
      } catch (_) {
        // Ignore location failures and continue saving.
      }
    }

    final result = await _service.savePersonalInfo(
      userId: userId,
      body: payload,
    );

    EmployeeDto? updated;
    switch (result) {
      case Success(value: final resp):
        updated = resp.employee;
        personalInfo = updated;
        employeeDetail = updated;
        await _persistAuthProfile(resp.employee);
        if (updated.id > 0) {
          updated = await _refreshEmployeeDetailNoNotify(updated.id) ?? updated;
        }
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    isLoading = false;
    _notifySafely();
    return updated;
  }

  Future<void> fetchJobProfiles(int employeeId) async {
    isLoading = true;
    lastError = null;
    _notifySafely();

    final result = await _service.getJobProfiles(employeeId);

    switch (result) {
      case Success(value: final resp):
        jobProfiles = resp.profiles;
        await _refreshEmployeeDetailNoNotify(employeeId);
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    isLoading = false;
    _notifySafely();
  }

  Future<void> saveJobProfiles({
    required int employeeId,
    required List<int> jobProfileIds,
  }) async {
    isLoading = true;
    lastError = null;
    _notifySafely();

    final result = await _service.saveJobProfiles(
      employeeId: employeeId,
      jobProfileIds: jobProfileIds,
    );

    switch (result) {
      case Success(value: final resp):
        jobProfiles = resp.profiles;
        await _refreshEmployeeDetailNoNotify(employeeId);
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    isLoading = false;
    _notifySafely();
  }

  Future<void> fetchExperiences(int employeeId) async {
    isLoading = true;
    lastError = null;
    _notifySafely();

    final result = await _service.getExperiences(employeeId);

    switch (result) {
      case Success(value: final resp):
        experiences = resp.experiences;
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    isLoading = false;
    _notifySafely();
  }

  Future<EmployeeExperienceDto?> fetchExperienceById(int experienceId) async {
    isLoading = true;
    lastError = null;
    _notifySafely();

    final result = await _service.getExperienceById(experienceId);

    EmployeeExperienceDto? exp;
    switch (result) {
      case Success(value: final e):
        exp = e;
        break;
      case Failure(exception: final err):
        lastError = err;
        break;
    }

    isLoading = false;
    _notifySafely();
    return exp;
  }

  Future<EmployeeExperienceDto?> createExperience({
    required int employeeId,
    required Map<String, dynamic> fields,
    File? certificateFile,
  }) async {
    isLoading = true;
    lastError = null;
    _notifySafely();

    final result = await _service.createExperience(
      employeeId: employeeId,
      fields: fields,
      certificateFile: certificateFile,
    );

    EmployeeExperienceDto? created;
    switch (result) {
      case Success(value: final exp):
        created = exp;
        await _refreshExperiencesNoNotify(employeeId);
        await _refreshEmployeeDetailNoNotify(employeeId);
        experiences = [
          created,
          ...experiences.where((e) => e.id != created!.id),
        ];
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    isLoading = false;
    _notifySafely();
    return created;
  }

  Future<EmployeeExperienceDto?> updateExperience({
    required int employeeId,
    required int experienceId,
    required Map<String, dynamic> fields,
    File? certificateFile,
  }) async {
    isLoading = true;
    lastError = null;
    _notifySafely();

    final result = await _service.updateExperience(
      employeeId: employeeId,
      experienceId: experienceId,
      fields: fields,
      certificateFile: certificateFile,
    );

    EmployeeExperienceDto? updated;
    switch (result) {
      case Success(value: final exp):
        updated = exp;
        await _refreshExperiencesNoNotify(employeeId);
        await _refreshEmployeeDetailNoNotify(employeeId);
        experiences = [
          updated,
          ...experiences.where((e) => e.id != updated!.id),
        ];
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    isLoading = false;
    _notifySafely();
    return updated;
  }

  Future<void> deleteExperience(int experienceId, {int? employeeId}) async {
    isLoading = true;
    lastError = null;
    _notifySafely();

    final result = await _service.deleteExperience(experienceId);

    switch (result) {
      case Success():
        experiences = experiences.where((e) => e.id != experienceId).toList();
        if (employeeId != null) {
          await _refreshExperiencesNoNotify(employeeId);
          await _refreshEmployeeDetailNoNotify(employeeId);
        }
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    isLoading = false;
    _notifySafely();
  }

  Future<void> fetchDocuments(int employeeId) async {
    isLoading = true;
    lastError = null;
    _notifySafely();

    final result = await _service.getDocuments(employeeId);

    switch (result) {
      case Success(value: final resp):
        documents = resp.documents;
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    isLoading = false;
    _notifySafely();
  }

  Future<EmployeeDocumentDto?> fetchDocumentById(int documentId) async {
    isLoading = true;
    lastError = null;
    _notifySafely();

    final result = await _service.getDocumentById(documentId);

    EmployeeDocumentDto? doc;
    switch (result) {
      case Success(value: final d):
        doc = d;
        break;
      case Failure(exception: final err):
        lastError = err;
        break;
    }

    isLoading = false;
    _notifySafely();
    return doc;
  }

  Future<bool> submitProfileForReview(int employeeId) async {
    isLoading = true;
    lastError = null;
    _notifySafely();

    final result = await _service.submitProfileForReview(employeeId);

    var submitted = false;
    switch (result) {
      case Success():
        submitted = true;
        await _refreshEmployeeDetailNoNotify(employeeId);
        await _refreshDocumentsNoNotify(employeeId);
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    isLoading = false;
    _notifySafely();
    return submitted;
  }

  Future<EmployeeDocumentDto?> uploadDocument({
    required int employeeId,
    required int documentTypeId,
    required File file,
  }) async {
    isLoading = true;
    lastError = null;
    _notifySafely();

    final result = await _service.uploadDocument(
      employeeId: employeeId,
      documentTypeId: documentTypeId,
      file: file,
    );

    EmployeeDocumentDto? created;
    switch (result) {
      case Success(value: final doc):
        created = doc;
        await _refreshDocumentsNoNotify(employeeId);
        await _refreshEmployeeDetailNoNotify(employeeId);
        documents = [created, ...documents.where((d) => d.id != created!.id)];
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    isLoading = false;
    _notifySafely();
    return created;
  }

  Future<EmployeeDocumentDto?> updateDocument({
    required int employeeId,
    required int documentId,
    int? documentTypeId,
    File? file,
  }) async {
    isLoading = true;
    lastError = null;
    _notifySafely();

    final result = await _service.updateDocument(
      employeeId: employeeId,
      documentId: documentId,
      documentTypeId: documentTypeId,
      file: file,
    );

    EmployeeDocumentDto? updated;
    switch (result) {
      case Success(value: final doc):
        updated = doc;
        await _refreshDocumentsNoNotify(employeeId);
        await _refreshEmployeeDetailNoNotify(employeeId);
        documents = [updated, ...documents.where((d) => d.id != updated!.id)];
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    isLoading = false;
    _notifySafely();
    return updated;
  }

  Future<void> deleteDocument(int documentId, {int? employeeId}) async {
    isLoading = true;
    lastError = null;
    _notifySafely();

    final result = await _service.deleteDocument(documentId);

    switch (result) {
      case Success():
        documents = documents.where((d) => d.id != documentId).toList();
        if (employeeId != null) {
          await _refreshDocumentsNoNotify(employeeId);
          await _refreshEmployeeDetailNoNotify(employeeId);
        }
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    isLoading = false;
    _notifySafely();
  }

  Future<AadhaarSendOtpResponse?> sendAadhaarOtp({
    required int employeeId,
    required String aadhaarNumber,
  }) async {
    isLoading = true;
    lastError = null;
    _notifySafely();

    final result = await _service.sendAadhaarOtp(
      employeeId: employeeId,
      aadhaarNumber: aadhaarNumber,
    );

    AadhaarSendOtpResponse? resp;
    switch (result) {
      case Success(value: final r):
        resp = r;
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    isLoading = false;
    _notifySafely();
    return resp;
  }

  Future<EmployeeDto?> verifyAadhaarOtp({
    required int employeeId,
    required String aadhaarNumber,
    required String otp,
  }) async {
    isLoading = true;
    lastError = null;
    _notifySafely();

    final result = await _service.verifyAadhaarOtp(
      employeeId: employeeId,
      aadhaarNumber: aadhaarNumber,
      otp: otp,
    );

    EmployeeDto? updated;
    switch (result) {
      case Success(value: final emp):
        updated = emp;
        personalInfo = emp;
        employeeDetail = emp;
        await _persistAuthProfile(emp);
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    isLoading = false;
    _notifySafely();
    return updated;
  }

  Future<EmployeeDto?> uploadSelfie({
    required int employeeId,
    required File file,
  }) async {
    isLoading = true;
    lastError = null;
    _notifySafely();

    final result = await _service.uploadSelfie(
      employeeId: employeeId,
      file: file,
    );

    EmployeeDto? updated;
    switch (result) {
      case Success(value: final emp):
        updated = emp;
        personalInfo = emp;
        employeeDetail = emp;
        await _persistAuthProfile(emp);
        break;
      case Failure(exception: final e):
        lastError = e;
        break;
    }

    isLoading = false;
    _notifySafely();
    return updated;
  }

  void reset() {
    isLoading = false;
    lastError = null;

    personalInfo = null;
    employeeDetail = null;
    jobProfiles = const [];
    experiences = const [];
    documents = const [];

    _notifySafely();
  }
}
