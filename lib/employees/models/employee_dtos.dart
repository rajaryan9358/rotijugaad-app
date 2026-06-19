import "../../masters/models/document_dtos.dart";
import "../../masters/models/job_profile_dtos.dart";
import "../../masters/models/json_helpers.dart";
import "../../masters/models/location_dtos.dart";
import "../../masters/models/work_dtos.dart";

class EmployeeSubscriptionPlanDto {
  final int id;
  final String? planNameEnglish;
  final String? planNameHindi;
  final int? planValidityDays;
  final double? planPrice;

  const EmployeeSubscriptionPlanDto({
    required this.id,
    this.planNameEnglish,
    this.planNameHindi,
    this.planValidityDays,
    this.planPrice,
  });

  factory EmployeeSubscriptionPlanDto.fromJson(Map<String, dynamic>? json) {
    return EmployeeSubscriptionPlanDto(
      id: asInt(json?["id"]) ?? 0,
      planNameEnglish: asString(json?["plan_name_english"]),
      planNameHindi: asString(json?["plan_name_hindi"]),
      planValidityDays: asInt(json?["plan_validity_days"]),
      planPrice: asDouble(json?["plan_price"]),
    );
  }
}

class EmployeeDto {
  final int id;
  final int? userId;
  final String? name;

  final String? dob;
  final String? gender;

  final int? stateId;
  final int? cityId;
  final int? preferredStateId;
  final int? preferredCityId;
  final String? preferredLocation;
  final int? qualificationId;
  final int? preferredShiftId;

  final double? expectedSalary;
  final String? expectedSalaryFrequency;

  final String? assistantCode;
  final String? email;
  final String? aboutUser;

  final String? aadharNumber;
  final String? aadharVerifiedAt;
  final String? selfieLink;

  final String? verificationStatus;
  final String? verificationAt;
  final String? kycStatus;
  final String? kycVerificationAt;

  final int? contactCredit;
  final double? interestCredit;

  final List<int> skillIds;
  final List<SkillDto> selectedSkills;

  final StateDto? state;
  final CityDto? city;
  final StateDto? preferredState;
  final CityDto? preferredCity;
  final QualificationDto? qualification;
  final ShiftDto? shift;
  final EmployeeSubscriptionPlanDto? subscriptionPlan;

  /// Entire backend payload for forward-compat.
  final Map<String, dynamic> raw;

  const EmployeeDto({
    required this.id,
    required this.userId,
    required this.name,
    required this.dob,
    required this.gender,
    required this.stateId,
    required this.cityId,
    required this.preferredStateId,
    required this.preferredCityId,
    required this.preferredLocation,
    required this.qualificationId,
    required this.preferredShiftId,
    required this.expectedSalary,
    required this.expectedSalaryFrequency,
    required this.assistantCode,
    required this.email,
    required this.aboutUser,
    required this.aadharNumber,
    required this.aadharVerifiedAt,
    required this.selfieLink,
    required this.verificationStatus,
    required this.verificationAt,
    required this.kycStatus,
    required this.kycVerificationAt,
    required this.contactCredit,
    required this.interestCredit,
    required this.skillIds,
    required this.selectedSkills,
    required this.state,
    required this.city,
    required this.preferredState,
    required this.preferredCity,
    required this.qualification,
    required this.shift,
    required this.subscriptionPlan,
    required this.raw,
  });

  factory EmployeeDto.fromJson(Map<String, dynamic>? json) {
    final payload = json ?? const <String, dynamic>{};

    final rawSkillIds = payload["skill_ids"];
    final skillIds = <int>[];
    if (rawSkillIds is List) {
      for (final v in rawSkillIds) {
        final n = asInt(v);
        if (n != null) skillIds.add(n);
      }
    }

    final selectedSkills = asMapList(
      payload["selected_skills"],
    ).map(SkillDto.fromJson).toList();

    return EmployeeDto(
      id: asInt(payload["id"]) ?? 0,
      userId: asInt(payload["user_id"]) ?? asInt(payload["userId"]),
      name: asString(payload["name"]),
      dob: asString(payload["dob"]),
      gender: asString(payload["gender"]),
      stateId: asInt(payload["state_id"]),
      cityId: asInt(payload["city_id"]),
      preferredStateId: asInt(payload["preferred_state_id"]),
      preferredCityId: asInt(payload["preferred_city_id"]),
      preferredLocation: asString(payload["preferred_location"]),
      qualificationId: asInt(payload["qualification_id"]),
      preferredShiftId: asInt(payload["preferred_shift_id"]),
      expectedSalary: asDouble(payload["expected_salary"]),
      expectedSalaryFrequency: asString(payload["expected_salary_frequency"]),
      assistantCode: asString(payload["assistant_code"]),
      email: asString(payload["email"]),
      aboutUser: asString(payload["about_user"]),
      aadharNumber: asString(payload["aadhar_number"]),
      aadharVerifiedAt: asString(payload["aadhar_verified_at"]),
      selfieLink: asString(payload["selfie_link"]),
      verificationStatus: asString(payload["verification_status"]),
      verificationAt: asString(payload["verification_at"]),
      kycStatus: asString(payload["kyc_status"]),
      kycVerificationAt: asString(payload["kyc_verification_at"]),
      contactCredit: asInt(payload["contact_credit"]),
      interestCredit: asDouble(payload["interest_credit"]),
      skillIds: skillIds,
      selectedSkills: selectedSkills,
      state: StateDto.fromJson(asMap(payload["State"])),
      city: CityDto.fromJson(asMap(payload["City"])),
      preferredState: StateDto.fromJson(asMap(payload["PreferredState"])),
      preferredCity: CityDto.fromJson(asMap(payload["PreferredCity"])),
      qualification: QualificationDto.fromJson(asMap(payload["Qualification"])),
      shift: ShiftDto.fromJson(asMap(payload["Shift"])),
      subscriptionPlan: payload["SubscriptionPlan"] == null
          ? null
          : EmployeeSubscriptionPlanDto.fromJson(
              asMap(payload["SubscriptionPlan"]),
            ),
      raw: payload,
    );
  }
}

class EmployeeDetailResponse {
  final EmployeeDto employee;

  const EmployeeDetailResponse({required this.employee});

  factory EmployeeDetailResponse.fromJson(Map<String, dynamic>? json) {
    final emp = asMap(json?["employee"]) ?? json ?? const <String, dynamic>{};
    return EmployeeDetailResponse(employee: EmployeeDto.fromJson(emp));
  }
}

class EmployeeJobProfilesResponse {
  final List<JobProfileDto> profiles;

  const EmployeeJobProfilesResponse({required this.profiles});

  factory EmployeeJobProfilesResponse.fromJson(Map<String, dynamic>? json) {
    final list = asMapList(json?["data"]);
    return EmployeeJobProfilesResponse(
      profiles: list.map(JobProfileDto.fromJson).toList(),
    );
  }
}

class EmployeeExperienceDto {
  final int id;
  final int? userId;
  final int? documentTypeId;
  final int? workNatureId;
  final String? previousFirm;
  final double? workDuration;
  final String? workDurationFrequency;
  final String? experienceCertificate;

  final WorkNatureDto? workNature;
  final DocumentTypeDto? documentType;

  final Map<String, dynamic> raw;

  const EmployeeExperienceDto({
    required this.id,
    required this.userId,
    required this.documentTypeId,
    required this.workNatureId,
    required this.previousFirm,
    required this.workDuration,
    required this.workDurationFrequency,
    required this.experienceCertificate,
    required this.workNature,
    required this.documentType,
    required this.raw,
  });

  factory EmployeeExperienceDto.fromJson(Map<String, dynamic>? json) {
    final payload = json ?? const <String, dynamic>{};
    return EmployeeExperienceDto(
      id: asInt(payload["id"]) ?? 0,
      userId: asInt(payload["user_id"]) ?? asInt(payload["userId"]),
      documentTypeId: asInt(payload["document_type_id"]),
      workNatureId: asInt(payload["work_nature_id"]),
      previousFirm: asString(payload["previous_firm"]),
      workDuration: asDouble(payload["work_duration"]),
      workDurationFrequency: asString(payload["work_duration_frequency"]),
      experienceCertificate: asString(payload["experience_certificate"]),
      workNature: payload["WorkNature"] == null
          ? null
          : WorkNatureDto.fromJson(asMap(payload["WorkNature"])),
      documentType: payload["DocumentType"] == null
          ? null
          : DocumentTypeDto.fromJson(asMap(payload["DocumentType"])),
      raw: payload,
    );
  }
}

class EmployeeExperiencesResponse {
  final List<EmployeeExperienceDto> experiences;

  const EmployeeExperiencesResponse({required this.experiences});

  factory EmployeeExperiencesResponse.fromJson(Map<String, dynamic>? json) {
    final list = asMapList(json?["data"]);
    return EmployeeExperiencesResponse(
      experiences: list.map(EmployeeExperienceDto.fromJson).toList(),
    );
  }
}

class EmployeeDocumentDto {
  final int id;
  final int? userId;
  final String? documentType;
  final String? documentName;
  final int? documentSize;
  final String? documentLink;

  final DocumentTypeDto? documentTypeMeta;

  final Map<String, dynamic> raw;

  const EmployeeDocumentDto({
    required this.id,
    required this.userId,
    required this.documentType,
    required this.documentName,
    required this.documentSize,
    required this.documentLink,
    required this.documentTypeMeta,
    required this.raw,
  });

  factory EmployeeDocumentDto.fromJson(Map<String, dynamic>? json) {
    final payload = json ?? const <String, dynamic>{};
    return EmployeeDocumentDto(
      id: asInt(payload["id"]) ?? 0,
      userId: asInt(payload["user_id"]) ?? asInt(payload["userId"]),
      documentType: asString(payload["document_type"]),
      documentName: asString(payload["document_name"]),
      documentSize: asInt(payload["document_size"]),
      documentLink: asString(payload["document_link"]),
      documentTypeMeta: payload["DocumentType"] == null
          ? null
          : DocumentTypeDto.fromJson(asMap(payload["DocumentType"])),
      raw: payload,
    );
  }
}

class EmployeeDocumentsResponse {
  final List<EmployeeDocumentDto> documents;

  const EmployeeDocumentsResponse({required this.documents});

  factory EmployeeDocumentsResponse.fromJson(Map<String, dynamic>? json) {
    final list = asMapList(json?["data"]);
    return EmployeeDocumentsResponse(
      documents: list.map(EmployeeDocumentDto.fromJson).toList(),
    );
  }
}

class DeleteResponse {
  final int id;

  const DeleteResponse({required this.id});

  factory DeleteResponse.fromJson(Map<String, dynamic>? json) {
    return DeleteResponse(id: asInt(json?["id"]) ?? 0);
  }
}

class AadhaarSendOtpResponse {
  final int employeeId;
  final String? otp;

  const AadhaarSendOtpResponse({required this.employeeId, this.otp});

  factory AadhaarSendOtpResponse.fromJson(Map<String, dynamic>? json) {
    return AadhaarSendOtpResponse(
      employeeId: asInt(json?["employee_id"]) ?? 0,
      otp: asString(json?["otp"]),
    );
  }
}

extension EmployeeDtoApiFields on EmployeeDto {
  double? get lat => asDouble(raw["lat"]);
  double? get lng => asDouble(raw["lng"]);

  int? get subscriptionPlanId => asInt(raw["subscription_plan_id"]);

  String? get aadharNumberPending => asString(raw["aadhar_number_pending"]);
  String? get aadharOtp => asString(raw["aadhar_otp"]);

  int? get contactCreditTotal => asInt(raw["contact_credit_total"]);
  int? get contactCreditUsed => asInt(raw["contact_credit_used"]);
  int? get contactCreditBalance => asInt(raw["contact_credit_balance"]);

  double? get interestCreditTotal => asDouble(raw["interest_credit_total"]);
  double? get interestCreditUsed => asDouble(raw["interest_credit_used"]);
  double? get interestCreditBalance => asDouble(raw["interest_credit_balance"]);

  String? get createdAt => asString(raw["created_at"]);
  String? get updatedAt => asString(raw["updated_at"]);
}
