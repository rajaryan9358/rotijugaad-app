import 'user_dto.dart';

class AuthSendOtpResponse {
  final String mobile;
  final String? otp;
  final UserDto? user;

  const AuthSendOtpResponse({
    required this.mobile,
    this.otp,
    this.user,
  });

  factory AuthSendOtpResponse.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};
    final userJson = map['user'];

    return AuthSendOtpResponse(
      mobile: map['mobile']?.toString() ?? '',
      otp: map['otp']?.toString(),
      user: userJson is Map<String, dynamic> ? UserDto.fromJson(userJson) : null,
    );
  }
}
