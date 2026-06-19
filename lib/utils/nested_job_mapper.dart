import "../jobs/models/job_dto.dart";

Map<String, dynamic>? _asMap(dynamic v) {
  if (v is Map) return v.cast<String, dynamic>();
  return null;
}

String? _asString(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  return s.isEmpty ? null : s;
}

String? _pickLang(Map<String, dynamic>? obj, String a, String b) {
  if (obj == null) return null;
  return _asString(obj[a]) ?? _asString(obj[b]);
}

String? _formatTime12(String? hhmmss) {
  final raw = (hhmmss ?? "").trim();
  if (raw.isEmpty) return null;

  final parts = raw.split(":");
  if (parts.length < 2) return null;

  final h = int.tryParse(parts[0]);
  final m = int.tryParse(parts[1]);
  if (h == null || m == null) return null;

  final period = h >= 12 ? "PM" : "AM";
  final hour12 = (h % 12 == 0) ? 12 : (h % 12);
  final minute = m.toString().padLeft(2, "0");
  return "${hour12}:${minute} ${period}";
}

String? _shiftTimingDisplay(String? start, String? end) {
  final a = _formatTime12(start);
  final b = _formatTime12(end);
  if (a == null && b == null) return null;
  if (a != null && b != null) return "${a} - ${b}";
  return a ?? b;
}

JobDto jobDtoFromNestedJobEmployer({
  required Map<String, dynamic>? job,
  required Map<String, dynamic>? employer,
  bool? isInWishlist,
}) {
  final jp = _asMap(job?["JobProfile"]);
  final st = _asMap(job?["SalaryType"]);
  final js = _asMap(job?["JobState"]);
  final jc = _asMap(job?["JobCity"]);

  final start = _asString(job?["work_start_time"]);
  final end = _asString(job?["work_end_time"]);

  final combined = <String, dynamic>{
    ...?job,
    "job_profile": _asString(job?["job_profile"]) ??
        _pickLang(jp, "profile_english", "profile_hindi"),
    "salary_type": _asString(job?["salary_type"]) ??
        _pickLang(st, "type_english", "type_hindi"),
    "job_state": _asString(job?["job_state"]) ??
        _pickLang(js, "state_english", "state_hindi"),
    "job_city": _asString(job?["job_city"]) ??
        _pickLang(jc, "city_english", "city_hindi"),
    "shift_timing_display": _asString(job?["shift_timing_display"]) ??
        _shiftTimingDisplay(start, end),
    "employer_name": _asString(job?["employer_name"]) ??
        _asString(employer?["name"]) ??
        _asString(employer?["employer_name"]),
    "organization_name": _asString(job?["organization_name"]) ??
        _asString(employer?["organization_name"]),
    "organization_type": _asString(job?["organization_type"]) ??
        _asString(employer?["organization_type"]),
    "employer_phone": _asString(job?["employer_phone"]) ??
        _asString(employer?["phone"]) ??
        _asString(_asMap(employer?["User"])?["mobile"]),
    "is_in_wishlist": isInWishlist ??
        (job?["is_in_wishlist"] ?? job?["is_wishlisted"] ?? false),
  };

  return JobDto.fromJson(combined);
}
