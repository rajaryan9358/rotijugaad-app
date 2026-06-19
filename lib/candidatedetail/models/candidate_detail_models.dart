import '../../candidates/models/candidate_summary.dart';

class CandidateEmployeeDetailDto {
  final int id;
  final String? slug;
  final String? name;
  final String? nameEnglish;
  final String? nameHindi;
  final String? aboutUser;
  final String? aboutUserEnglish;
  final String? aboutUserHindi;
  final String? mobile;
  final String? email;
  final bool? isActive;
  final String? gender;
  final String? dob;
  final String? verificationStatus;
  final String? kycStatus;
  final String? aadharNumber;
  final String? selfieLink;
  final String? currentState;
  final String? currentCity;
  final String? currentStateEnglish;
  final String? currentStateHindi;
  final String? currentCityEnglish;
  final String? currentCityHindi;
  final num? expectedSalary;
  final String? expectedSalaryFrequency;
  final String? preferredState;
  final String? preferredCity;
  final String? preferredStateEnglish;
  final String? preferredStateHindi;
  final String? preferredCityEnglish;
  final String? preferredCityHindi;
  final String? preferredShift;
  final String? preferredShiftEnglish;
  final String? preferredShiftHindi;
  final String? qualification;
  final String? qualificationEnglish;
  final String? qualificationHindi;
  final List<String> skillsEnglish;
  final List<String> skillsHindi;
  final String? createdAt;
  final double? lat;
  final double? lng;

  const CandidateEmployeeDetailDto({
    required this.id,
    required this.slug,
    required this.name,
    required this.nameEnglish,
    required this.nameHindi,
    required this.aboutUser,
    required this.aboutUserEnglish,
    required this.aboutUserHindi,
    required this.mobile,
    required this.email,
    required this.isActive,
    required this.gender,
    required this.dob,
    required this.verificationStatus,
    required this.kycStatus,
    required this.aadharNumber,
    required this.selfieLink,
    required this.currentState,
    required this.currentCity,
    required this.currentStateEnglish,
    required this.currentStateHindi,
    required this.currentCityEnglish,
    required this.currentCityHindi,
    required this.expectedSalary,
    required this.expectedSalaryFrequency,
    required this.preferredState,
    required this.preferredCity,
    required this.preferredStateEnglish,
    required this.preferredStateHindi,
    required this.preferredCityEnglish,
    required this.preferredCityHindi,
    required this.preferredShift,
    required this.preferredShiftEnglish,
    required this.preferredShiftHindi,
    required this.qualification,
    required this.qualificationEnglish,
    required this.qualificationHindi,
    required this.skillsEnglish,
    required this.skillsHindi,
    required this.createdAt,
    this.lat,
    this.lng,
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

  static List<String> _asLocalizedStringList(
    dynamic v,
    String englishKey,
    String hindiKey,
  ) {
    if (v is! List) return const [];
    final result = <String>[];
    for (final item in v) {
      if (item is Map<String, dynamic>) {
        final english = _asNullableString(item[englishKey]);
        final hindi = _asNullableString(item[hindiKey]);
        if ((english ?? '').isNotEmpty || (hindi ?? '').isNotEmpty) {
          result.add((english ?? hindi ?? '').trim());
        }
      } else if (item is Map) {
        final map = item.map((k, value) => MapEntry(k.toString(), value));
        final english = _asNullableString(map[englishKey]);
        final hindi = _asNullableString(map[hindiKey]);
        if ((english ?? '').isNotEmpty || (hindi ?? '').isNotEmpty) {
          result.add((english ?? hindi ?? '').trim());
        }
      } else {
        final value = _asNullableString(item);
        if (value != null) result.add(value);
      }
    }
    return result;
  }

  DateTime? get dobDate {
    final raw = (dob ?? '').trim();
    if (raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  factory CandidateEmployeeDetailDto.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};

    return CandidateEmployeeDetailDto(
      id: _asInt(map['id']),
      slug: _asNullableString(map['slug']),
      name: _asNullableString(map['name']),
      nameEnglish: _asNullableString(map['name_english'] ?? map['nameEnglish']),
      nameHindi: _asNullableString(map['name_hindi'] ?? map['nameHindi']),
      aboutUser: _asNullableString(map['about_user'] ?? map['aboutUser']),
      aboutUserEnglish: _asNullableString(
        map['about_user_english'] ??
            map['aboutUserEnglish'] ??
            map['about_us_english'],
      ),
      aboutUserHindi: _asNullableString(
        map['about_user_hindi'] ??
            map['aboutUserHindi'] ??
            map['about_us_hindi'],
      ),
      mobile: _asNullableString(map['mobile']),
      email: _asNullableString(map['email']),
      isActive: _asBool(map['is_active'] ?? map['isActive']),
      gender: _asNullableString(map['gender']),
      dob: _asNullableString(map['dob']),
      verificationStatus: _asNullableString(
        map['verification_status'] ?? map['verificationStatus'],
      ),
      kycStatus: _asNullableString(map['kyc_status'] ?? map['kycStatus']),
      aadharNumber: _asNullableString(
        map['aadhar_number'] ?? map['aadharNumber'],
      ),
      selfieLink: _asNullableString(map['selfie_link'] ?? map['selfieLink']),
      currentState: _asNullableString(
        map['current_state'] ?? map['currentState'],
      ),
      currentCity: _asNullableString(map['current_city'] ?? map['currentCity']),
      currentStateEnglish: _asNullableString(
        map['current_state_english'] ?? map['currentStateEnglish'],
      ),
      currentStateHindi: _asNullableString(
        map['current_state_hindi'] ?? map['currentStateHindi'],
      ),
      currentCityEnglish: _asNullableString(
        map['current_city_english'] ?? map['currentCityEnglish'],
      ),
      currentCityHindi: _asNullableString(
        map['current_city_hindi'] ?? map['currentCityHindi'],
      ),
      expectedSalary: _asNum(map['expected_salary'] ?? map['expectedSalary']),
      expectedSalaryFrequency: _asNullableString(
        map['expected_salary_frequency'] ?? map['expectedSalaryFrequency'],
      ),
      preferredState: _asNullableString(
        map['preferred_state'] ?? map['preferredState'],
      ),
      preferredStateEnglish: _asNullableString(
        map['preferred_state_english'] ?? map['preferredStateEnglish'],
      ),
      preferredStateHindi: _asNullableString(
        map['preferred_state_hindi'] ?? map['preferredStateHindi'],
      ),
      preferredCity: _asNullableString(
        map['preferred_city'] ?? map['preferredCity'],
      ),
      preferredCityEnglish: _asNullableString(
        map['preferred_city_english'] ?? map['preferredCityEnglish'],
      ),
      preferredCityHindi: _asNullableString(
        map['preferred_city_hindi'] ?? map['preferredCityHindi'],
      ),
      preferredShift: _asNullableString(
        map['preferred_shift'] ?? map['preferredShift'],
      ),
      preferredShiftEnglish: _asNullableString(
        map['preferred_shift_english'] ?? map['preferredShiftEnglish'],
      ),
      preferredShiftHindi: _asNullableString(
        map['preferred_shift_hindi'] ?? map['preferredShiftHindi'],
      ),
      qualification: _asNullableString(map['qualification']),
      qualificationEnglish: _asNullableString(
        map['qualification_english'] ?? map['qualificationEnglish'],
      ),
      qualificationHindi: _asNullableString(
        map['qualification_hindi'] ?? map['qualificationHindi'],
      ),
      skillsEnglish: _asLocalizedStringList(
        map['selected_skills'] ?? map['selectedSkills'],
        'skill_english',
        'skill_hindi',
      ),
      skillsHindi: _asLocalizedStringList(
        map['selected_skills'] ?? map['selectedSkills'],
        'skill_hindi',
        'skill_english',
      ),
      createdAt: _asNullableString(map['created_at'] ?? map['createdAt']),
      lat: (map['lat'] as num?)?.toDouble(),
      lng: (map['lng'] as num?)?.toDouble(),
    );
  }
}

class CandidateExperienceDto {
  final int id;
  final String? previousFirm;
  final num? workDuration;
  final String? workDurationFrequency;
  final String? experienceCertificate;
  final String? workNatureEnglish;
  final String? workNatureHindi;

  const CandidateExperienceDto({
    required this.id,
    required this.previousFirm,
    required this.workDuration,
    required this.workDurationFrequency,
    required this.experienceCertificate,
    required this.workNatureEnglish,
    required this.workNatureHindi,
  });

  static int _asInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
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

  factory CandidateExperienceDto.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};

    final workNature = map['WorkNature'];
    String? natureEn;
    String? natureHi;
    if (workNature is Map<String, dynamic>) {
      natureEn = _asNullableString(
        workNature['nature_english'] ?? workNature['natureEnglish'],
      );
      natureHi = _asNullableString(
        workNature['nature_hindi'] ?? workNature['natureHindi'],
      );
    } else if (workNature is Map) {
      final m = workNature.map((k, v) => MapEntry(k.toString(), v));
      natureEn = _asNullableString(m['nature_english'] ?? m['natureEnglish']);
      natureHi = _asNullableString(m['nature_hindi'] ?? m['natureHindi']);
    }

    return CandidateExperienceDto(
      id: _asInt(map['id']),
      previousFirm: _asNullableString(
        map['previous_firm'] ?? map['previousFirm'],
      ),
      workDuration: _asNum(map['work_duration'] ?? map['workDuration']),
      workDurationFrequency: _asNullableString(
        map['work_duration_frequency'] ?? map['workDurationFrequency'],
      ),
      experienceCertificate: _asNullableString(
        map['experience_certificate'] ?? map['experienceCertificate'],
      ),
      workNatureEnglish: natureEn,
      workNatureHindi: natureHi,
    );
  }
}

class CandidateContactDto {
  final bool isUnlocked;
  final String? unlockedAt;
  final int? employerContactId;
  final bool isCallExperienceShared;

  const CandidateContactDto({
    required this.isUnlocked,
    required this.unlockedAt,
    required this.employerContactId,
    required this.isCallExperienceShared,
  });

  static bool _asBool(dynamic v) {
    if (v is bool) return v;
    final s = v?.toString().trim().toLowerCase();
    return s == 'true' || s == '1';
  }

  static int? _asNullableInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static String? _asNullableString(dynamic v) {
    final s = (v?.toString() ?? '').trim();
    return s.isEmpty ? null : s;
  }

  factory CandidateContactDto.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};
    return CandidateContactDto(
      isUnlocked: _asBool(map['is_unlocked'] ?? map['isUnlocked']),
      unlockedAt: _asNullableString(map['unlocked_at'] ?? map['unlockedAt']),
      employerContactId: _asNullableInt(
        map['employer_contact_id'] ?? map['employerContactId'],
      ),
      isCallExperienceShared: _asBool(
        map['is_call_experience_shared'] ?? map['isCallExperienceShared'],
      ),
    );
  }

  CandidateContactDto copyWith({
    bool? isUnlocked,
    String? unlockedAt,
    int? employerContactId,
    bool? isCallExperienceShared,
  }) {
    return CandidateContactDto(
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      employerContactId: employerContactId ?? this.employerContactId,
      isCallExperienceShared:
          isCallExperienceShared ?? this.isCallExperienceShared,
    );
  }
}

class CandidateReportDto {
  final bool isReported;
  final String? reportedAt;

  const CandidateReportDto({
    required this.isReported,
    required this.reportedAt,
  });

  static bool _asBool(dynamic v) {
    if (v is bool) return v;
    final s = v?.toString().trim().toLowerCase();
    return s == 'true' || s == '1';
  }

  static String? _asNullableString(dynamic v) {
    final s = (v?.toString() ?? '').trim();
    return s.isEmpty ? null : s;
  }

  factory CandidateReportDto.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};
    return CandidateReportDto(
      isReported: _asBool(map['is_reported'] ?? map['isReported']),
      reportedAt: _asNullableString(map['reported_at'] ?? map['reportedAt']),
    );
  }

  CandidateReportDto copyWith({bool? isReported, String? reportedAt}) {
    return CandidateReportDto(
      isReported: isReported ?? this.isReported,
      reportedAt: reportedAt ?? this.reportedAt,
    );
  }
}

class CandidateShortlistDto {
  final bool isShortlisted;
  final String? shortlistedAt;
  final int? shortlistId;

  const CandidateShortlistDto({
    required this.isShortlisted,
    required this.shortlistedAt,
    required this.shortlistId,
  });

  static bool _asBool(dynamic v) {
    if (v is bool) return v;
    final s = v?.toString().trim().toLowerCase();
    return s == 'true' || s == '1';
  }

  static int? _asNullableInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static String? _asNullableString(dynamic v) {
    final s = (v?.toString() ?? '').trim();
    return s.isEmpty ? null : s;
  }

  factory CandidateShortlistDto.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};
    return CandidateShortlistDto(
      isShortlisted: _asBool(map['is_shortlisted'] ?? map['isShortlisted']),
      shortlistedAt: _asNullableString(
        map['shortlisted_at'] ?? map['shortlistedAt'],
      ),
      shortlistId: _asNullableInt(map['shortlist_id'] ?? map['shortlistId']),
    );
  }

  CandidateShortlistDto copyWith({
    bool? isShortlisted,
    String? shortlistedAt,
    int? shortlistId,
  }) {
    return CandidateShortlistDto(
      isShortlisted: isShortlisted ?? this.isShortlisted,
      shortlistedAt: shortlistedAt ?? this.shortlistedAt,
      shortlistId: shortlistId ?? this.shortlistId,
    );
  }
}

class CandidateDetailDto {
  final CandidateEmployeeDetailDto employee;
  final List<CandidateJobProfileDto> jobProfiles;
  final List<CandidateExperienceDto> experiences;
  final CandidateContactDto contact;
  final CandidateReportDto report;
  final CandidateShortlistDto shortlist;

  const CandidateDetailDto({
    required this.employee,
    required this.jobProfiles,
    required this.experiences,
    required this.contact,
    required this.report,
    required this.shortlist,
  });

  factory CandidateDetailDto.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};

    final rawEmployee = map['employee'];
    final employee = CandidateEmployeeDetailDto.fromJson(
      rawEmployee is Map<String, dynamic>
          ? rawEmployee
          : rawEmployee is Map
          ? rawEmployee.map((k, v) => MapEntry(k.toString(), v))
          : null,
    );

    final jobProfiles = <CandidateJobProfileDto>[];
    final rawProfiles =
        map['employee_job_profiles'] ?? map['employeeJobProfiles'];
    if (rawProfiles is List) {
      for (final item in rawProfiles) {
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

    final experiences = <CandidateExperienceDto>[];
    final rawExp = map['employee_experiences'] ?? map['employeeExperiences'];
    if (rawExp is List) {
      for (final item in rawExp) {
        if (item is Map<String, dynamic>) {
          experiences.add(CandidateExperienceDto.fromJson(item));
        } else if (item is Map) {
          experiences.add(
            CandidateExperienceDto.fromJson(
              item.map((k, v) => MapEntry(k.toString(), v)),
            ),
          );
        }
      }
    }

    final contactRaw = map['contact'];
    final contact = CandidateContactDto.fromJson(
      contactRaw is Map<String, dynamic>
          ? contactRaw
          : contactRaw is Map
          ? contactRaw.map((k, v) => MapEntry(k.toString(), v))
          : null,
    );

    final reportRaw = map['report'];
    final report = CandidateReportDto.fromJson(
      reportRaw is Map<String, dynamic>
          ? reportRaw
          : reportRaw is Map
          ? reportRaw.map((k, v) => MapEntry(k.toString(), v))
          : null,
    );

    final shortlistRaw = map['shortlist'];
    final shortlist = CandidateShortlistDto.fromJson(
      shortlistRaw is Map<String, dynamic>
          ? shortlistRaw
          : shortlistRaw is Map
          ? shortlistRaw.map((k, v) => MapEntry(k.toString(), v))
          : null,
    );

    return CandidateDetailDto(
      employee: employee,
      jobProfiles: jobProfiles,
      experiences: experiences,
      contact: contact,
      report: report,
      shortlist: shortlist,
    );
  }

  CandidateDetailDto copyWith({
    CandidateEmployeeDetailDto? employee,
    List<CandidateJobProfileDto>? jobProfiles,
    List<CandidateExperienceDto>? experiences,
    CandidateContactDto? contact,
    CandidateReportDto? report,
    CandidateShortlistDto? shortlist,
  }) {
    return CandidateDetailDto(
      employee: employee ?? this.employee,
      jobProfiles: jobProfiles ?? this.jobProfiles,
      experiences: experiences ?? this.experiences,
      contact: contact ?? this.contact,
      report: report ?? this.report,
      shortlist: shortlist ?? this.shortlist,
    );
  }
}
