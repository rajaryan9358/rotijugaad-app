import 'package:rotijugaad/utils/shared_pref.dart';

class JobDto {
  final int id;
  final int? employerId;

  final String? employerName;
  final String? organizationName;
  final String? organizationType;
  final String? employerPhone;
  final String? interviewerContact;

  final int? jobProfileId;
  final String? jobProfile;

  final String? shiftTimingDisplay;
  final bool isHousehold;

  final String? genders;
  final String? experiences;
  final String? qualifications;
  final String? shifts;
  final String? skills;
  final String? benefits;

  final int? salaryMin;
  final int? salaryMax;
  final int? salaryTypeId;
  final String? salaryType;

  final String? verificationStatus;
  final int? noVacancy;
  final int? hiredTotal;

  final String? jobAddress;
  final String? jobLocation;
  final String? jobState;
  final String? jobCity;

  final bool isExpired;
  final String? jobStatus;
  final String? jobLife;
  final DateTime? expiredAt;

  final bool isKycVerified;
  final bool isInWishlist;
  final bool showOrganization;
  final bool isContactUnlocked;

  final DateTime? createdAt;

  const JobDto({
    required this.id,
    required this.employerId,
    required this.employerName,
    required this.organizationName,
    required this.organizationType,
    required this.employerPhone,
    required this.interviewerContact,
    required this.jobProfileId,
    required this.jobProfile,
    required this.shiftTimingDisplay,
    required this.isHousehold,
    required this.genders,
    required this.experiences,
    required this.qualifications,
    required this.shifts,
    required this.skills,
    required this.benefits,
    required this.salaryMin,
    required this.salaryMax,
    required this.salaryTypeId,
    required this.salaryType,
    required this.verificationStatus,
    required this.noVacancy,
    required this.hiredTotal,
    required this.jobAddress,
    required this.jobLocation,
    required this.jobState,
    required this.jobCity,
    required this.isExpired,
    required this.jobStatus,
    required this.jobLife,
    required this.expiredAt,
    required this.isKycVerified,
    required this.isInWishlist,
    this.showOrganization = true,
    this.isContactUnlocked = false,
    required this.createdAt,
  });

  JobDto copyWith({bool? isInWishlist}) {
    return JobDto(
      id: id,
      employerId: employerId,
      employerName: employerName,
      organizationName: organizationName,
      organizationType: organizationType,
      employerPhone: employerPhone,
      interviewerContact: interviewerContact,
      jobProfileId: jobProfileId,
      jobProfile: jobProfile,
      shiftTimingDisplay: shiftTimingDisplay,
      isHousehold: isHousehold,
      genders: genders,
      experiences: experiences,
      qualifications: qualifications,
      shifts: shifts,
      skills: skills,
      benefits: benefits,
      salaryMin: salaryMin,
      salaryMax: salaryMax,
      salaryTypeId: salaryTypeId,
      salaryType: salaryType,
      verificationStatus: verificationStatus,
      noVacancy: noVacancy,
      hiredTotal: hiredTotal,
      jobAddress: jobAddress,
      jobLocation: jobLocation,
      jobState: jobState,
      jobCity: jobCity,
      isExpired: isExpired,
      jobStatus: jobStatus,
      jobLife: jobLife,
      expiredAt: expiredAt,
      isKycVerified: isKycVerified,
      isInWishlist: isInWishlist ?? this.isInWishlist,
      showOrganization: showOrganization,
      isContactUnlocked: isContactUnlocked,
      createdAt: createdAt,
    );
  }

  static int _asInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    return int.tryParse((v ?? '').toString()) ?? fallback;
  }

  static int? _asNullableInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.round();

    final s = v.toString().trim();
    if (s.isEmpty) return null;

    final i = int.tryParse(s);
    if (i != null) return i;

    final d = double.tryParse(s);
    if (d != null) return d.round();

    return null;
  }

  static bool _asBool(dynamic v, {bool fallback = false}) {
    if (v is bool) return v;
    final s = (v ?? '').toString().trim().toLowerCase();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0') return false;
    return fallback;
  }

  static String? _asNullableString(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static DateTime? _asDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  factory JobDto.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};
    final employer = (map['Employer'] is Map)
        ? (map['Employer'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    final jobProfileMap = (map['JobProfile'] is Map)
        ? (map['JobProfile'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    final salaryTypeMap = (map['SalaryType'] is Map)
        ? (map['SalaryType'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    final jobStateMap = (map['JobState'] is Map)
        ? (map['JobState'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    final jobCityMap = (map['JobCity'] is Map)
        ? (map['JobCity'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};

    final wishlist = (map['wishlist'] is Map)
        ? (map['wishlist'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};

    final nestedWishlist =
        wishlist['is_in_wishlist'] ??
        wishlist['in_wishlist'] ??
        wishlist['is_wishlisted'];

    final topWishlist =
        map['is_in_wishlist'] ??
        map['isInWishlist'] ??
        map['in_wishlist'] ??
        map['is_wishlisted'];

    final isHindi =
        SharedPrefUtils.readStr(SharedPrefUtils.APP_LANGUAGE) == 'hi';

    String? pickLocalized(dynamic english, dynamic hindi, dynamic fallback) {
      final en = _asNullableString(english);
      final hi = _asNullableString(hindi);
      final fb = _asNullableString(fallback);
      return (isHindi ? hi : en) ?? en ?? hi ?? fb;
    }

    return JobDto(
      id: _asInt(map['job_id'] ?? map['jobId'] ?? map['id']),
      employerId: _asNullableInt(map['employer_id'] ?? map['employerId']),
      employerName: pickLocalized(
        map['employer_name_english'] ??
            map['employerNameEnglish'] ??
            employer['name'],
        map['employer_name_hindi'] ??
            map['employerNameHindi'] ??
            employer['name_hindi'],
        map['employer_name'] ?? map['employerName'] ?? employer['name'],
      ),
      organizationName: pickLocalized(
        map['organization_name_english'] ?? map['organizationNameEnglish'],
        map['organization_name_hindi'] ?? map['organizationNameHindi'],
        map['organization_name'] ??
            map['organizationName'] ??
            employer['organization_name_english'] ??
            employer['organization_name_hindi'] ??
            employer['organization_name'],
      ),
      organizationType: _asNullableString(
        map['organization_type'] ??
            map['organizationType'] ??
            employer['organization_type'],
      ),
      employerPhone: _asNullableString(
        map['employer_phone'] ?? map['employerPhone'],
      ),
      interviewerContact: _asNullableString(
        map['interviewer_contact'] ?? map['interviewerContact'],
      ),
      jobProfileId: _asNullableInt(
        map['job_profile_id'] ?? map['jobProfileId'],
      ),
      jobProfile: pickLocalized(
        map['job_profile_english'] ??
            map['jobProfileEnglish'] ??
            map['job_profile_name_english'] ??
            map['jobProfileNameEnglish'] ??
            jobProfileMap['profile_english'],
        map['job_profile_hindi'] ??
            map['jobProfileHindi'] ??
            map['job_profile_name_hindi'] ??
            map['jobProfileNameHindi'] ??
            jobProfileMap['profile_hindi'],
        map['job_profile'] ??
            map['jobProfile'] ??
            map['job_profile_name'] ??
            map['jobProfileName'] ??
            jobProfileMap['profile_name'],
      ),
      shiftTimingDisplay: _asNullableString(
        map['shift_timing_display'] ?? map['shiftTimingDisplay'],
      ),
      isHousehold: _asBool(map['is_household'] ?? map['isHousehold']),
      genders: _asNullableString(map['genders']),
      experiences: _asNullableString(map['experiences']),
      qualifications: _asNullableString(map['qualifications']),
      shifts: _asNullableString(map['shifts']),
      skills: _asNullableString(map['skills']),
      benefits: _asNullableString(map['benefits']),
      salaryMin: _asNullableInt(map['salary_min'] ?? map['salaryMin']),
      salaryMax: _asNullableInt(map['salary_max'] ?? map['salaryMax']),
      salaryTypeId: _asNullableInt(
        map['salary_type_id'] ?? map['salaryTypeId'],
      ),
      salaryType: pickLocalized(
        map['salary_type_english'] ??
            map['salaryTypeEnglish'] ??
            salaryTypeMap['type_english'],
        map['salary_type_hindi'] ??
            map['salaryTypeHindi'] ??
            salaryTypeMap['type_hindi'],
        map['salary_type'] ??
            map['salaryType'] ??
            map['salary_frequency'] ??
            map['salaryFrequency'] ??
            salaryTypeMap['type'],
      ),
      verificationStatus: _asNullableString(
        map['verification_status'] ?? map['verificationStatus'],
      ),
      noVacancy: _asNullableInt(map['no_vacancy'] ?? map['noVacancy']),
      hiredTotal: _asNullableInt(map['hired_total'] ?? map['hiredTotal']),
      jobAddress: pickLocalized(
        map['job_address_english'] ?? map['jobAddressEnglish'],
        map['job_address_hindi'] ?? map['jobAddressHindi'],
        map['job_address'] ?? map['jobAddress'] ?? map['address'],
      ),
      jobLocation: _asNullableString(map['job_location'] ?? map['jobLocation']),
      jobState: pickLocalized(
        map['job_state_english'] ??
            map['jobStateEnglish'] ??
            jobStateMap['state_english'],
        map['job_state_hindi'] ??
            map['jobStateHindi'] ??
            jobStateMap['state_hindi'],
        map['job_state'] ?? map['jobState'] ?? map['state'],
      ),
      jobCity: pickLocalized(
        map['job_city_english'] ??
            map['jobCityEnglish'] ??
            jobCityMap['city_english'],
        map['job_city_hindi'] ??
            map['jobCityHindi'] ??
            jobCityMap['city_hindi'],
        map['job_city'] ?? map['jobCity'] ?? map['city'],
      ),
      isExpired: _asBool(map['is_expired'] ?? map['isExpired']),
      jobStatus: _asNullableString(
        map['job_status'] ?? map['jobStatus'] ?? map['status'],
      ),
      jobLife: _asNullableString(map['job_life'] ?? map['jobLife']),
      expiredAt: _asDate(map['expired_at'] ?? map['expiredAt']),
      isKycVerified:
          (employer['kyc_status']?.toString().trim().toLowerCase() ?? '') ==
          'verified',
      isInWishlist: _asBool(nestedWishlist ?? topWishlist),
      showOrganization: _asBool(
        map['show_organization'] ?? map['showOrganization'],
        fallback: true,
      ),
      isContactUnlocked: _asBool(
        map['is_contact_unlocked'] ?? map['isContactUnlocked'],
      ),
      createdAt: _asDate(map['created_at'] ?? map['createdAt']),
    );
  }
}
