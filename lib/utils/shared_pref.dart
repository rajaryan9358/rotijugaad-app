import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefUtils {
  static String USER_TYPE = "user_type";

  static const String AUTH_LOGGED_IN = "auth_logged_in";
  static const String AUTH_USER_JSON = "auth_user_json";
  static const String AUTH_PROFILE_TYPE = "auth_profile_type";
  static const String AUTH_PROFILE_JSON = "auth_profile_json";
  static const String AUTH_PROFILE_COMPLETED = "auth_profile_completed";

  static const String APP_LANGUAGE = "app_language";
  static const String APP_SETTINGS_JSON = "app_settings_json";
  static const String JOBS_FILTERS_JSON = "jobs_filters_json";
  static const String CANDIDATES_FILTERS_JSON = "candidates_filters_json";

  static const String INBOX_NOTIFICATIONS_JSON = "inbox_notifications_json";
  static const String SERVER_NOTIFICATIONS_UNREAD_COUNT =
      "server_notifications_unread_count";

  static const String PENDING_DEEPLINK_JSON = "pending_deeplink_json";

  static const String HAS_SEEN_HOME = "has_seen_home";

  static late SharedPreferences _preferences;

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future saveStr(String key, String message) async {
    await _preferences.setString(key, message);
  }

  static String readStr(String key) {
    return _preferences.getString(key) ?? "";
  }

  static Future saveInt(String key, int message) async {
    await _preferences.setInt(key, message);
  }

  static int readInt(String key) {
    return _preferences.getInt(key) ?? 0;
  }

  static Future saveBool(String key, bool value) async {
    await _preferences.setBool(key, value);
  }

  static bool readBool(String key) {
    return _preferences.getBool(key) ?? false;
  }

  static Future saveJson(String key, Map<String, dynamic> value) async {
    await saveStr(key, jsonEncode(value));
  }

  static Map<String, dynamic>? readJson(String key) {
    final raw = readStr(key);
    if (raw.trim().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  static Future saveJsonList(
    String key,
    List<Map<String, dynamic>> value,
  ) async {
    await saveStr(key, jsonEncode(value));
  }

  static List<Map<String, dynamic>> readJsonList(String key) {
    final raw = readStr(key);
    if (raw.trim().isEmpty) return <Map<String, dynamic>>[];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <Map<String, dynamic>>[];

      return decoded
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  static Future clearAuthSession() async {
    await saveBool(AUTH_LOGGED_IN, false);
    await saveStr(AUTH_USER_JSON, '');
    await saveStr(AUTH_PROFILE_TYPE, '');
    await saveStr(AUTH_PROFILE_JSON, '');
    await saveBool(AUTH_PROFILE_COMPLETED, false);
    await saveStr(USER_TYPE, '');
    await saveStr(INBOX_NOTIFICATIONS_JSON, '');
    await saveInt(SERVER_NOTIFICATIONS_UNREAD_COUNT, 0);
    await saveBool(HAS_SEEN_HOME, false);
  }

  static Future clear() async {
    return _preferences.clear();
  }
}
