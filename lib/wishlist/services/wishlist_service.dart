import '../../network/api_client.dart';
import '../../network/api_service.dart';
import '../../utils/custom_exception.dart';
import '../../utils/result.dart';
import '../models/wishlist_response.dart';

class WishlistService {
  final ApiService _api;

  WishlistService({ApiService? api}) : _api = api ?? ApiService();

  Future<Result<WishlistResponse, CustomException>> getEmployeeWishlist(
    int employeeId, {
    int page = 1,
    int limit = 50,
  }) {
    return _api.getJson<WishlistResponse>(
      endpoint: ApiClient.employeeWishlist(employeeId),
      queryParameters: {
        'page': page.toString(),
        'limit': limit.toString(),
      },
      fromJson: (json) => WishlistResponse.fromJson(json),
    );
  }
}
