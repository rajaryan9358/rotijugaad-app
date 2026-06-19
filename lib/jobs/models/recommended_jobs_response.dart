import 'job_dto.dart';

class RecommendedJobsResponse {
  final List<JobDto> jobs;

  const RecommendedJobsResponse({required this.jobs});

  factory RecommendedJobsResponse.fromJson(Map<String, dynamic>? json) {
    final raw = json?['data'];
    final list = (raw is List) ? raw : const [];

    final jobs = <JobDto>[];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        jobs.add(JobDto.fromJson(item));
      } else if (item is Map) {
        jobs.add(JobDto.fromJson(item.cast<String, dynamic>()));
      }
    }

    return RecommendedJobsResponse(jobs: jobs);
  }
}
