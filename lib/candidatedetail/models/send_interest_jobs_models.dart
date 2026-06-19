import '../../jobs/models/job_dto.dart';

class SendInterestJobInterestDto {
  final int? jobInterestId;
  final String? status;
  final DateTime? time;

  const SendInterestJobInterestDto({
    required this.jobInterestId,
    required this.status,
    required this.time,
  });

  static int? _asNullableInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static String? _asNullableString(dynamic v) {
    final s = (v?.toString() ?? '').trim();
    return s.isEmpty ? null : s;
  }

  static DateTime? _asDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  factory SendInterestJobInterestDto.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};
    return SendInterestJobInterestDto(
      jobInterestId: _asNullableInt(
        map['job_interest_id'] ?? map['jobInterestId'],
      ),
      status: _asNullableString(map['status']),
      time: _asDate(map['time'] ?? map['created_at'] ?? map['createdAt']),
    );
  }
}

class EmployerSendInterestJobDto {
  final JobDto job;
  final String? organizationName;
  final String? organizationNameEnglish;
  final String? organizationNameHindi;
  final String? jobProfileEnglish;
  final String? jobProfileHindi;
  final bool canSendInterest;
  final SendInterestJobInterestDto? interest;

  const EmployerSendInterestJobDto({
    required this.job,
    required this.organizationName,
    required this.organizationNameEnglish,
    required this.organizationNameHindi,
    required this.jobProfileEnglish,
    required this.jobProfileHindi,
    required this.canSendInterest,
    required this.interest,
  });

  static bool _asBool(dynamic v) {
    if (v is bool) return v;
    final s = (v?.toString() ?? '').trim().toLowerCase();
    return s == 'true' || s == '1';
  }

  static String? _asNullableString(dynamic v) {
    final s = (v?.toString() ?? '').trim();
    return s.isEmpty ? null : s;
  }

  factory EmployerSendInterestJobDto.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};

    final rawJob = map['job'];
    final jobMap = rawJob is Map<String, dynamic>
        ? rawJob
        : rawJob is Map
        ? rawJob.cast<String, dynamic>()
        : const <String, dynamic>{};

    final nestedJobProfile = jobMap['JobProfile'];
    final nestedJobProfileMap = nestedJobProfile is Map<String, dynamic>
        ? nestedJobProfile
        : nestedJobProfile is Map
        ? nestedJobProfile.cast<String, dynamic>()
        : const <String, dynamic>{};

    final nestedSalaryType = jobMap['SalaryType'];
    final nestedSalaryTypeMap = nestedSalaryType is Map<String, dynamic>
        ? nestedSalaryType
        : nestedSalaryType is Map
        ? nestedSalaryType.cast<String, dynamic>()
        : const <String, dynamic>{};

    final normalizedJobMap = <String, dynamic>{
      ...jobMap,
      'job_profile':
          jobMap['job_profile'] ??
          jobMap['jobProfile'] ??
          nestedJobProfileMap['profile_english'] ??
          nestedJobProfileMap['profile_hindi'],
        'job_profile_english':
          jobMap['job_profile_english'] ??
          jobMap['jobProfileEnglish'] ??
          nestedJobProfileMap['profile_english'],
        'job_profile_hindi':
          jobMap['job_profile_hindi'] ??
          jobMap['jobProfileHindi'] ??
          nestedJobProfileMap['profile_hindi'],
      'salary_type':
          jobMap['salary_type'] ??
          jobMap['salaryType'] ??
          nestedSalaryTypeMap['type_english'] ??
          nestedSalaryTypeMap['type_hindi'],
        'salary_type_english':
          jobMap['salary_type_english'] ??
          jobMap['salaryTypeEnglish'] ??
          nestedSalaryTypeMap['type_english'],
        'salary_type_hindi':
          jobMap['salary_type_hindi'] ??
          jobMap['salaryTypeHindi'] ??
          nestedSalaryTypeMap['type_hindi'],
        'organization_name_english':
          jobMap['organization_name_english'] ?? jobMap['organizationNameEnglish'],
        'organization_name_hindi':
          jobMap['organization_name_hindi'] ?? jobMap['organizationNameHindi'],
    };

    final rawInterest = map['interest'];
    final interestMap = rawInterest is Map<String, dynamic>
        ? rawInterest
        : rawInterest is Map
        ? rawInterest.cast<String, dynamic>()
        : null;

    return EmployerSendInterestJobDto(
      job: JobDto.fromJson(normalizedJobMap),
      organizationName: _asNullableString(
        map['organization_name'] ?? map['organizationName'],
      ),
      organizationNameEnglish: _asNullableString(
        map['organization_name_english'] ??
            map['organizationNameEnglish'] ??
            jobMap['organization_name_english'] ??
            jobMap['organizationNameEnglish'],
      ),
      organizationNameHindi: _asNullableString(
        map['organization_name_hindi'] ??
            map['organizationNameHindi'] ??
            jobMap['organization_name_hindi'] ??
            jobMap['organizationNameHindi'],
      ),
      jobProfileEnglish: _asNullableString(
        map['job_profile_english'] ??
            map['jobProfileEnglish'] ??
            jobMap['job_profile_english'] ??
            jobMap['jobProfileEnglish'] ??
            nestedJobProfileMap['profile_english'],
      ),
      jobProfileHindi: _asNullableString(
        map['job_profile_hindi'] ??
            map['jobProfileHindi'] ??
            jobMap['job_profile_hindi'] ??
            jobMap['jobProfileHindi'] ??
            nestedJobProfileMap['profile_hindi'],
      ),
      canSendInterest: _asBool(
        map['can_send_interest'] ??
            map['canSendInterest'] ??
            map['can_shortlist'] ??
            map['canShortlist'],
      ),
      interest: interestMap == null
          ? null
          : SendInterestJobInterestDto.fromJson(interestMap),
    );
  }
}

class EmployerSendInterestJobsResponse {
  final int page;
  final int limit;
  final int total;
  final List<EmployerSendInterestJobDto> results;

  const EmployerSendInterestJobsResponse({
    required this.page,
    required this.limit,
    required this.total,
    required this.results,
  });

  static int _asInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    return int.tryParse((v ?? '').toString()) ?? fallback;
  }

  factory EmployerSendInterestJobsResponse.fromJson(
    Map<String, dynamic>? json,
  ) {
    final map = json ?? const <String, dynamic>{};

    final raw = map['results'] ?? map['data'];
    final list = raw is List ? raw : const [];

    final out = <EmployerSendInterestJobDto>[];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        out.add(EmployerSendInterestJobDto.fromJson(item));
      } else if (item is Map) {
        out.add(
          EmployerSendInterestJobDto.fromJson(item.cast<String, dynamic>()),
        );
      }
    }

    return EmployerSendInterestJobsResponse(
      page: _asInt(map['page'], fallback: 1),
      limit: _asInt(map['limit'], fallback: 50),
      total: _asInt(map['total'], fallback: out.length),
      results: out,
    );
  }
}
