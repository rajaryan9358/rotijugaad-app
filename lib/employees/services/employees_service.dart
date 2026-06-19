import "dart:io";

import "../../network/api_client.dart";
import "../../network/api_service.dart";
import "../../utils/custom_exception.dart";
import "../../utils/result.dart";
import "../models/employee_dtos.dart";
import "../models/hired_jobs_dtos.dart";

class EmployeesService {
  final ApiService _api;

  EmployeesService({ApiService? api}) : _api = api ?? ApiService();

  Future<Result<EmployeeDetailResponse, CustomException>> getEmployeeById(
    int id,
  ) {
    return _api.getJson<EmployeeDetailResponse>(
      endpoint: ApiClient.employeeById(id),
      fromJson: (json) => EmployeeDetailResponse.fromJson(json),
    );
  }

  Future<Result<EmployeeDto, CustomException>> getPersonalInfo(int userId) {
    return _api.getJson<EmployeeDto>(
      endpoint: ApiClient.employeePersonalInfo(userId),
      fromJson: (json) => EmployeeDto.fromJson(json),
    );
  }

  Future<Result<EmployeeDetailResponse, CustomException>> savePersonalInfo({
    required int userId,
    required Map<String, dynamic> body,
  }) {
    return _api.postJson<EmployeeDetailResponse>(
      endpoint: ApiClient.employeePersonalInfo(userId),
      body: body,
      fromJson: (json) => EmployeeDetailResponse.fromJson(json),
    );
  }

  Future<Result<EmployeeJobProfilesResponse, CustomException>> getJobProfiles(
    int employeeId,
  ) {
    return _api.getJson<EmployeeJobProfilesResponse>(
      endpoint: ApiClient.employeeJobProfiles(employeeId),
      fromJson: (json) => EmployeeJobProfilesResponse.fromJson(json),
    );
  }

  Future<Result<EmployeeJobProfilesResponse, CustomException>> saveJobProfiles({
    required int employeeId,
    required List<int> jobProfileIds,
  }) {
    return _api.postJson<EmployeeJobProfilesResponse>(
      endpoint: ApiClient.employeeJobProfiles(employeeId),
      body: {"job_profile_ids": jobProfileIds},
      fromJson: (json) => EmployeeJobProfilesResponse.fromJson(json),
    );
  }

  Future<Result<EmployeeExperienceDto, CustomException>> getExperienceById(
    int experienceId,
  ) {
    return _api.getJson<EmployeeExperienceDto>(
      endpoint: ApiClient.employeeExperienceById(experienceId),
      fromJson: (json) => EmployeeExperienceDto.fromJson(json),
    );
  }

  Future<Result<EmployeeExperiencesResponse, CustomException>> getExperiences(
    int employeeId,
  ) {
    return _api.getJson<EmployeeExperiencesResponse>(
      endpoint: ApiClient.employeeExperiences(employeeId),
      fromJson: (json) => EmployeeExperiencesResponse.fromJson(json),
    );
  }

  Future<Result<EmployeeExperienceDto, CustomException>> createExperience({
    required int employeeId,
    required Map<String, dynamic> fields,
    File? certificateFile,
  }) {
    return _api.postMultipart<EmployeeExperienceDto>(
      endpoint: ApiClient.employeeExperiences(employeeId),
      fields: fields,
      files: certificateFile == null
          ? null
          : {"experience_certificate": certificateFile},
      fromJson: (json) => EmployeeExperienceDto.fromJson(json),
    );
  }

  Future<Result<EmployeeExperienceDto, CustomException>> updateExperience({
    required int employeeId,
    required int experienceId,
    required Map<String, dynamic> fields,
    File? certificateFile,
  }) {
    return _api.putMultipart<EmployeeExperienceDto>(
      endpoint: ApiClient.employeeExperienceById(experienceId),
      fields: fields,
      files: certificateFile == null
          ? null
          : {"experience_certificate": certificateFile},
      fromJson: (json) => EmployeeExperienceDto.fromJson(json),
    );
  }

  Future<Result<DeleteResponse, CustomException>> deleteExperience(
    int experienceId,
  ) {
    return _api.deleteJson<DeleteResponse>(
      endpoint: ApiClient.employeeExperienceById(experienceId),
      fromJson: (json) => DeleteResponse.fromJson(json),
    );
  }

  Future<Result<EmployeeDocumentDto, CustomException>> getDocumentById(
    int documentId,
  ) {
    return _api.getJson<EmployeeDocumentDto>(
      endpoint: ApiClient.employeeDocumentById(documentId),
      fromJson: (json) => EmployeeDocumentDto.fromJson(json),
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>> submitProfileForReview(
    int employeeId,
  ) {
    return _api.postJson<Map<String, dynamic>>(
      endpoint: ApiClient.employeeSubmitForReview(employeeId),
      body: const {},
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }

  Future<Result<EmployeeDocumentsResponse, CustomException>> getDocuments(
    int employeeId,
  ) {
    return _api.getJson<EmployeeDocumentsResponse>(
      endpoint: ApiClient.employeeDocuments(employeeId),
      fromJson: (json) => EmployeeDocumentsResponse.fromJson(json),
    );
  }

  Future<Result<EmployeeDocumentDto, CustomException>> uploadDocument({
    required int employeeId,
    required int documentTypeId,
    required File file,
  }) {
    return _api.postMultipart<EmployeeDocumentDto>(
      endpoint: ApiClient.employeeDocuments(employeeId),
      fields: {"document_type_id": documentTypeId},
      files: {"document": file},
      fromJson: (json) => EmployeeDocumentDto.fromJson(json),
    );
  }

  Future<Result<EmployeeDocumentDto, CustomException>> updateDocument({
    required int employeeId,
    required int documentId,
    int? documentTypeId,
    File? file,
  }) {
    return _api.putMultipart<EmployeeDocumentDto>(
      endpoint: ApiClient.employeeDocumentById(documentId),
      fields: {if (documentTypeId != null) "document_type_id": documentTypeId},
      files: file == null ? null : {"document": file},
      fromJson: (json) => EmployeeDocumentDto.fromJson(json),
    );
  }

  Future<Result<DeleteResponse, CustomException>> deleteDocument(
    int documentId,
  ) {
    return _api.deleteJson<DeleteResponse>(
      endpoint: ApiClient.employeeDocumentById(documentId),
      fromJson: (json) => DeleteResponse.fromJson(json),
    );
  }

  Future<Result<AadhaarSendOtpResponse, CustomException>> sendAadhaarOtp({
    required int employeeId,
    required String aadhaarNumber,
  }) {
    return _api.postJson<AadhaarSendOtpResponse>(
      endpoint: ApiClient.employeeAadharSendOtp(employeeId),
      body: {"aadhar_number": aadhaarNumber},
      fromJson: (json) => AadhaarSendOtpResponse.fromJson(json),
    );
  }

  Future<Result<EmployeeDto, CustomException>> verifyAadhaarOtp({
    required int employeeId,
    required String aadhaarNumber,
    required String otp,
  }) {
    return _api.postJson<EmployeeDto>(
      endpoint: ApiClient.employeeAadharVerifyOtp(employeeId),
      body: {"aadhar_number": aadhaarNumber, "otp": otp},
      fromJson: (json) => EmployeeDto.fromJson(json),
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>> sendMobileChangeOtp({
    required int employeeId,
    required String mobile,
  }) {
    return _api.postJson<Map<String, dynamic>>(
      endpoint: ApiClient.employeeAadharSendOtp(employeeId),
      body: {"mobile": mobile},
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>> verifyMobileChangeOtp({
    required int employeeId,
    required String mobile,
    required String otp,
  }) {
    return _api.postJson<Map<String, dynamic>>(
      endpoint: ApiClient.employeeAadharVerifyOtp(employeeId),
      body: {"mobile": mobile, "otp": otp},
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }

  Future<Result<EmployeeDto, CustomException>> uploadSelfie({
    required int employeeId,
    required File file,
  }) {
    return _api.postMultipart<EmployeeDto>(
      endpoint: ApiClient.employeeSelfie(employeeId),
      fields: const {},
      files: {"selfie": file},
      fromJson: (json) => EmployeeDto.fromJson(json),
    );
  }

  Future<Result<EmployeeHiredJobsPageDto, CustomException>> getHiredJobs({
    required int employeeId,
    int page = 1,
    int limit = 50,
  }) {
    return _api.getJson<EmployeeHiredJobsPageDto>(
      endpoint: ApiClient.employeeHiredJobs(employeeId),
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      fromJson: (json) => EmployeeHiredJobsPageDto.fromJson(json),
    );
  }
}
