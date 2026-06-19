import '../../network/api_client.dart';
import '../../network/api_service.dart';
import '../../utils/custom_exception.dart';
import '../../utils/result.dart';
import '../models/candidates_responses.dart';
import '../../candidatedetail/models/candidate_detail_models.dart';

class CandidatesService {
  final ApiService _api;

  CandidatesService({ApiService? api}) : _api = api ?? ApiService();

  Map<String, dynamic> _cleanBody(Map<String, dynamic> input) {
    final out = <String, dynamic>{};
    input.forEach((k, v) {
      if (v == null) return;

      if (v is String) {
        final s = v.trim();
        if (s.isEmpty) return;
        out[k] = s;
        return;
      }

      if (v is List) {
        if (v.isEmpty) return;
        out[k] = v;
        return;
      }

      out[k] = v;
    });
    return out;
  }

  List<int>? _normalizeIds(List<int>? ids) {
    final list = (ids ?? const <int>[]).where((e) => e > 0).toList();
    return list.isEmpty ? null : list;
  }

  Future<Result<CandidatesPageResponse, CustomException>> getAllCandidates({
    int? employerId,
    String? search,
    List<int>? jobProfileIds,
    List<int>? preferredStateIds,
    List<int>? preferredCityIds,
    List<int>? qualificationIds,
    List<int>? shiftIds,
    List<int>? skillIds,
    List<int>? salaryRangeIds,
    String? verificationStatus,
    List<Map<String, num?>>? experienceRanges,
    List<Map<String, num?>>? distanceRanges,
    String? gender,
    String? expectedSalaryFrequency,
    double? lat,
    double? lng,
    int page = 1,
    int limit = 50,
  }) {
    return _api.postJson<CandidatesPageResponse>(
      endpoint: ApiClient.candidatesGetAll,
      body: _cleanBody({
        'search': search,
        'employer_id': employerId,
        'job_profile_ids': _normalizeIds(jobProfileIds),
        'preferred_state_ids': _normalizeIds(preferredStateIds),
        'preferred_city_ids': _normalizeIds(preferredCityIds),
        'qualification_ids': _normalizeIds(qualificationIds),
        'shift_ids': _normalizeIds(shiftIds),
        'skill_ids': _normalizeIds(skillIds),
        'salary_range_ids': _normalizeIds(salaryRangeIds),
        'verification_status': verificationStatus,
        'experience_ranges':
            (experienceRanges != null && experienceRanges.isNotEmpty)
            ? experienceRanges
            : null,
        'distance_ranges': (distanceRanges != null && distanceRanges.isNotEmpty)
            ? distanceRanges
            : null,
        'gender': gender,
        'expected_salary_frequency': expectedSalaryFrequency,
        'lat': lat,
        'lng': lng,
        'page': page,
        'limit': limit,
      }),
      fromJson: (json) => CandidatesPageResponse.fromJson(json),
    );
  }

  Future<Result<RecommendedCandidatesResponse, CustomException>>
  getRecommendedCandidates({
    required int employerId,
    String? search,
    List<int>? jobProfileIds,
    List<int>? preferredStateIds,
    List<int>? preferredCityIds,
    List<int>? qualificationIds,
    List<int>? shiftIds,
    List<int>? skillIds,
    List<int>? salaryRangeIds,
    String? verificationStatus,
    List<Map<String, num?>>? experienceRanges,
    List<Map<String, num?>>? distanceRanges,
    String? gender,
    String? expectedSalaryFrequency,
    double? lat,
    double? lng,
    int page = 1,
    int limit = 50,
  }) {
    return _api.postJson<RecommendedCandidatesResponse>(
      endpoint: ApiClient.candidatesRecommended(employerId),
      body: _cleanBody({
        'search': search,
        'job_profile_ids': _normalizeIds(jobProfileIds),
        'preferred_state_ids': _normalizeIds(preferredStateIds),
        'preferred_city_ids': _normalizeIds(preferredCityIds),
        'qualification_ids': _normalizeIds(qualificationIds),
        'shift_ids': _normalizeIds(shiftIds),
        'skill_ids': _normalizeIds(skillIds),
        'salary_range_ids': _normalizeIds(salaryRangeIds),
        'verification_status': verificationStatus,
        'experience_ranges':
            (experienceRanges != null && experienceRanges.isNotEmpty)
            ? experienceRanges
            : null,
        'distance_ranges': (distanceRanges != null && distanceRanges.isNotEmpty)
            ? distanceRanges
            : null,
        'gender': gender,
        'expected_salary_frequency': expectedSalaryFrequency,
        'lat': lat,
        'lng': lng,
        'page': page,
        'limit': limit,
      }),
      fromJson: (json) => RecommendedCandidatesResponse.fromJson(json),
    );
  }

  Future<Result<CandidateDetailDto, CustomException>> getCandidateDetail({
    required int candidateId,
    required int employerId,
  }) {
    return _api.getJson<CandidateDetailDto>(
      endpoint: ApiClient.candidatesDetail(candidateId, employerId),
      fromJson: (json) => CandidateDetailDto.fromJson(json),
    );
  }

  Future<Result<CandidateContactDto, CustomException>> unlockCandidateContact({
    required int candidateId,
    required int employerId,
  }) {
    return _api.postJson<CandidateContactDto>(
      endpoint: ApiClient.candidatesUnlockContact,
      body: _cleanBody({'employerId': employerId, 'candidateId': candidateId}),
      fromJson: (json) => CandidateContactDto.fromJson(json),
    );
  }

  Future<Result<bool, CustomException>> reportCandidate({
    required int candidateId,
    required int employerId,
    required int reasonId,
    String? description,
  }) {
    final d = (description ?? '').trim();

    return _api.postJson<bool>(
      endpoint: ApiClient.candidatesReport,
      body: _cleanBody({
        'candidate_id': candidateId,
        'employer_id': employerId,
        'reason_id': reasonId,
        'description': d,
      }),
      fromJson: (_) => true,
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>>
  toggleEmployerCandidateShortlist({
    required int employerId,
    required int candidateId,
  }) {
    return _api.postJson<Map<String, dynamic>>(
      endpoint: ApiClient.employerCandidateShortlistTogglePost,
      body: _cleanBody({'employerId': employerId, 'candidateId': candidateId}),
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }
}
