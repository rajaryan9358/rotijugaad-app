import 'candidate_summary.dart';

class CandidatesPageResponse {
  final int page;
  final int limit;
  final int total;
  final List<CandidateSummaryDto> candidates;

  const CandidatesPageResponse({
    required this.page,
    required this.limit,
    required this.total,
    required this.candidates,
  });

  static int _asInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? fallback;
  }

  factory CandidatesPageResponse.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};

    final rawCandidates = map['candidates'];
    final candidates = <CandidateSummaryDto>[];
    if (rawCandidates is List) {
      for (final item in rawCandidates) {
        if (item is Map<String, dynamic>) {
          candidates.add(CandidateSummaryDto.fromJson(item));
        } else if (item is Map) {
          candidates.add(
            CandidateSummaryDto.fromJson(
              item.map((k, v) => MapEntry(k.toString(), v)),
            ),
          );
        }
      }
    }

    return CandidatesPageResponse(
      page: _asInt(map['page'], fallback: 1),
      limit: _asInt(map['limit'], fallback: 50),
      total: _asInt(map['total'], fallback: candidates.length),
      candidates: candidates,
    );
  }
}

class RecommendedCandidatesResponse {
  final List<CandidateSummaryDto> candidates;

  const RecommendedCandidatesResponse({required this.candidates});

  factory RecommendedCandidatesResponse.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};

    final rawList = map['data'] ?? map['candidates'] ?? map['items'];

    final candidates = <CandidateSummaryDto>[];
    if (rawList is List) {
      for (final item in rawList) {
        if (item is Map<String, dynamic>) {
          candidates.add(CandidateSummaryDto.fromJson(item));
        } else if (item is Map) {
          candidates.add(
            CandidateSummaryDto.fromJson(
              item.map((k, v) => MapEntry(k.toString(), v)),
            ),
          );
        }
      }
    }

    return RecommendedCandidatesResponse(candidates: candidates);
  }
}
