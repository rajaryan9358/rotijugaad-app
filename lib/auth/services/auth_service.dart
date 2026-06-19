import '../../network/api_client.dart';
import '../../network/api_service.dart';
import '../../utils/custom_exception.dart';
import '../../utils/result.dart';
import '../models/auth_send_otp_response.dart';
import '../models/auth_verify_otp_response.dart';
import '../../notifications/notification_service.dart';

class AuthService {
  final ApiService _api;

  AuthService({ApiService? api}) : _api = api ?? ApiService();

  Future<Result<AuthSendOtpResponse, CustomException>> sendLoginOtp({
    required String mobile,
  }) {
    return _api.postJson<AuthSendOtpResponse>(
      endpoint: ApiClient.authSendLoginOtp,
      body: {'mobile': mobile},
      fromJson: (json) => AuthSendOtpResponse.fromJson(json),
    );
  }

  Future<Result<AuthVerifyOtpResponse, CustomException>> verifyLoginOtp({
    required String mobile,
    required String otp,
  }) {
    return _verifyLoginOtpInternal(mobile: mobile, otp: otp);
  }

  Future<Result<AuthVerifyOtpResponse, CustomException>>
  _verifyLoginOtpInternal({required String mobile, required String otp}) async {
    final fcmToken = await NotificationService.instance.getToken();

    return _api.postJson<AuthVerifyOtpResponse>(
      endpoint: ApiClient.authVerifyLoginOtp,
      body: {
        'mobile': mobile,
        'otp': otp,
        if (fcmToken != null && fcmToken.trim().isNotEmpty)
          'fcm_token': fcmToken.trim(),
      },
      fromJson: (json) => AuthVerifyOtpResponse.fromJson(json),
    );
  }

  Future<Result<AuthSendOtpResponse, CustomException>> sendSignupOtp({
    required String name,
    required String mobile,
    required String userType,
    String? referredBy,
  }) {
    return _api.postJson<AuthSendOtpResponse>(
      endpoint: ApiClient.authSendSignupOtp,
      body: {
        'name': name,
        'mobile': mobile,
        'user_type': userType,
        if (referredBy != null && referredBy.trim().isNotEmpty)
          'referred_by': referredBy.trim(),
      },
      fromJson: (json) => AuthSendOtpResponse.fromJson(json),
    );
  }

  Future<Result<AuthVerifyOtpResponse, CustomException>> verifySignupOtp({
    required String mobile,
    required String otp,
  }) {
    return _verifySignupOtpInternal(mobile: mobile, otp: otp);
  }

  Future<Result<AuthVerifyOtpResponse, CustomException>>
  _verifySignupOtpInternal({
    required String mobile,
    required String otp,
  }) async {
    final fcmToken = await NotificationService.instance.getToken();

    return _api.postJson<AuthVerifyOtpResponse>(
      endpoint: ApiClient.authVerifySignupOtp,
      body: {
        'mobile': mobile,
        'otp': otp,
        if (fcmToken != null && fcmToken.trim().isNotEmpty)
          'fcm_token': fcmToken.trim(),
      },
      fromJson: (json) => AuthVerifyOtpResponse.fromJson(json),
    );
  }
}
