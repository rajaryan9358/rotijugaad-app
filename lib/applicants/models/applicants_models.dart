import 'package:intl/intl.dart';
import 'package:rotijugaad/utils/shared_pref.dart';

class ApplicantsPageResponse {
  final int page;
  final int limit;
  final int total;
  final List<ApplicantRecord> results;

  ApplicantsPageResponse({
    required this.page,
    required this.limit,
    required this.total,
    required this.results,
  });

  factory ApplicantsPageResponse.fromJson(Map<String, dynamic>? json) {
    final page = _asInt(json?['page']) ?? 1;
    final limit = _asInt(json?['limit']) ?? 20;
    final total = _asInt(json?['total']) ?? 0;

    final results = <ApplicantRecord>[];
    final raw = json?['results'];
    if (raw is List) {
      for (final item in raw) {
        if (item is Map) {
          results.add(ApplicantRecord.fromJson(item.cast<String, dynamic>()));
        }
      }
    }

    return ApplicantsPageResponse(
      page: page,
      limit: limit,
      total: total,
      results: results,
    );
  }
}

class ApplicantRecord {
  final ApplicantEmployee employee;
  final ApplicantJobInterest jobInterest;
  final ApplicantJob job;

  /// Some endpoints return these at top-level rather than nested in `Job`.
  final String? jobProfileNameRaw;
  final String? organizationNameRaw;

  ApplicantRecord({
    required this.employee,
    required this.jobInterest,
    required this.job,
    this.jobProfileNameRaw,
    this.organizationNameRaw,
  });

  factory ApplicantRecord.fromJson(Map<String, dynamic> json) {
    final employeeJson = _firstMap(json, const [
      'Employee',
      'employee',
      'employee_detail',
      'EmployeeDetail',
    ]);

    final jobJson = _firstMap(json, const [
      'Job',
      'job',
      'EmployerJob',
      'EmployerJobs',
    ]);

    final interestJson = _firstMap(json, const [
      'JobInterest',
      'jobInterest',
      'job_interest',
      'EmployeeJobInterest',
    ]);

    return ApplicantRecord(
      employee: ApplicantEmployee.fromJson(employeeJson),
      jobInterest: ApplicantJobInterest.fromJson(interestJson),
      job: ApplicantJob.fromJson(jobJson),
      jobProfileNameRaw: json['job_profile_name']?.toString(),
      organizationNameRaw: json['organization_name']?.toString(),
    );
  }

  String get employeeName {
    final isHindi =
        SharedPrefUtils.readStr(SharedPrefUtils.APP_LANGUAGE) == 'hi';
    final name =
        (isHindi ? employee.nameHindi : employee.nameEnglish) ?? employee.name;
    if (name != null && name.trim().isNotEmpty) return name.trim();
    return '-';
  }

  String get jobProfileName {
    final nested = job.jobProfileName;
    if (nested != null && nested.trim().isNotEmpty) return nested.trim();

    final raw = jobProfileNameRaw;
    if (raw != null && raw.trim().isNotEmpty) return raw.trim();

    return '-';
  }

  String get organizationName {
    final nested = job.organizationName;
    if (nested != null && nested.trim().isNotEmpty) return nested.trim();

    final raw = organizationNameRaw;
    if (raw != null && raw.trim().isNotEmpty) return raw.trim();

    return '';
  }

  String get employeeLocation {
    final isHindi =
        SharedPrefUtils.readStr(SharedPrefUtils.APP_LANGUAGE) == 'hi';
    final parts = [
      (isHindi ? employee.cityHindi : employee.cityEnglish)?.trim() ??
          employee.city?.trim(),
      (isHindi ? employee.stateHindi : employee.stateEnglish)?.trim() ??
          employee.state?.trim(),
    ].where((e) => (e ?? '').isNotEmpty).cast<String>().toList();

    return parts.join(', ');
  }

  String get jobLocation {
    final isHindi =
        SharedPrefUtils.readStr(SharedPrefUtils.APP_LANGUAGE) == 'hi';
    final parts = [
      (isHindi ? job.cityHindi : job.cityEnglish)?.trim() ?? job.city?.trim(),
      (isHindi ? job.stateHindi : job.stateEnglish)?.trim() ??
          job.state?.trim(),
    ].where((e) => (e ?? '').isNotEmpty).cast<String>().toList();

    return parts.join(', ');
  }

  String get hiredLabel {
    final hired = job.hiredCount;
    final total = job.noVacancy;
    if (hired == null || total == null) return '';
    return '$hired of $total hired';
  }
}

class ApplicantEmployee {
  final int? id;
  final String? name;
  final String? nameEnglish;
  final String? nameHindi;
  final String? gender;
  final String? verificationStatus;
  final String? kycStatus;
  final num? expectedSalary;
  final String? expectedSalaryFrequency;
  final String? city;
  final String? state;
  final String? cityEnglish;
  final String? cityHindi;
  final String? stateEnglish;
  final String? stateHindi;
  final String? preferredCity;
  final String? preferredState;
  final String? preferredCityEnglish;
  final String? preferredCityHindi;
  final String? preferredStateEnglish;
  final String? preferredStateHindi;
  final List<ApplicantEmployeeJobProfile> jobProfiles;

  ApplicantEmployee({
    required this.id,
    required this.name,
    required this.nameEnglish,
    required this.nameHindi,
    required this.gender,
    required this.verificationStatus,
    required this.kycStatus,
    required this.expectedSalary,
    required this.expectedSalaryFrequency,
    required this.city,
    required this.state,
    required this.cityEnglish,
    required this.cityHindi,
    required this.stateEnglish,
    required this.stateHindi,
    required this.preferredCity,
    required this.preferredState,
    required this.preferredCityEnglish,
    required this.preferredCityHindi,
    required this.preferredStateEnglish,
    required this.preferredStateHindi,
    required this.jobProfiles,
  });

  factory ApplicantEmployee.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ApplicantEmployee(
        id: null,
        name: null,
        nameEnglish: null,
        nameHindi: null,
        gender: null,
        verificationStatus: null,
        kycStatus: null,
        expectedSalary: null,
        expectedSalaryFrequency: null,
        city: null,
        state: null,
        cityEnglish: null,
        cityHindi: null,
        stateEnglish: null,
        stateHindi: null,
        preferredCity: null,
        preferredState: null,
        preferredCityEnglish: null,
        preferredCityHindi: null,
        preferredStateEnglish: null,
        preferredStateHindi: null,
        jobProfiles: const [],
      );
    }

    final rawJobProfiles =
        json['employee_job_profiles'] ??
        json['job_profiles'] ??
        json['jobProfiles'];
    final jobProfiles = <ApplicantEmployeeJobProfile>[];
    if (rawJobProfiles is List) {
      for (final item in rawJobProfiles) {
        if (item is Map<String, dynamic>) {
          jobProfiles.add(ApplicantEmployeeJobProfile.fromJson(item));
        } else if (item is Map) {
          jobProfiles.add(
            ApplicantEmployeeJobProfile.fromJson(
              item.map((k, v) => MapEntry(k.toString(), v)),
            ),
          );
        }
      }
    }

    return ApplicantEmployee(
      id: _asInt(json['id'] ?? json['employee_id']),
      name: json['name']?.toString() ?? json['full_name']?.toString(),
      nameEnglish:
          json['name_english']?.toString() ??
          json['full_name_english']?.toString(),
      nameHindi:
          json['name_hindi']?.toString() ?? json['full_name_hindi']?.toString(),
      gender: json['gender']?.toString(),
      verificationStatus: json['verification_status']?.toString(),
      kycStatus: json['kyc_status']?.toString(),
      expectedSalary: _asNum(json['expected_salary']),
      expectedSalaryFrequency: json['expected_salary_frequency']?.toString(),
      city: json['city']?.toString() ?? json['preferred_city']?.toString(),
      state: json['state']?.toString() ?? json['preferred_state']?.toString(),
      cityEnglish:
          json['city_english']?.toString() ??
          json['preferred_city_english']?.toString(),
      cityHindi:
          json['city_hindi']?.toString() ??
          json['preferred_city_hindi']?.toString(),
      stateEnglish:
          json['state_english']?.toString() ??
          json['preferred_state_english']?.toString(),
      stateHindi:
          json['state_hindi']?.toString() ??
          json['preferred_state_hindi']?.toString(),
      preferredCity: json['preferred_city']?.toString(),
      preferredState: json['preferred_state']?.toString(),
      preferredCityEnglish: json['preferred_city_english']?.toString(),
      preferredCityHindi: json['preferred_city_hindi']?.toString(),
      preferredStateEnglish: json['preferred_state_english']?.toString(),
      preferredStateHindi: json['preferred_state_hindi']?.toString(),
      jobProfiles: jobProfiles,
    );
  }
}

class ApplicantEmployeeJobProfile {
  final int id;
  final String profileEnglish;
  final String profileHindi;

  const ApplicantEmployeeJobProfile({
    required this.id,
    required this.profileEnglish,
    required this.profileHindi,
  });

  factory ApplicantEmployeeJobProfile.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};
    final nested = (map['JobProfile'] is Map)
        ? (map['JobProfile'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};

    return ApplicantEmployeeJobProfile(
      id: _asInt(map['id']) ?? 0,
      profileEnglish:
          (map['profile_english'] ??
                  map['profileEnglish'] ??
                  nested['profile_english'] ??
                  '')
              .toString()
              .trim(),
      profileHindi:
          (map['profile_hindi'] ??
                  map['profileHindi'] ??
                  nested['profile_hindi'] ??
                  '')
              .toString()
              .trim(),
    );
  }
}

class ApplicantJob {
  final int? id;
  final String? jobProfileName;
  final String? organizationName;
  final String? status;
  final num? salaryMin;
  final num? salaryMax;
  final int? salaryTypeId;
  final String? salaryType;
  final String? salaryFrequency;
  final String? city;
  final String? state;
  final String? cityEnglish;
  final String? cityHindi;
  final String? stateEnglish;
  final String? stateHindi;
  final int? noVacancy;
  final int? hiredCount;

  ApplicantJob({
    required this.id,
    required this.jobProfileName,
    required this.organizationName,
    required this.status,
    required this.salaryMin,
    required this.salaryMax,
    required this.salaryTypeId,
    required this.salaryType,
    required this.salaryFrequency,
    required this.city,
    required this.state,
    required this.cityEnglish,
    required this.cityHindi,
    required this.stateEnglish,
    required this.stateHindi,
    required this.noVacancy,
    required this.hiredCount,
  });

  factory ApplicantJob.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ApplicantJob(
        id: null,
        jobProfileName: null,
        organizationName: null,
        status: null,
        salaryMin: null,
        salaryMax: null,
        salaryTypeId: null,
        salaryType: null,
        salaryFrequency: null,
        city: null,
        state: null,
        cityEnglish: null,
        cityHindi: null,
        stateEnglish: null,
        stateHindi: null,
        noVacancy: null,
        hiredCount: null,
      );
    }

    return ApplicantJob(
      id: _asInt(json['id'] ?? json['job_id']),
      jobProfileName: json['job_profile_name']?.toString(),
      organizationName: json['organization_name']?.toString(),
      status: json['status']?.toString(),
      salaryMin: _asNum(json['salary_min']),
      salaryMax: _asNum(json['salary_max']),
      salaryTypeId: _asInt(json['salary_type_id'] ?? json['salaryTypeId']),
      salaryType:
          json['salary_type']?.toString() ?? json['salaryType']?.toString(),
      salaryFrequency:
          json['salary_frequency']?.toString() ??
          json['salaryFrequency']?.toString() ??
          json['salary_type']?.toString() ??
          json['salaryType']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      cityEnglish: json['city_english']?.toString(),
      cityHindi: json['city_hindi']?.toString(),
      stateEnglish: json['state_english']?.toString(),
      stateHindi: json['state_hindi']?.toString(),
      noVacancy: _asInt(json['no_vacancy']),
      hiredCount: _asInt(json['hired_count'] ?? json['hired_total']),
    );
  }
}

class ApplicantJobInterest {
  final int? id;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? jobId;

  ApplicantJobInterest({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.jobId,
  });

  factory ApplicantJobInterest.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ApplicantJobInterest(
        id: null,
        status: null,
        createdAt: null,
        updatedAt: null,
        jobId: null,
      );
    }

    return ApplicantJobInterest(
      id: _asInt(json['id'] ?? json['job_interest_id']),
      status: json['status']?.toString(),
      createdAt: _asDateTime(json['created_at'] ?? json['createdAt']),
      updatedAt: _asDateTime(json['updated_at'] ?? json['updatedAt']),
      jobId: _asInt(json['job_id'] ?? json['jobId']),
    );
  }

  String get createdAtLabel {
    final dt = createdAt;
    if (dt == null) return '';
    return DateFormat('d MMM, yyyy').format(dt.toLocal());
  }

  String get updatedAtLabel {
    final dt = updatedAt ?? createdAt;
    if (dt == null) return '';
    return DateFormat('d MMM, yyyy').format(dt.toLocal());
  }
}

int? _asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  final s = value.toString().trim();
  if (s.isEmpty) return null;
  return int.tryParse(s);
}

num? _asNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  final s = value.toString().trim();
  if (s.isEmpty) return null;
  return num.tryParse(s);
}

DateTime? _asDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value.isUtc ? value : value.toUtc();
  final s = value.toString().trim();
  if (s.isEmpty) return null;
  final hasOffset = s.endsWith('Z') || s.contains('+') ||
      (s.length > 10 && RegExp(r'T\d{2}:\d{2}:\d{2}.*-\d{2}').hasMatch(s));
  final normalized = hasOffset ? s : '${s}Z';
  return DateTime.tryParse(normalized);
}

Map<String, dynamic>? _firstMap(Map<String, dynamic> json, List<String> keys) {
  for (final k in keys) {
    final v = json[k];
    if (v is Map) return v.cast<String, dynamic>();
  }
  return null;
}
