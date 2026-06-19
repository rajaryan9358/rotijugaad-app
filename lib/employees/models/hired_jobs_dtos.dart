import "package:rotijugaad/jobs/models/job_dto.dart";

import "../../masters/models/json_helpers.dart";

class EmployeeHiredMetaDto {
  final int? jobInterestId;
  final String? senderType;
  final int? senderId;
  final int? receiverId;
  final int? jobId;
  final String? status;
  final DateTime? hiredAt;

  const EmployeeHiredMetaDto({
    required this.jobInterestId,
    required this.senderType,
    required this.senderId,
    required this.receiverId,
    required this.jobId,
    required this.status,
    required this.hiredAt,
  });

  static DateTime? _asDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString())?.toLocal();
  }

  factory EmployeeHiredMetaDto.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};
    return EmployeeHiredMetaDto(
      jobInterestId: asInt(map["job_interest_id"] ?? map["jobInterestId"]),
      senderType: asString(map["sender_type"] ?? map["senderType"]),
      senderId: asInt(map["sender_id"] ?? map["senderId"]),
      receiverId: asInt(map["receiver_id"] ?? map["receiverId"]),
      jobId: asInt(map["job_id"] ?? map["jobId"]),
      status: asString(map["status"]),
      hiredAt: _asDate(map["hired_at"] ?? map["hiredAt"]),
    );
  }
}

class EmployeeHiredJobDto {
  final EmployeeHiredMetaDto hired;
  final String? organizationName;
  final String? organizationNameEnglish;
  final String? organizationNameHindi;
  final String? employerPhone;
  final JobDto job;

  /// Entire backend payload for forward-compat.
  final Map<String, dynamic> raw;

  const EmployeeHiredJobDto({
    required this.hired,
    required this.organizationName,
    required this.organizationNameEnglish,
    required this.organizationNameHindi,
    required this.employerPhone,
    required this.job,
    required this.raw,
  });

  static String? _sanitizePhone(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty || value.startsWith('-')) return null;
    final digits = value.replaceAll(RegExp(r'\D+'), '');
    if (digits.isEmpty) return null;
    return value;
  }

  factory EmployeeHiredJobDto.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};

    final hiredMap = asMap(map["hired"]);
    final jobMap = asMap(map["job"]);
    final employerMap = asMap(map["employer"]);

    final phone = _sanitizePhone(
      asString(
        employerMap?["phone"] ??
            employerMap?["mobile"] ??
            employerMap?["User"]?["mobile"],
      ),
    );

    return EmployeeHiredJobDto(
      hired: EmployeeHiredMetaDto.fromJson(hiredMap),
      organizationName: asString(map["organization_name"]),
      organizationNameEnglish: asString(map["organization_name_english"]),
      organizationNameHindi: asString(map["organization_name_hindi"]),
      employerPhone: phone,
      job: JobDto.fromJson(jobMap),
      raw: map,
    );
  }
}

class EmployeeHiredJobsPageDto {
  final int page;
  final int limit;
  final int total;
  final List<EmployeeHiredJobDto> results;

  const EmployeeHiredJobsPageDto({
    required this.page,
    required this.limit,
    required this.total,
    required this.results,
  });

  factory EmployeeHiredJobsPageDto.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};
    final list = asMapList(map["results"]);

    return EmployeeHiredJobsPageDto(
      page: asInt(map["page"]) ?? 1,
      limit: asInt(map["limit"]) ?? 50,
      total: asInt(map["total"]) ?? list.length,
      results: list.map(EmployeeHiredJobDto.fromJson).toList(),
    );
  }
}
