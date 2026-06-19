import 'package:rotijugaad/utils/shared_pref.dart';

class JobDetailDto {
  final int id;
  final String? slug;

  final String? subscriptionStatus;
  final DateTime? creditExpiryAt;
  final int contactCreditAvailable;
  final int interestCreditAvailable;
  final int contactCreditTotal;
  final int interestCreditTotal;

  final String? employerName;
  final String? organizationName;
  final String? organizationType;
  final String? businessCategory;
  final String? employerPhone;

  final String? jobProfile;
  final String? jobDesignation;
  final String? profileImage;

  final String? jobState;
  final String? jobCity;
  final String? jobAddress;
  final String? jobLocation;
  final double? lat;
  final double? lng;

  final double? salaryMin;
  final double? salaryMax;
  final int? salaryTypeId;
  final String? salaryType;

  final int? noVacancy;
  final int? hiredTotal;

  final String? descriptionEnglish;
  final String? otherBenefitEnglish;

  final String? workStartTime;
  final String? workEndTime;

  final DateTime? createdAt;

  final List<String> genders;
  final List<String> experiences;
  final List<String> qualifications;
  final List<String> shifts;
  final List<String> jobDays;
  final List<String> skills;
  final List<String> benefits;

  final bool isContactUnlocked;
  final DateTime? contactUnlockedAt;
  final bool isCallExperienceShared;

  final bool hasInterest;
  final bool isInterestSent;
  final bool isInterestReceived;
  final String? interestStatus;
  final DateTime? interestStatusAt;

  final DateTime? otpUnlockedAt;
  final String? otp;

  final bool isReported;
  final DateTime? reportedAt;
  final bool isInWishlist;

  final bool isEmployerVerified;
  final bool showOrganization;

  const JobDetailDto({
    required this.id,
    required this.slug,
    required this.subscriptionStatus,
    required this.creditExpiryAt,
    required this.contactCreditAvailable,
    required this.interestCreditAvailable,
    required this.contactCreditTotal,
    required this.interestCreditTotal,
    required this.employerName,
    required this.organizationName,
    required this.organizationType,
    required this.businessCategory,
    required this.employerPhone,
    required this.jobProfile,
    required this.jobDesignation,
    required this.profileImage,
    required this.jobState,
    required this.jobCity,
    required this.jobAddress,
    this.jobLocation,
    this.lat,
    this.lng,
    required this.salaryMin,
    required this.salaryMax,
    required this.salaryTypeId,
    required this.salaryType,
    required this.noVacancy,
    required this.hiredTotal,
    required this.descriptionEnglish,
    required this.otherBenefitEnglish,
    required this.workStartTime,
    required this.workEndTime,
    required this.createdAt,
    required this.genders,
    required this.experiences,
    required this.qualifications,
    required this.shifts,
    required this.jobDays,
    required this.skills,
    required this.benefits,
    required this.isContactUnlocked,
    required this.contactUnlockedAt,
    required this.isCallExperienceShared,
    required this.hasInterest,
    required this.isInterestSent,
    required this.isInterestReceived,
    required this.interestStatus,
    required this.interestStatusAt,
    required this.otpUnlockedAt,
    required this.otp,
    required this.isReported,
    required this.reportedAt,
    required this.isInWishlist,
    required this.isEmployerVerified,
    this.showOrganization = true,
  });

  JobDetailDto copyWith({bool? isInWishlist}) {
    return JobDetailDto(
      id: id,
      slug: slug,
      subscriptionStatus: subscriptionStatus,
      creditExpiryAt: creditExpiryAt,
      contactCreditAvailable: contactCreditAvailable,
      interestCreditAvailable: interestCreditAvailable,
      contactCreditTotal: contactCreditTotal,
      interestCreditTotal: interestCreditTotal,
      employerName: employerName,
      organizationName: organizationName,
      organizationType: organizationType,
      businessCategory: businessCategory,
      employerPhone: employerPhone,
      jobProfile: jobProfile,
      jobDesignation: jobDesignation,
      profileImage: profileImage,
      jobState: jobState,
      jobCity: jobCity,
      jobAddress: jobAddress,
      jobLocation: jobLocation,
      lat: lat,
      lng: lng,
      salaryMin: salaryMin,
      salaryMax: salaryMax,
      salaryTypeId: salaryTypeId,
      salaryType: salaryType,
      noVacancy: noVacancy,
      hiredTotal: hiredTotal,
      descriptionEnglish: descriptionEnglish,
      otherBenefitEnglish: otherBenefitEnglish,
      workStartTime: workStartTime,
      workEndTime: workEndTime,
      createdAt: createdAt,
      genders: genders,
      experiences: experiences,
      qualifications: qualifications,
      shifts: shifts,
      jobDays: jobDays,
      skills: skills,
      benefits: benefits,
      isContactUnlocked: isContactUnlocked,
      contactUnlockedAt: contactUnlockedAt,
      isCallExperienceShared: isCallExperienceShared,
      hasInterest: hasInterest,
      isInterestSent: isInterestSent,
      isInterestReceived: isInterestReceived,
      interestStatus: interestStatus,
      interestStatusAt: interestStatusAt,
      otpUnlockedAt: otpUnlockedAt,
      otp: otp,
      isReported: isReported,
      reportedAt: reportedAt,
      isInWishlist: isInWishlist ?? this.isInWishlist,
      isEmployerVerified: isEmployerVerified,
      showOrganization: showOrganization,
    );
  }

  static int _asInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    if (v is double) return v.round();
    final s = (v ?? '').toString().trim();
    if (s.isEmpty) return fallback;
    final i = int.tryParse(s);
    if (i != null) return i;
    final d = double.tryParse(s);
    if (d != null) return d.round();
    return fallback;
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

  static double? _asNullableDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    final s = v.toString().trim();
    if (s.isEmpty) return null;
    return double.tryParse(s);
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

  static List<String> _asStringList(dynamic v) {
    if (v is List) {
      return v
          .map((e) => e?.toString().trim())
          .where((e) => e != null && e.isNotEmpty)
          .cast<String>()
          .toList();
    }
    return const [];
  }

  static List<Map<String, dynamic>> _asMapList(dynamic v) {
    if (v is List) {
      return v.whereType<Map>().map((e) => e.cast<String, dynamic>()).toList();
    }
    return const [];
  }

  factory JobDetailDto.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};
    final isHindi =
        SharedPrefUtils.readStr(SharedPrefUtils.APP_LANGUAGE) == 'hi';

    final employer = (map['Employer'] is Map)
        ? (map['Employer'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};

    final employerUser = (employer['User'] is Map)
        ? (employer['User'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};

    final jobProfile = (map['JobProfile'] is Map)
        ? (map['JobProfile'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};

    final salaryType = (map['SalaryType'] is Map)
        ? (map['SalaryType'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};

    final contact = (map['contact'] is Map)
        ? (map['contact'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};

    final interest = (map['interest'] is Map)
        ? (map['interest'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};

    final callExperience = (map['call_experience'] is Map)
        ? (map['call_experience'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};

    final report = (map['report'] is Map)
        ? (map['report'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};

    final wishlist = (map['wishlist'] is Map)
        ? (map['wishlist'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};

    final employerVerification = _asNullableString(
      employer['kyc_status'],
    );

    Map<String, dynamic> asMap(dynamic v) {
      if (v is Map<String, dynamic>) return v;
      if (v is Map) return v.cast<String, dynamic>();
      return const <String, dynamic>{};
    }

    String? pickLocalized(dynamic english, dynamic hindi, dynamic fallback) {
      final en = _asNullableString(english);
      final hi = _asNullableString(hindi);
      final fb = _asNullableString(fallback);
      return (isHindi ? hi : en) ?? en ?? hi ?? fb;
    }

    final jobState = asMap(map['JobState']);
    final jobCity = asMap(map['JobCity']);

    List<String> pickLocalizedListFromNested(
      dynamic source,
      String nestedKey,
      String englishKey,
      String hindiKey,
      String fallbackKey,
    ) {
      final out = <String>[];
      for (final item in _asMapList(source)) {
        final nested = asMap(item[nestedKey]);
        final value = pickLocalized(
          nested[englishKey],
          nested[hindiKey],
          nested[fallbackKey],
        );
        if ((value ?? '').trim().isNotEmpty) {
          out.add(value!.trim());
        }
      }
      return out;
    }

    List<String> pickLocalizedListFromFlat(
      dynamic source,
      String englishKey,
      String hindiKey,
      String fallbackKey,
    ) {
      final out = <String>[];
      for (final item in _asMapList(source)) {
        final value = pickLocalized(
          item[englishKey],
          item[hindiKey],
          item[fallbackKey],
        );
        if ((value ?? '').trim().isNotEmpty) {
          out.add(value!.trim());
        }
      }
      return out;
    }

    final localizedExperiences = pickLocalizedListFromNested(
      map['JobExperiences'],
      'Experience',
      'title_english',
      'title_hindi',
      'title',
    );

    final localizedQualifications = pickLocalizedListFromNested(
      map['JobQualifications'],
      'Qualification',
      'qualification_english',
      'qualification_hindi',
      'qualification',
    );

    final localizedShifts = pickLocalizedListFromNested(
      map['JobShifts'],
      'Shift',
      'shift_english',
      'shift_hindi',
      'shift',
    );

    final localizedSkills = pickLocalizedListFromNested(
      map['JobSkills'],
      'Skill',
      'skill_english',
      'skill_hindi',
      'skill',
    );

    final localizedBenefits = [
      ...pickLocalizedListFromNested(
        map['SelectedJobBenefits'],
        'JobBenefit',
        'benefit_english',
        'benefit_hindi',
        'benefit',
      ),
      ...pickLocalizedListFromFlat(
        map['selected_benefits'],
        'benefit_english',
        'benefit_hindi',
        'benefit',
      ),
    ].toSet().toList(growable: false);

    final hasInterest = _asBool(
      interest['has_interest'] ?? interest['hasInterest'],
    );

    return JobDetailDto(
      id: _asInt(map['id']),
      slug: _asNullableString(map['slug']),
      subscriptionStatus: _asNullableString(
        map['subscription_status'] ?? map['subscriptionStatus'],
      ),
      creditExpiryAt: _asDate(map['credit_expiry_at'] ?? map['creditExpiryAt']),
      contactCreditAvailable: _asInt(
        map['contact_credit_available'] ?? map['contactCreditAvailable'],
        fallback: 0,
      ),
      interestCreditAvailable: _asInt(
        map['interest_credit_available'] ?? map['interestCreditAvailable'],
        fallback: 0,
      ),
      contactCreditTotal: _asInt(
        map['contact_credit_total'] ?? map['contactCreditTotal'],
        fallback: 0,
      ),
      interestCreditTotal: _asInt(
        map['interest_credit_total'] ?? map['interestCreditTotal'],
        fallback: 0,
      ),
      employerName: pickLocalized(
        employer['name'],
        employer['name_hindi'],
        employer['name'],
      ),
      organizationName: pickLocalized(
        employer['organization_name_english'] ?? employer['organization_name'],
        employer['organization_name_hindi'],
        employer['organization_name'],
      ),
      organizationType: _asNullableString(employer['organization_type']),
      businessCategory: () {
        final bc = asMap(employer['BusinessCategory']);
        return pickLocalized(
          bc['category_english'],
          bc['category_hindi'],
          bc['category'],
        );
      }(),
      employerPhone:
          _asNullableString(contact['interviewer_contact']) ??
          _asNullableString(contact['mobile']) ??
          _asNullableString(employerUser['mobile']),
      jobProfile: pickLocalized(
        jobProfile['profile_english'],
        jobProfile['profile_hindi'],
        map['job_profile'],
      ),
      jobDesignation: pickLocalized(
        map['job_designation_english'],
        map['job_designation_hindi'],
        map['job_designation'] ?? map['jobDesignation'],
      ),
      profileImage: _asNullableString(jobProfile['profile_image']),
      jobState: pickLocalized(
        jobState['state_english'],
        jobState['state_hindi'],
        map['job_state'],
      ),
      jobCity: pickLocalized(
        jobCity['city_english'],
        jobCity['city_hindi'],
        map['job_city'],
      ),
      jobAddress: pickLocalized(
        map['job_address_english'] ?? contact['job_address_english'],
        map['job_address_hindi'] ?? contact['job_address_hindi'],
        map['job_address'] ?? contact['job_address'],
      ),
      jobLocation: _asNullableString(map['job_location'] ?? map['jobLocation']),
      lat: _asNullableDouble(map['lat']),
      lng: _asNullableDouble(map['lng']),
      salaryMin: _asNullableDouble(map['salary_min']),
      salaryMax: _asNullableDouble(map['salary_max']),
      salaryTypeId: _asNullableInt(map['salary_type_id']),
      salaryType: pickLocalized(
        salaryType['type_english'],
        salaryType['type_hindi'],
        map['salary_type'],
      ),
      noVacancy: _asNullableInt(map['no_vacancy']),
      hiredTotal: _asNullableInt(map['hired_total']),
      descriptionEnglish: pickLocalized(
        map['description_english'],
        map['description_hindi'],
        map['description'],
      ),
      otherBenefitEnglish: pickLocalized(
        map['other_benefit_english'],
        map['other_benefit_hindi'],
        map['other_benefit'],
      ),
      workStartTime: _asNullableString(map['work_start_time']),
      workEndTime: _asNullableString(map['work_end_time']),
      createdAt: _asDate(map['created_at']),
      genders: _asStringList(map['genders']),
      experiences: localizedExperiences.isNotEmpty
          ? localizedExperiences
          : _asStringList(map['experiences']),
      qualifications: localizedQualifications.isNotEmpty
          ? localizedQualifications
          : _asStringList(map['qualifications']),
      shifts: localizedShifts.isNotEmpty
          ? localizedShifts
          : _asStringList(map['shifts']),
      jobDays: _asStringList(map['job_days'] ?? map['jobDays']),
      skills: localizedSkills.isNotEmpty
          ? localizedSkills
          : _asStringList(map['skills']),
      benefits: localizedBenefits.isNotEmpty
          ? localizedBenefits
          : _asStringList(map['benefits']),
      isContactUnlocked: _asBool(contact['is_unlocked']),
      contactUnlockedAt: _asDate(
        contact['unlocked_at'] ?? contact['unlockedAt'],
      ),
      isCallExperienceShared: _asBool(
        callExperience['is_shared'] ?? callExperience['isShared'],
      ),
      hasInterest: hasInterest,
      isInterestSent: _asBool(interest['is_sent'] ?? interest['isSent']),
      isInterestReceived: _asBool(
        interest['is_received'] ?? interest['isReceived'],
      ),
      interestStatus: _asNullableString(interest['status']),
      interestStatusAt: _asDate(interest['status_at'] ?? interest['statusAt']),
      otpUnlockedAt: _asDate(
        interest['otp_unlocked_at'] ?? interest['otpUnlockedAt'],
      ),
      otp: _asNullableString(interest['otp']),
      isReported: _asBool(report['is_reported']),
      reportedAt: _asDate(
        report['reported_at'] ?? report['reportedAt'] ?? report['created_at'],
      ),
      isInWishlist: _asBool(wishlist['is_in_wishlist']),
      isEmployerVerified:
          (employerVerification ?? '').toLowerCase() == 'verified' ||
          (employerVerification ?? '').toLowerCase() == 'approved',
      showOrganization: _asBool(
        map['show_organization'] ?? map['showOrganization'],
        fallback: true,
      ),
    );
  }
}
