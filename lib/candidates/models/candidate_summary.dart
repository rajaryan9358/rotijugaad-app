class CandidateJobProfileDto {
  final int id;
  final String profileEnglish;
  final String profileHindi;
  final String? profileImage;

  const CandidateJobProfileDto({
    required this.id,
    required this.profileEnglish,
    required this.profileHindi,
    this.profileImage,
  });

  factory CandidateJobProfileDto.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};
    final nested = (map['JobProfile'] is Map)
        ? (map['JobProfile'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};

    int asInt(dynamic v) {
      if (v is int) return v;
      return int.tryParse(v?.toString() ?? '') ?? 0;
    }

    String asString(dynamic v) => (v?.toString() ?? '').trim();
    String? asNullableString(dynamic v) {
      final s = v?.toString().trim();
      return (s == null || s.isEmpty) ? null : s;
    }

    return CandidateJobProfileDto(
      id: asInt(map['id']),
      profileEnglish: asString(
        map['profile_english'] ??
            map['profileEnglish'] ??
            nested['profile_english'],
      ),
      profileHindi: asString(
        map['profile_hindi'] ?? map['profileHindi'] ?? nested['profile_hindi'],
      ),
      profileImage: asNullableString(
        map['profile_image'] ?? map['profileImage'] ?? nested['profile_image'],
      ),
    );
  }
}

class CandidateSummaryDto {
  final int id;
  final String? name;
  final String? nameEnglish;
  final String? nameHindi;
  final String? organizationName;
  final String? organizationNameEnglish;
  final String? organizationNameHindi;
  final String? mobile;
  final bool? isActive;
  final String? gender;
  final String? verificationStatus;
  final String? kycStatus;
  final num? expectedSalary;
  final String? expectedSalaryFrequency;
  final String? preferredState;
  final String? preferredCity;
  final String? preferredStateEnglish;
  final String? preferredStateHindi;
  final String? preferredCityEnglish;
  final String? preferredCityHindi;
  final String? state;
  final String? city;
  final String? stateEnglish;
  final String? stateHindi;
  final String? cityEnglish;
  final String? cityHindi;
  final String? qualification;
  final String? preferredShift;
  final List<CandidateJobProfileDto> jobProfiles;
  final bool isShortlisted;
  final String? shortlistedAt;
  final String? selfieLink;

  const CandidateSummaryDto({
    required this.id,
    required this.name,
    this.nameEnglish,
    this.nameHindi,
    this.organizationName,
    this.organizationNameEnglish,
    this.organizationNameHindi,
    required this.mobile,
    required this.isActive,
    required this.gender,
    required this.verificationStatus,
    required this.kycStatus,
    required this.expectedSalary,
    required this.expectedSalaryFrequency,
    required this.preferredState,
    required this.preferredCity,
    this.preferredStateEnglish,
    this.preferredStateHindi,
    this.preferredCityEnglish,
    this.preferredCityHindi,
    this.state,
    this.city,
    this.stateEnglish,
    this.stateHindi,
    this.cityEnglish,
    this.cityHindi,
    required this.qualification,
    required this.preferredShift,
    required this.jobProfiles,
    required this.isShortlisted,
    required this.shortlistedAt,
    this.selfieLink,
  });

  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static bool? _asBool(dynamic v) {
    if (v == null) return null;
    if (v is bool) return v;
    final s = v.toString().trim().toLowerCase();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0') return false;
    return null;
  }

  static num? _asNum(dynamic v) {
    if (v == null) return null;
    if (v is num) return v;
    return num.tryParse(v.toString());
  }

  static String? _asNullableString(dynamic v) {
    final s = (v?.toString() ?? '').trim();
    return s.isEmpty ? null : s;
  }

  factory CandidateSummaryDto.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};
    final preferredStateMap = (map['PreferredState'] is Map)
        ? (map['PreferredState'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    final preferredCityMap = (map['PreferredCity'] is Map)
        ? (map['PreferredCity'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    final stateMap = (map['State'] is Map)
        ? (map['State'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};
    final cityMap = (map['City'] is Map)
        ? (map['City'] as Map).cast<String, dynamic>()
        : const <String, dynamic>{};

    final rawJobProfiles =
        map['job_profiles'] ??
        map['jobProfiles'] ??
        map['employee_job_profiles'];
    final rawShortlist = map['shortlist'];
    final shortlist = rawShortlist is Map<String, dynamic>
        ? rawShortlist
        : rawShortlist is Map
        ? rawShortlist.map((k, v) => MapEntry(k.toString(), v))
        : const <String, dynamic>{};
    final jobProfiles = <CandidateJobProfileDto>[];
    if (rawJobProfiles is List) {
      for (final item in rawJobProfiles) {
        if (item is Map<String, dynamic>) {
          jobProfiles.add(CandidateJobProfileDto.fromJson(item));
        } else if (item is Map) {
          jobProfiles.add(
            CandidateJobProfileDto.fromJson(
              item.map((k, v) => MapEntry(k.toString(), v)),
            ),
          );
        }
      }
    }

    return CandidateSummaryDto(
      id: _asInt(map['id']),
      name: _asNullableString(map['name']),
      nameEnglish: _asNullableString(map['name_english'] ?? map['nameEnglish']),
      nameHindi: _asNullableString(map['name_hindi'] ?? map['nameHindi']),
      organizationName: _asNullableString(
        map['organization_name'] ?? map['organizationName'],
      ),
      organizationNameEnglish: _asNullableString(
        map['organization_name_english'] ?? map['organizationNameEnglish'],
      ),
      organizationNameHindi: _asNullableString(
        map['organization_name_hindi'] ?? map['organizationNameHindi'],
      ),
      mobile: _asNullableString(map['mobile']),
      isActive: _asBool(map['is_active'] ?? map['isActive']),
      gender: _asNullableString(map['gender']),
      verificationStatus: _asNullableString(
        map['verification_status'] ?? map['verificationStatus'],
      ),
      kycStatus: _asNullableString(map['kyc_status'] ?? map['kycStatus']),
      expectedSalary: _asNum(map['expected_salary'] ?? map['expectedSalary']),
      expectedSalaryFrequency: _asNullableString(
        map['expected_salary_frequency'] ?? map['expectedSalaryFrequency'],
      ),
      preferredState: _asNullableString(
        map['preferred_state'] ??
            map['preferredState'] ??
            preferredStateMap['state_english'] ??
            preferredStateMap['state_hindi'] ??
            stateMap['state_english'] ??
            stateMap['state_hindi'] ??
            map['state'],
      ),
      preferredCity: _asNullableString(
        map['preferred_city'] ??
            map['preferredCity'] ??
            preferredCityMap['city_english'] ??
            preferredCityMap['city_hindi'] ??
            cityMap['city_english'] ??
            cityMap['city_hindi'] ??
            map['city'],
      ),
      preferredStateEnglish: _asNullableString(
        map['preferred_state_english'] ??
            map['preferredStateEnglish'] ??
            preferredStateMap['state_english'],
      ),
      preferredStateHindi: _asNullableString(
        map['preferred_state_hindi'] ??
            map['preferredStateHindi'] ??
            preferredStateMap['state_hindi'] ??
            stateMap['state_hindi'],
      ),
      preferredCityEnglish: _asNullableString(
        map['preferred_city_english'] ??
            map['preferredCityEnglish'] ??
            preferredCityMap['city_english'] ??
            cityMap['city_english'],
      ),
      preferredCityHindi: _asNullableString(
        map['preferred_city_hindi'] ??
            map['preferredCityHindi'] ??
            preferredCityMap['city_hindi'] ??
            cityMap['city_hindi'],
      ),
      state: _asNullableString(map['state']),
      city: _asNullableString(map['city']),
      stateEnglish: _asNullableString(
        map['state_english'] ??
            map['stateEnglish'] ??
            stateMap['state_english'],
      ),
      stateHindi: _asNullableString(
        map['state_hindi'] ?? map['stateHindi'] ?? stateMap['state_hindi'],
      ),
      cityEnglish: _asNullableString(
        map['city_english'] ?? map['cityEnglish'] ?? cityMap['city_english'],
      ),
      cityHindi: _asNullableString(
        map['city_hindi'] ?? map['cityHindi'] ?? cityMap['city_hindi'],
      ),
      qualification: _asNullableString(map['qualification']),
      preferredShift: _asNullableString(
        map['preferred_shift'] ?? map['preferredShift'],
      ),
      jobProfiles: jobProfiles,
      isShortlisted:
          _asBool(
            map['is_shortlisted'] ??
                map['isShortlisted'] ??
                shortlist['is_shortlisted'] ??
                shortlist['isShortlisted'],
          ) ??
          false,
      shortlistedAt: _asNullableString(
        map['shortlisted_at'] ??
            map['shortlistedAt'] ??
            shortlist['shortlisted_at'] ??
            shortlist['shortlistedAt'],
      ),
      selfieLink: _asNullableString(
        map['selfie_link'] ?? map['selfieLink'],
      ),
    );
  }

  CandidateSummaryDto copyWith({bool? isShortlisted, String? shortlistedAt}) {
    return CandidateSummaryDto(
      id: id,
      name: name,
      nameEnglish: nameEnglish,
      nameHindi: nameHindi,
      organizationName: organizationName,
      organizationNameEnglish: organizationNameEnglish,
      organizationNameHindi: organizationNameHindi,
      mobile: mobile,
      isActive: isActive,
      gender: gender,
      verificationStatus: verificationStatus,
      kycStatus: kycStatus,
      expectedSalary: expectedSalary,
      expectedSalaryFrequency: expectedSalaryFrequency,
      preferredState: preferredState,
      preferredCity: preferredCity,
      preferredStateEnglish: preferredStateEnglish,
      preferredStateHindi: preferredStateHindi,
      preferredCityEnglish: preferredCityEnglish,
      preferredCityHindi: preferredCityHindi,
      state: state,
      city: city,
      stateEnglish: stateEnglish,
      stateHindi: stateHindi,
      cityEnglish: cityEnglish,
      cityHindi: cityHindi,
      qualification: qualification,
      preferredShift: preferredShift,
      jobProfiles: jobProfiles,
      isShortlisted: isShortlisted ?? this.isShortlisted,
      shortlistedAt: shortlistedAt ?? this.shortlistedAt,
      selfieLink: selfieLink,
    );
  }
}
