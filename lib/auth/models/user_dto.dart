class UserDto {
  final int id;
  final String? name;
  final String? mobile;
  final String? referredBy;
  final String? referralCode;
  final int? totalReferred;
  final String? userType;
  final String? profileStatus;
  final String? phoneVerifiedAt;
  final String? profileCompletedAt;
  final bool? profileCompleted;
  final bool? isActive;
  final bool? deletePending;

  const UserDto({
    required this.id,
    this.name,
    this.mobile,
    this.referredBy,
    this.referralCode,
    this.totalReferred,
    this.userType,
    this.profileStatus,
    this.phoneVerifiedAt,
    this.profileCompletedAt,
    this.profileCompleted,
    this.isActive,
    this.deletePending,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name']?.toString(),
      mobile: json['mobile']?.toString(),
      referredBy: json['referred_by']?.toString(),
      referralCode: json['referral_code']?.toString(),
      totalReferred: (json['total_referred'] as num?)?.toInt(),
      userType: json['user_type']?.toString(),
      profileStatus: json['profile_status']?.toString(),
      phoneVerifiedAt: json['phone_verified_at']?.toString(),
      profileCompletedAt: json['profile_completed_at']?.toString(),
      profileCompleted: json['profile_completed'] as bool?,
      isActive: json['is_active'] as bool?,
      deletePending: json['delete_pending'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobile': mobile,
      'referred_by': referredBy,
      'referral_code': referralCode,
      'total_referred': totalReferred,
      'user_type': userType,
      'profile_status': profileStatus,
      'phone_verified_at': phoneVerifiedAt,
      'profile_completed_at': profileCompletedAt,
      'profile_completed': profileCompleted,
      'is_active': isActive,
      'delete_pending': deletePending,
    };
  }
}
