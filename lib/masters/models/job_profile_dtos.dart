import "json_helpers.dart";

class JobProfileDto {
  final int id;
  final String? profileEnglish;
  final String? profileHindi;
  final String? profileImage;
  final int? sequence;

  const JobProfileDto({
    required this.id,
    this.profileEnglish,
    this.profileHindi,
    this.profileImage,
    this.sequence,
  });

  factory JobProfileDto.fromJson(Map<String, dynamic>? json) {
    return JobProfileDto(
      id: asInt(json?["id"]) ?? 0,
      profileEnglish: asString(json?["profile_english"]),
      profileHindi: asString(json?["profile_hindi"]),
      profileImage: asString(json?["profile_image"]),
      sequence: asInt(json?["sequence"]),
    );
  }
}
