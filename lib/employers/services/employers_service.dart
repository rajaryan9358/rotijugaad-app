import 'dart:io';

import "../../network/api_client.dart";
import "../../network/api_service.dart";
import "../../applicants/models/applicants_models.dart";
import "../../employerjobs/models/employer_jobs_response.dart";
import "../../candidatedetail/models/send_interest_jobs_models.dart";
import "../../candidates/models/candidates_responses.dart";
import "../../utils/custom_exception.dart";
import "../../utils/result.dart";

class EmployersService {
  final ApiService _api;

  EmployersService({ApiService? api}) : _api = api ?? ApiService();

  Future<Result<Map<String, dynamic>, CustomException>> getEmployerById(
    int id,
  ) {
    return _api.getJson<Map<String, dynamic>>(
      endpoint: ApiClient.employerById(id),
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>> getEmployerProfile(
    int employerId,
  ) {
    return _api.getJson<Map<String, dynamic>>(
      endpoint: ApiClient.employerProfile(employerId),
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }

  Future<Result<EmployerJobsResponse, CustomException>> getEmployerJobs(
    int employerId, {
    int page = 1,
    int limit = 50,
  }) {
    return _api.getJson<EmployerJobsResponse>(
      endpoint: ApiClient.employerJobs(employerId),
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      fromJson: (json) => EmployerJobsResponse.fromJson(json),
    );
  }

  Future<Result<ApplicantsPageResponse, CustomException>> getEmployerApplicants(
    int employerId, {
    int page = 1,
    int limit = 20,
  }) {
    return _api.getJson<ApplicantsPageResponse>(
      endpoint: ApiClient.employerApplicants(employerId),
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      fromJson: (json) => ApplicantsPageResponse.fromJson(json),
    );
  }

  Future<Result<ApplicantsPageResponse, CustomException>>
  getEmployerReceivedApplicants(
    int employerId, {
    int page = 1,
    int limit = 20,
  }) {
    return _api.getJson<ApplicantsPageResponse>(
      endpoint: ApiClient.employerApplicantsReceived(employerId),
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      fromJson: (json) => ApplicantsPageResponse.fromJson(json),
    );
  }

  Future<Result<ApplicantsPageResponse, CustomException>>
  getEmployerSentApplicants(int employerId, {int page = 1, int limit = 20}) {
    return _api.getJson<ApplicantsPageResponse>(
      endpoint: ApiClient.employerApplicantsSent(employerId),
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      fromJson: (json) => ApplicantsPageResponse.fromJson(json),
    );
  }

  Future<Result<ApplicantsPageResponse, CustomException>>
  getEmployerShortlistedApplicants(
    int employerId, {
    int page = 1,
    int limit = 20,
  }) {
    return _api.getJson<ApplicantsPageResponse>(
      endpoint: ApiClient.employerApplicantsShortlisted(employerId),
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      fromJson: (json) => ApplicantsPageResponse.fromJson(json),
    );
  }

  Future<Result<CandidatesPageResponse, CustomException>>
  getEmployerShortlistedCandidates(
    int employerId, {
    int page = 1,
    int limit = 20,
  }) {
    return _api.getJson<CandidatesPageResponse>(
      endpoint: ApiClient.employerShortlistedCandidates(employerId),
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      fromJson: (json) => CandidatesPageResponse.fromJson(json),
    );
  }

  Future<Result<ApplicantsPageResponse, CustomException>>
  getEmployerHiredApplicants(int employerId, {int page = 1, int limit = 20}) {
    return _api.getJson<ApplicantsPageResponse>(
      endpoint: ApiClient.employerApplicantsHired(employerId),
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      fromJson: (json) => ApplicantsPageResponse.fromJson(json),
    );
  }

  Future<Result<ApplicantsPageResponse, CustomException>>
  getEmployerRejectedApplicants(
    int employerId, {
    int page = 1,
    int limit = 20,
  }) {
    return _api.getJson<ApplicantsPageResponse>(
      endpoint: ApiClient.employerApplicantsRejected(employerId),
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      fromJson: (json) => ApplicantsPageResponse.fromJson(json),
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>>
  saveEmployerPersonalInfo(int userId, Map<String, dynamic> body) {
    return _api.putJson<Map<String, dynamic>>(
      endpoint: ApiClient.employerPersonalInfo(userId),
      body: body,
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>> sendAadhaarOtp({
    required int employerId,
    required String aadhaarNumber,
  }) {
    return _api.postJson<Map<String, dynamic>>(
      endpoint: ApiClient.employerAadharSendOtp(employerId),
      body: {'aadhar_number': aadhaarNumber},
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>> verifyAadhaarOtp({
    required int employerId,
    required String aadhaarNumber,
    required String otp,
  }) {
    return _api.postJson<Map<String, dynamic>>(
      endpoint: ApiClient.employerAadharVerifyOtp(employerId),
      body: {'aadhar_number': aadhaarNumber, 'otp': otp},
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>> sendMobileChangeOtp({
    required int employerId,
    required String mobile,
  }) {
    return _api.postJson<Map<String, dynamic>>(
      endpoint: ApiClient.employerAadharSendOtp(employerId),
      body: {'mobile': mobile},
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>> verifyMobileChangeOtp({
    required int employerId,
    required String mobile,
    required String otp,
  }) {
    return _api.postJson<Map<String, dynamic>>(
      endpoint: ApiClient.employerAadharVerifyOtp(employerId),
      body: {'mobile': mobile, 'otp': otp},
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>> uploadEmployerDocument({
    required int employerId,
    required File file,
  }) {
    return _api.postMultipart<Map<String, dynamic>>(
      endpoint: ApiClient.employerDocument(employerId),
      fields: const <String, dynamic>{},
      files: {'document': file},
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }

  Future<Result<EmployerSendInterestJobsResponse, CustomException>>
  getEmployerJobsForSendingInterest(
    int employerId,
    int candidateId, {
    int page = 1,
    int limit = 50,
  }) {
    return _api.getJson<EmployerSendInterestJobsResponse>(
      endpoint: ApiClient.employerCandidateJobsSendInterest(
        employerId,
        candidateId,
      ),
      queryParameters: {"page": page.toString(), "limit": limit.toString()},
      fromJson: (json) => EmployerSendInterestJobsResponse.fromJson(json),
    );
  }

  Future<Result<EmployerSendInterestJobsResponse, CustomException>>
  getEmployerJobsForShortlisting(
    int employerId,
    int candidateId, {
    int page = 1,
    int limit = 50,
  }) {
    return _api.getJson<EmployerSendInterestJobsResponse>(
      endpoint: ApiClient.employerCandidateJobsShortlist(
        employerId,
        candidateId,
      ),
      queryParameters: {"page": page.toString(), "limit": limit.toString()},
      fromJson: (json) => EmployerSendInterestJobsResponse.fromJson(json),
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>>
  shortlistCandidateForJobs({
    required int employerId,
    required int candidateId,
    required List<int> jobIds,
  }) {
    return _api.postJson<Map<String, dynamic>>(
      endpoint: ApiClient.employerCandidateShortlistPost,
      body: {
        "employerId": employerId,
        "candidateId": candidateId,
        "jobIds": jobIds,
      },
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>>
  sendInterestToCandidateForJobs({
    required int employerId,
    required int candidateId,
    required List<int> jobIds,
  }) {
    return _api.postJson<Map<String, dynamic>>(
      endpoint: ApiClient.employerCandidateSendInterestPost,
      body: {
        "employerId": employerId,
        "candidateId": candidateId,
        "jobIds": jobIds,
      },
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>>
  saveEmployerCandidateCallExperience({
    required int employerId,
    required int candidateId,
    int? callExperienceId,
    String? review,
  }) {
    final body = <String, dynamic>{
      "employer_id": employerId,
      "candidate_id": candidateId,
    };

    if (callExperienceId != null && callExperienceId > 0) {
      body["call_experience_id"] = callExperienceId;
    }
    final r = (review ?? "").trim();
    if (r.isNotEmpty) body["review"] = r;

    return _api.postJson<Map<String, dynamic>>(
      endpoint: ApiClient.employerCandidateCallExperience,
      body: body,
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>> updateApplicantStatus({
    required int employerId,
    required int jobInterestId,
    required String status,
    String? otp,
  }) {
    final body = <String, dynamic>{
      'job_interest_id': jobInterestId,
      'status': status,
    };

    final normalizedOtp = (otp ?? '').trim();
    if (normalizedOtp.isNotEmpty) {
      body['otp'] = normalizedOtp;
    }

    return _api.postJson<Map<String, dynamic>>(
      endpoint: ApiClient.employerApplicantsStatus(employerId),
      body: body,
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }
}
