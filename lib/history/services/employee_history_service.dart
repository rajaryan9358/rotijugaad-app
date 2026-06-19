import '../../network/api_client.dart';
import '../../network/api_service.dart';
import '../../utils/custom_exception.dart';
import '../../utils/result.dart';

class EmployeeHistoryService {
  final ApiService _api;

  EmployeeHistoryService({ApiService? api}) : _api = api ?? ApiService();

  Future<Result<Map<String, dynamic>, CustomException>> getContacts(
    int employeeId, {
    int page = 1,
    int limit = 50,
  }) {
    return _api.getJson<Map<String, dynamic>>(
      endpoint: ApiClient.employeeContactsHistory(employeeId),
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>> getInterests(
    int employeeId, {
    int page = 1,
    int limit = 50,
  }) {
    return _api.getJson<Map<String, dynamic>>(
      endpoint: ApiClient.employeeInterestsHistory(employeeId),
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }
}
