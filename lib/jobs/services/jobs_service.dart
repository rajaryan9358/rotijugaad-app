import '../../network/api_client.dart';
import '../../network/api_service.dart';
import '../../utils/custom_exception.dart';
import '../../utils/result.dart';
import '../../applicants/models/applicants_models.dart';
import '../models/get_all_jobs_request.dart';
import '../models/get_all_jobs_response.dart';
import '../models/recommended_jobs_response.dart';
import '../models/job_dto.dart';

class JobsService {
  final ApiService _api;

  JobsService({ApiService? api}) : _api = api ?? ApiService();

  Future<Result<GetAllJobsResponse, CustomException>> getAllJobs({
    required GetAllJobsRequest request,
  }) {
    return _api.postJson<GetAllJobsResponse>(
      endpoint: ApiClient.jobsGetAll,
      body: request.toJson(),
      fromJson: (json) => GetAllJobsResponse.fromJson(json),
    );
  }

  Future<Result<RecommendedJobsResponse, CustomException>> getRecommendedJobs(
    int employeeId, {
    GetAllJobsRequest? request,
  }) {
    if (request == null) {
      return _api.getJson<RecommendedJobsResponse>(
        endpoint: ApiClient.jobsRecommended(employeeId),
        fromJson: (json) => RecommendedJobsResponse.fromJson(json),
      );
    }

    final body = <String, dynamic>{
      ...request.toJson(),
      'employee_id': employeeId,
    };

    return _api.postJson<RecommendedJobsResponse>(
      endpoint: ApiClient.jobsRecommended(employeeId),
      body: body,
      fromJson: (json) => RecommendedJobsResponse.fromJson(json),
    );
  }

  static bool? _parseNullableBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    final s = v.toString().trim().toLowerCase();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0') return false;
    return null;
  }

  Future<Result<bool?, CustomException>> toggleWishlist({
    required int jobId,
    required int employeeId,
  }) {
    return _api.postJson<bool?>(
      endpoint: ApiClient.jobsWishlistToggle,
      body: {'job_id': jobId, 'employee_id': employeeId},
      fromJson: (json) {
        if (json == null) return null;

        dynamic direct =
            json['is_in_wishlist'] ??
            json['in_wishlist'] ??
            json['is_wishlisted'] ??
            json['wishlist'] ??
            json['status'];

        if (json['wishlist'] is Map) {
          final wish = (json['wishlist'] as Map).cast<String, dynamic>();
          direct =
              wish['is_in_wishlist'] ??
              wish['in_wishlist'] ??
              wish['is_wishlisted'] ??
              direct;
        }

        return _parseNullableBool(direct);
      },
    );
  }

  Future<Result<JobDto, CustomException>> getEmployerJobDetail({
    required int employerId,
    required int jobId,
  }) {
    return _api.getJson<JobDto>(
      endpoint: ApiClient.jobsEmployerDetail(employerId, jobId),
      fromJson: (json) => JobDto.fromJson(json),
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>>
  getEmployerJobDetailRaw({required int employerId, required int jobId}) {
    return _api.getJson<Map<String, dynamic>>(
      endpoint: ApiClient.jobsEmployerDetail(employerId, jobId),
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }

  Future<Result<ApplicantsPageResponse, CustomException>>
  getEmployerJobApplicantsReceived({
    required int employerId,
    required int jobId,
    int page = 1,
    int limit = 20,
  }) {
    return _api.getJson<ApplicantsPageResponse>(
      endpoint: ApiClient.jobsEmployerApplicantsReceived(employerId, jobId),
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      fromJson: (json) => ApplicantsPageResponse.fromJson(json),
    );
  }

  Future<Result<ApplicantsPageResponse, CustomException>>
  getEmployerJobApplicantsSent({
    required int employerId,
    required int jobId,
    int page = 1,
    int limit = 20,
  }) {
    return _api.getJson<ApplicantsPageResponse>(
      endpoint: ApiClient.jobsEmployerApplicantsSent(employerId, jobId),
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      fromJson: (json) => ApplicantsPageResponse.fromJson(json),
    );
  }

  Future<Result<ApplicantsPageResponse, CustomException>>
  getEmployerJobApplicantsShortlisted({
    required int employerId,
    required int jobId,
    int page = 1,
    int limit = 20,
  }) {
    return _api.getJson<ApplicantsPageResponse>(
      endpoint: ApiClient.jobsEmployerApplicantsShortlisted(employerId, jobId),
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      fromJson: (json) => ApplicantsPageResponse.fromJson(json),
    );
  }

  Future<Result<ApplicantsPageResponse, CustomException>>
  getEmployerJobApplicantsHired({
    required int employerId,
    required int jobId,
    int page = 1,
    int limit = 20,
  }) {
    return _api.getJson<ApplicantsPageResponse>(
      endpoint: ApiClient.jobsEmployerApplicantsHired(employerId, jobId),
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      fromJson: (json) => ApplicantsPageResponse.fromJson(json),
    );
  }

  Future<Result<ApplicantsPageResponse, CustomException>>
  getEmployerJobApplicantsRejected({
    required int employerId,
    required int jobId,
    int page = 1,
    int limit = 20,
  }) {
    return _api.getJson<ApplicantsPageResponse>(
      endpoint: ApiClient.jobsEmployerApplicantsRejected(employerId, jobId),
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      fromJson: (json) => ApplicantsPageResponse.fromJson(json),
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>> saveEmployerJob({
    required int employerId,
    required Map<String, dynamic> body,
  }) {
    return _api.postJson<Map<String, dynamic>>(
      endpoint: ApiClient.jobsEmployerSave(employerId),
      body: body,
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>>
  sendInterviewerContactOtp({
    required int employerId,
    required String interviewerContact,
  }) {
    return _api.postJson<Map<String, dynamic>>(
      endpoint: ApiClient.jobsInterviewerSendOtp(employerId),
      body: {'interviewer_contact': interviewerContact},
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>>
  verifyInterviewerContactOtp({
    required int employerId,
    required String interviewerContact,
    required String otp,
    int? verificationId,
  }) {
    final body = <String, dynamic>{
      'interviewer_contact': interviewerContact,
      'otp': otp,
    };
    if (verificationId != null && verificationId > 0) {
      body['verification_id'] = verificationId;
    }

    return _api.postJson<Map<String, dynamic>>(
      endpoint: ApiClient.jobsInterviewerVerifyOtp(employerId),
      body: body,
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }
}
