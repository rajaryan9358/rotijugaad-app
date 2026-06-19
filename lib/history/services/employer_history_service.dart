import '../../network/api_client.dart';
import '../../network/api_service.dart';
import '../../utils/custom_exception.dart';
import '../../utils/result.dart';

class EmployerHistoryService {
  final ApiService _api;

  EmployerHistoryService({ApiService? api}) : _api = api ?? ApiService();

  Future<Result<Map<String, dynamic>, CustomException>> getContacts(
    int employerId, {
    int page = 1,
    int limit = 50,
  }) {
    return _api.getJson<Map<String, dynamic>>(
      endpoint: ApiClient.employerContactsHistory(employerId),
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>> getInterests(
    int employerId, {
    int page = 1,
    int limit = 50,
  }) {
    return _api.getJson<Map<String, dynamic>>(
      endpoint: ApiClient.employerInterestsHistory(employerId),
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>> getAds(
    int employerId, {
    int page = 1,
    int limit = 50,
  }) {
    return _api.getJson<Map<String, dynamic>>(
      endpoint: ApiClient.employerAdsHistory(employerId),
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }
}
