import '../../network/api_client.dart';
import '../../network/api_service.dart';
import '../../utils/custom_exception.dart';
import '../../utils/result.dart';

class PaymentHistoryService {
  final ApiService _api;

  PaymentHistoryService({ApiService? api}) : _api = api ?? ApiService();

  Future<Result<Map<String, dynamic>, CustomException>>
  getEmployerPaymentHistory(int employerId, {int page = 1, int limit = 50}) {
    return _api.getJson<Map<String, dynamic>>(
      endpoint: ApiClient.employerPaymentsHistory(employerId),
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>>
  getEmployeePaymentHistory(int employeeId, {int page = 1, int limit = 50}) {
    return _api.getJson<Map<String, dynamic>>(
      endpoint: ApiClient.employeePaymentsHistory(employeeId),
      queryParameters: {'page': page.toString(), 'limit': limit.toString()},
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }
}
