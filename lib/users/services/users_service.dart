import '../../auth/models/user_dto.dart';
import '../../network/api_client.dart';
import '../../network/api_service.dart';
import '../../utils/custom_exception.dart';
import '../../utils/result.dart';

class UsersService {
  final ApiService _api;

  UsersService({ApiService? api}) : _api = api ?? ApiService();

  Future<Result<UserDto, CustomException>> getUserById(int userId) {
    return _api.getJson<UserDto>(
      endpoint: ApiClient.userById(userId),
      fromJson: (json) {
        final map = json ?? const <String, dynamic>{};
        final user = map['user'];
        return UserDto.fromJson(
          user is Map<String, dynamic> ? user : const <String, dynamic>{},
        );
      },
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>>
  updatePreferredLanguage({
    required int userId,
    required String preferredLanguage,
  }) {
    final language = preferredLanguage.trim().toUpperCase();
    return _api.putJson<Map<String, dynamic>>(
      endpoint: ApiClient.userPreferredLanguage(userId),
      body: {'preferred_language': language},
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>> updateLastActiveAt(
    int userId,
  ) {
    return _api.putJson<Map<String, dynamic>>(
      endpoint: ApiClient.userLastActive(userId),
      body: const <String, dynamic>{},
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>> submitDeletionRequest(
    int userId,
  ) {
    return _api.postJson<Map<String, dynamic>>(
      endpoint: ApiClient.userDeleteRequest(userId),
      body: const <String, dynamic>{},
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }

  Future<Result<Map<String, dynamic>, CustomException>> submitReview({
    required int userId,
    required int rating,
    required String review,
    String? userType,
  }) {
    return _api.postJson<Map<String, dynamic>>(
      endpoint: ApiClient.userCreateReview(userId),
      body: {
        'rating': rating,
        'review': review,
        if (userType != null && userType.trim().isNotEmpty)
          'user_type': userType.trim().toLowerCase(),
      },
      fromJson: (json) => json ?? const <String, dynamic>{},
    );
  }
}
