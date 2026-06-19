import '../../network/api_client.dart';
import '../../network/api_service.dart';
import '../../utils/custom_exception.dart';
import '../../utils/result.dart';
import '../models/job_detail_dto.dart';

class JobDetailsService {
  final ApiService _api;

  JobDetailsService({ApiService? api}) : _api = api ?? ApiService();

  Future<Result<JobDetailDto, CustomException>> getJobDetail({
    required int jobId,
    required int employeeId,
  }) {
    return _api.getJson<JobDetailDto>(
      endpoint: ApiClient.jobsDetail(jobId, employeeId),
      fromJson: (json) => JobDetailDto.fromJson(json),
    );
  }

  Future<Result<bool, CustomException>> unlockJobContact({
    required int jobId,
    required int employeeId,
  }) {
    return _api.postJson<bool>(
      endpoint: ApiClient.employeeUnlockJobContact,
      body: {'job_id': jobId, 'employee_id': employeeId},
      fromJson: (_) => true,
    );
  }

  Future<Result<bool, CustomException>> sendJobInterest({
    required int jobId,
    required int employeeId,
  }) {
    return _api.postJson<bool>(
      endpoint: ApiClient.employeeSendJobInterest,
      body: {'job_id': jobId, 'employee_id': employeeId},
      fromJson: (_) => true,
    );
  }

  Future<Result<bool, CustomException>> unlockApplicationOtp({
    required int jobId,
    required int employeeId,
  }) {
    return _api.postJson<bool>(
      endpoint: ApiClient.employeeUnlockApplicationOtp,
      body: {'job_id': jobId, 'employee_id': employeeId},
      fromJson: (_) => true,
    );
  }

  Future<Result<bool, CustomException>> reportJob({
    required int jobId,
    required int employeeId,
    required int reasonId,
    String? description,
  }) {
    final d = (description ?? '').trim();

    return _api.postJson<bool>(
      endpoint: ApiClient.employeeReportJob,
      body: {
        'job_id': jobId,
        'employee_id': employeeId,
        'reason_id': reasonId,
        'description': d.isEmpty ? null : d,
      },
      fromJson: (_) => true,
    );
  }

  Future<Result<bool, CustomException>> saveContactCallExperience({
    required int jobId,
    required int employeeId,
    int? callExperienceId,
    String? review,
  }) {
    final body = <String, dynamic>{'job_id': jobId, 'employee_id': employeeId};

    if (callExperienceId != null && callExperienceId > 0) {
      body['call_experience_id'] = callExperienceId;
    }

    final r = (review ?? '').trim();
    if (r.isNotEmpty) {
      body['review'] = r;
    }

    return _api.postJson<bool>(
      endpoint: ApiClient.employeeSaveCallExperience,
      body: body,
      fromJson: (_) => true,
    );
  }
}
