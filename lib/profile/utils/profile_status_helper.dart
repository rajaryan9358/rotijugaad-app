class ProfileStatusHelper {
  static bool boolish(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    final raw = value.toString().trim().toLowerCase();
    return raw == 'true' || raw == '1' || raw == 'yes';
  }

  static bool hasValue(dynamic value) =>
      value != null && value.toString().trim().isNotEmpty;

  static String normalizedStatus(dynamic value) {
    final status = (value ?? '').toString().trim().toLowerCase();
    if (status == 'init') return '';
    return status;
  }

  static bool isProfileCompleted({
    Map<String, dynamic>? user,
    Map<String, dynamic>? profile,
  }) {
    // If the user API explicitly provides profile_completed, trust it as the
    // authoritative source — even if the cached profile JSON looks complete.
    final userFlag =
        user?['profile_completed'] ?? user?['profileCompleted'];
    if (userFlag != null) {
      return boolish(userFlag);
    }

    if (hasValue(
      user?['profile_completed_at'] ?? user?['profileCompletedAt'],
    )) {
      return true;
    }

    if (boolish(
      profile?['profile_completed'] ?? profile?['profileCompleted'],
    )) {
      return true;
    }
    if (hasValue(
      profile?['profile_completed_at'] ?? profile?['profileCompletedAt'],
    )) {
      return true;
    }

    final verificationStatus = normalizedStatus(
      profile?['verification_status'] ?? profile?['verificationStatus'],
    );
    return verificationStatus == 'pending' || verificationStatus == 'verified';
  }
}
