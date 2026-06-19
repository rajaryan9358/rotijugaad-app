import '../../network/api_client.dart';
import '../../network/api_service.dart';
import '../../utils/custom_exception.dart';
import '../../utils/result.dart';

class SubscriptionsService {
  final ApiService _api;

  SubscriptionsService({ApiService? api}) : _api = api ?? ApiService();

  Future<Result<Map<String, dynamic>, CustomException>>
  getEmployerSubscriptions(int employerId) {
    return _api.getJson<Map<String, dynamic>>(
      endpoint: ApiClient.employerSubscriptions(employerId),
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>>
  getEmployeeSubscriptions(int employeeId) {
    return _api.getJson<Map<String, dynamic>>(
      endpoint: ApiClient.employeeSubscriptions(employeeId),
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>>
  buyEmployerSubscription({required int employerId, required int planId}) {
    return _api.postJson<Map<String, dynamic>>(
      endpoint: ApiClient.employerBuySubscription(employerId),
      body: {'subscription_plan_id': planId},
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>>
  buyEmployeeSubscription({required int employeeId, required int planId}) {
    return _api.postJson<Map<String, dynamic>>(
      endpoint: ApiClient.employeeBuySubscription(employeeId),
      body: {'subscription_plan_id': planId},
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>>
  getEmployerSubscriptionPaymentStatus({
    required int employerId,
    required String orderId,
  }) {
    return _api.getJson<Map<String, dynamic>>(
      endpoint: ApiClient.employerSubscriptionPaymentStatus(
        employerId,
        orderId,
      ),
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>>
  getEmployeeSubscriptionPaymentStatus({
    required int employeeId,
    required String orderId,
  }) {
    return _api.getJson<Map<String, dynamic>>(
      endpoint: ApiClient.employeeSubscriptionPaymentStatus(
        employeeId,
        orderId,
      ),
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }
}
