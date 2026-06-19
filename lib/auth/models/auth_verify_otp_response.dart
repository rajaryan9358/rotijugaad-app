import 'user_dto.dart';

class AuthVerifyOtpResponse {
  final UserDto user;
  final String? profileType;
  final Map<String, dynamic>? profile;
  final bool profileCompleted;

  const AuthVerifyOtpResponse({
    required this.user,
    required this.profileType,
    required this.profile,
    required this.profileCompleted,
  });

  factory AuthVerifyOtpResponse.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};
    final userJson = map['user'];

    if (userJson is! Map<String, dynamic>) {
      throw const FormatException('Missing user in auth verify response');
    }

    final profileJson = map['profile'];

    return AuthVerifyOtpResponse(
      user: UserDto.fromJson(userJson),
      profileType: map['profile_type']?.toString(),
      profile: profileJson is Map<String, dynamic> ? profileJson : null,
      profileCompleted: map['profile_completed'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'profile_type': profileType,
      'profile': profile,
      'profile_completed': profileCompleted,
    };
  }
}
