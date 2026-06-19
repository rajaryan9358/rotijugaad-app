import "json_helpers.dart";

class SkillDto {
  final int id;
  final String? skillEnglish;
  final String? skillHindi;
  final int? sequence;

  const SkillDto({
    required this.id,
    this.skillEnglish,
    this.skillHindi,
    this.sequence,
  });

  factory SkillDto.fromJson(Map<String, dynamic>? json) {
    return SkillDto(
      id: asInt(json?["id"]) ?? 0,
      skillEnglish: asString(json?["skill_english"]),
      skillHindi: asString(json?["skill_hindi"]),
      sequence: asInt(json?["sequence"]),
    );
  }
}

class QualificationDto {
  final int id;
  final String? qualificationEnglish;
  final String? qualificationHindi;
  final int? sequence;

  const QualificationDto({
    required this.id,
    this.qualificationEnglish,
    this.qualificationHindi,
    this.sequence,
  });

  factory QualificationDto.fromJson(Map<String, dynamic>? json) {
    return QualificationDto(
      id: asInt(json?["id"]) ?? 0,
      qualificationEnglish: asString(json?["qualification_english"]),
      qualificationHindi: asString(json?["qualification_hindi"]),
      sequence: asInt(json?["sequence"]),
    );
  }
}

class ShiftDto {
  final int id;
  final String? shiftEnglish;
  final String? shiftHindi;
  final String? shiftFrom;
  final String? shiftTo;
  final int? sequence;

  const ShiftDto({
    required this.id,
    this.shiftEnglish,
    this.shiftHindi,
    this.shiftFrom,
    this.shiftTo,
    this.sequence,
  });

  factory ShiftDto.fromJson(Map<String, dynamic>? json) {
    return ShiftDto(
      id: asInt(json?["id"]) ?? 0,
      shiftEnglish: asString(json?["shift_english"]),
      shiftHindi: asString(json?["shift_hindi"]),
      shiftFrom: asString(json?["shift_from"]),
      shiftTo: asString(json?["shift_to"]),
      sequence: asInt(json?["sequence"]),
    );
  }
}
