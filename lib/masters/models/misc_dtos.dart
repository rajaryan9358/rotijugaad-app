import "json_helpers.dart";

class ExperienceDto {
  final int id;
  final String? titleEnglish;
  final String? titleHindi;
  final int? expFrom;
  final int? expTo;
  final String? expType;
  final int? sequence;

  const ExperienceDto({
    required this.id,
    this.titleEnglish,
    this.titleHindi,
    this.expFrom,
    this.expTo,
    this.expType,
    this.sequence,
  });

  factory ExperienceDto.fromJson(Map<String, dynamic>? json) {
    return ExperienceDto(
      id: asInt(json?["id"]) ?? 0,
      titleEnglish: asString(json?["title_english"]),
      titleHindi: asString(json?["title_hindi"]),
      expFrom: asInt(json?["exp_from"]),
      expTo: asInt(json?["exp_to"]),
      expType: asString(json?["exp_type"]),
      sequence: asInt(json?["sequence"]),
    );
  }
}

class SalaryTypeDto {
  final int id;
  final String? typeEnglish;
  final String? typeHindi;
  final int? sequence;

  const SalaryTypeDto({
    required this.id,
    this.typeEnglish,
    this.typeHindi,
    this.sequence,
  });

  factory SalaryTypeDto.fromJson(Map<String, dynamic>? json) {
    return SalaryTypeDto(
      id: asInt(json?["id"]) ?? 0,
      typeEnglish: asString(json?["type_english"]),
      typeHindi: asString(json?["type_hindi"]),
      sequence: asInt(json?["sequence"]),
    );
  }
}

class DistanceDto {
  final int id;
  final String? titleEnglish;
  final String? titleHindi;
  final double? distance;
  final int? sequence;

  const DistanceDto({
    required this.id,
    this.titleEnglish,
    this.titleHindi,
    this.distance,
    this.sequence,
  });

  factory DistanceDto.fromJson(Map<String, dynamic>? json) {
    return DistanceDto(
      id: asInt(json?["id"]) ?? 0,
      titleEnglish: asString(json?["title_english"]),
      titleHindi: asString(json?["title_hindi"]),
      distance: asDouble(json?["distance"]),
      sequence: asInt(json?["sequence"]),
    );
  }
}

class CallExperienceDto {
  final int id;
  final String? experienceEnglish;
  final String? experienceHindi;
  final int? sequence;

  const CallExperienceDto({
    required this.id,
    this.experienceEnglish,
    this.experienceHindi,
    this.sequence,
  });

  factory CallExperienceDto.fromJson(Map<String, dynamic>? json) {
    return CallExperienceDto(
      id: asInt(json?["id"]) ?? 0,
      experienceEnglish: asString(json?["experience_english"]),
      experienceHindi: asString(json?["experience_hindi"]),
      sequence: asInt(json?["sequence"]),
    );
  }
}

class ReportReasonDto {
  final int id;
  final String? reasonEnglish;
  final String? reasonHindi;
  final int? sequence;

  const ReportReasonDto({
    required this.id,
    this.reasonEnglish,
    this.reasonHindi,
    this.sequence,
  });

  factory ReportReasonDto.fromJson(Map<String, dynamic>? json) {
    return ReportReasonDto(
      id: asInt(json?["id"]) ?? 0,
      reasonEnglish: asString(json?["reason_english"]),
      reasonHindi: asString(json?["reason_hindi"]),
      sequence: asInt(json?["sequence"]),
    );
  }
}

class SalaryRangeDto {
  final int id;
  final double? salaryFrom;
  final double? salaryTo;
  final bool? isActive;

  const SalaryRangeDto({
    required this.id,
    this.salaryFrom,
    this.salaryTo,
    this.isActive,
  });

  factory SalaryRangeDto.fromJson(Map<String, dynamic>? json) {
    return SalaryRangeDto(
      id: asInt(json?["id"]) ?? 0,
      salaryFrom: asDouble(json?["salary_from"] ?? json?["salaryFrom"]),
      salaryTo: asDouble(json?["salary_to"] ?? json?["salaryTo"]),
      isActive: asBool(json?["is_active"] ?? json?["isActive"]),
    );
  }
}

class BusinessCategoryDto {
  final int id;
  final String? categoryEnglish;
  final String? categoryHindi;
  final int? sequence;

  const BusinessCategoryDto({
    required this.id,
    this.categoryEnglish,
    this.categoryHindi,
    this.sequence,
  });

  factory BusinessCategoryDto.fromJson(Map<String, dynamic>? json) {
    return BusinessCategoryDto(
      id: asInt(json?["id"]) ?? 0,
      categoryEnglish: asString(json?["category_english"]),
      categoryHindi: asString(json?["category_hindi"]),
      sequence: asInt(json?["sequence"]),
    );
  }
}

class VacancyNumberDto {
  final int id;
  final String? numberEnglish;
  final String? numberHindi;
  final int? sequence;

  const VacancyNumberDto({
    required this.id,
    this.numberEnglish,
    this.numberHindi,
    this.sequence,
  });

  factory VacancyNumberDto.fromJson(Map<String, dynamic>? json) {
    return VacancyNumberDto(
      id: asInt(json?["id"]) ?? 0,
      numberEnglish: asString(json?["number_english"]),
      numberHindi: asString(json?["number_hindi"]),
      sequence: asInt(json?["sequence"]),
    );
  }
}

class JobBenefitDto {
  final int id;
  final String? benefitEnglish;
  final String? benefitHindi;
  final int? sequence;

  const JobBenefitDto({
    required this.id,
    this.benefitEnglish,
    this.benefitHindi,
    this.sequence,
  });

  factory JobBenefitDto.fromJson(Map<String, dynamic>? json) {
    return JobBenefitDto(
      id: asInt(json?["id"]) ?? 0,
      benefitEnglish: asString(json?["benefit_english"]),
      benefitHindi: asString(json?["benefit_hindi"]),
      sequence: asInt(json?["sequence"]),
    );
  }
}
