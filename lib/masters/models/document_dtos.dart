import "json_helpers.dart";

class DocumentTypeDto {
  final int id;
  final String? typeEnglish;
  final String? typeHindi;
  final int? sequence;

  const DocumentTypeDto({
    required this.id,
    this.typeEnglish,
    this.typeHindi,
    this.sequence,
  });

  factory DocumentTypeDto.fromJson(Map<String, dynamic>? json) {
    return DocumentTypeDto(
      id: asInt(json?["id"]) ?? 0,
      typeEnglish: asString(json?["type_english"]),
      typeHindi: asString(json?["type_hindi"]),
      sequence: asInt(json?["sequence"]),
    );
  }
}

class WorkNatureDto {
  final int id;
  final String? natureEnglish;
  final String? natureHindi;
  final int? sequence;

  const WorkNatureDto({
    required this.id,
    this.natureEnglish,
    this.natureHindi,
    this.sequence,
  });

  factory WorkNatureDto.fromJson(Map<String, dynamic>? json) {
    return WorkNatureDto(
      id: asInt(json?["id"]) ?? 0,
      natureEnglish: asString(json?["nature_english"]),
      natureHindi: asString(json?["nature_hindi"]),
      sequence: asInt(json?["sequence"]),
    );
  }
}
