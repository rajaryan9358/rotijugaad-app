class EmployeeStoryDto {
  final int id;
  final String userType;

  final String titleEnglish;
  final String titleHindi;
  final String descriptionEnglish;
  final String descriptionHindi;
  final String image;

  final DateTime? expiryAt;
  final int sequence;
  final bool isActive;

  final bool isRead;
  final DateTime? readAt;

  const EmployeeStoryDto({
    required this.id,
    required this.userType,
    required this.titleEnglish,
    required this.titleHindi,
    required this.descriptionEnglish,
    required this.descriptionHindi,
    required this.image,
    required this.expiryAt,
    required this.sequence,
    required this.isActive,
    required this.isRead,
    required this.readAt,
  });

  EmployeeStoryDto copyWith({bool? isRead, DateTime? readAt}) {
    return EmployeeStoryDto(
      id: id,
      userType: userType,
      titleEnglish: titleEnglish,
      titleHindi: titleHindi,
      descriptionEnglish: descriptionEnglish,
      descriptionHindi: descriptionHindi,
      image: image,
      expiryAt: expiryAt,
      sequence: sequence,
      isActive: isActive,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
    );
  }

  static int _asInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    return int.tryParse((v ?? '').toString()) ?? fallback;
  }

  static bool _asBool(dynamic v, {bool fallback = false}) {
    if (v is bool) return v;
    final s = (v ?? '').toString().trim().toLowerCase();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0') return false;
    return fallback;
  }

  static DateTime? _asDate(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }

  factory EmployeeStoryDto.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};

    return EmployeeStoryDto(
      id: _asInt(map['id']),
      userType: (map['user_type'] ?? map['userType'] ?? '').toString(),
      titleEnglish: (map['title_english'] ?? map['titleEnglish'] ?? '')
          .toString(),
      titleHindi: (map['title_hindi'] ?? map['titleHindi'] ?? '').toString(),
      descriptionEnglish:
          (map['description_english'] ?? map['descriptionEnglish'] ?? '')
              .toString(),
      descriptionHindi:
          (map['description_hindi'] ?? map['descriptionHindi'] ?? '')
              .toString(),
      image: (map['image'] ?? '').toString(),
      expiryAt: _asDate(map['expiry_at'] ?? map['expiryAt']),
      sequence: _asInt(map['sequence']),
      isActive: _asBool(map['is_active'] ?? map['isActive']),
      isRead: _asBool(map['is_read'] ?? map['isRead']),
      readAt: _asDate(map['read_at'] ?? map['readAt']),
    );
  }
}

class EmployeeStoriesResponse {
  final List<EmployeeStoryDto> stories;

  const EmployeeStoriesResponse({required this.stories});

  factory EmployeeStoriesResponse.fromJson(Map<String, dynamic>? json) {
    final raw = json?['data'];
    final list = (raw is List) ? raw : const [];

    final stories = <EmployeeStoryDto>[];
    for (final item in list) {
      if (item is Map<String, dynamic>) {
        stories.add(EmployeeStoryDto.fromJson(item));
      } else if (item is Map) {
        stories.add(EmployeeStoryDto.fromJson(item.cast<String, dynamic>()));
      }
    }

    return EmployeeStoriesResponse(stories: stories);
  }
}

class StoryMarkReadResponse {
  final int employeeId;
  final int storyId;
  final DateTime? readAt;

  const StoryMarkReadResponse({
    required this.employeeId,
    required this.storyId,
    required this.readAt,
  });

  static int _asInt(dynamic v, {int fallback = 0}) {
    if (v is int) return v;
    return int.tryParse((v ?? '').toString()) ?? fallback;
  }

  factory StoryMarkReadResponse.fromJson(Map<String, dynamic>? json) {
    final map = json ?? const <String, dynamic>{};
    return StoryMarkReadResponse(
      employeeId: _asInt(map['employee_id'] ?? map['employer_id'] ?? map['employeeId'] ?? map['employerId']),
      storyId: _asInt(map['story_id'] ?? map['storyId']),
      readAt: DateTime.tryParse(
        (map['read_at'] ?? map['readAt'] ?? '').toString(),
      ),
    );
  }
}
