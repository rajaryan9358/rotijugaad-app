import "json_helpers.dart";

class StateDto {
  final int id;
  final String? stateEnglish;
  final String? stateHindi;
  final int? sequence;

  const StateDto({
    required this.id,
    this.stateEnglish,
    this.stateHindi,
    this.sequence,
  });

  factory StateDto.fromJson(Map<String, dynamic>? json) {
    return StateDto(
      id: asInt(json?["id"]) ?? 0,
      stateEnglish: asString(json?["state_english"]),
      stateHindi: asString(json?["state_hindi"]),
      sequence: asInt(json?["sequence"]),
    );
  }
}

class CityDto {
  final int id;
  final int? stateId;
  final String? cityEnglish;
  final String? cityHindi;
  final int? sequence;

  const CityDto({
    required this.id,
    this.stateId,
    this.cityEnglish,
    this.cityHindi,
    this.sequence,
  });

  factory CityDto.fromJson(Map<String, dynamic>? json) {
    return CityDto(
      id: asInt(json?["id"]) ?? 0,
      stateId: asInt(json?["state_id"]),
      cityEnglish: asString(json?["city_english"]),
      cityHindi: asString(json?["city_hindi"]),
      sequence: asInt(json?["sequence"]),
    );
  }
}
