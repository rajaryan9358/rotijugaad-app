import '../../jobs/models/job_dto.dart';

class EmployerJobsResponse {
  final int page;
  final int limit;
  final int total;
  final List<JobDto> jobs;

  const EmployerJobsResponse({
    required this.page,
    required this.limit,
    required this.total,
    required this.jobs,
  });

  static int _asInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    return int.tryParse((v ?? '').toString()) ?? fallback;
  }

  factory EmployerJobsResponse.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};

    final raw = map['results'] ?? map['jobs'] ?? map['data'];
    final list = (raw is List) ? raw : const [];

    final out = <JobDto>[];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        out.add(JobDto.fromJson(item));
      } else if (item is Map) {
        out.add(JobDto.fromJson(item.cast<String, dynamic>()));
      }
    }

    return EmployerJobsResponse(
      page: _asInt(map['page'], fallback: 1),
      limit: _asInt(map['limit'], fallback: 50),
      total: _asInt(map['total'], fallback: out.length),
      jobs: out,
    );
  }
}
