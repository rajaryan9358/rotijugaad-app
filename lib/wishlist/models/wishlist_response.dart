import '../../jobs/models/job_dto.dart';

class WishlistResponse {
  final int page;
  final int limit;
  final int total;
  final List<JobDto> jobs;

  const WishlistResponse({
    required this.page,
    required this.limit,
    required this.total,
    required this.jobs,
  });

  static int _asInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    return int.tryParse((v ?? '').toString()) ?? fallback;
  }

  factory WishlistResponse.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};

    final results = (map['results'] is List)
        ? (map['results'] as List)
        : const [];

    final jobs = results
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .map((item) {
          final job = item['job'];
          if (job is Map) {
            return JobDto.fromJson(job.cast<String, dynamic>());
          }
          return JobDto.fromJson(const <String, dynamic>{});
        })
        .toList(growable: false);

    return WishlistResponse(
      page: _asInt(map['page'], fallback: 1),
      limit: _asInt(map['limit'], fallback: jobs.length),
      total: _asInt(map['total'], fallback: jobs.length),
      jobs: jobs,
    );
  }
}
