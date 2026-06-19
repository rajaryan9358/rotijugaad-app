import 'package:flutter/foundation.dart';

import '../../utils/shared_pref.dart';
import '../../utils/result.dart';
import '../../users/services/users_service.dart';

enum AppLanguage { en, hi }

class LanguageProvider extends ChangeNotifier {
  AppLanguage _language = AppLanguage.en;

  LanguageProvider() {
    final stored = SharedPrefUtils.readStr(SharedPrefUtils.APP_LANGUAGE);
    _language = stored.trim().toLowerCase() == 'hi'
        ? AppLanguage.hi
        : AppLanguage.en;
  }

  AppLanguage get language => _language;

  String get languageCode => _language == AppLanguage.hi ? 'hi' : 'en';

  String get apiLangHeader => languageCode;

  bool get isHindi => _language == AppLanguage.hi;

  Future<void> setLanguage(AppLanguage language) async {
    final didChange = _language != language;
    _language = language;

    final nextCode = languageCode;
    await SharedPrefUtils.saveStr(SharedPrefUtils.APP_LANGUAGE, nextCode);

    // If user is logged in, persist language on backend too.
    try {
      final isLoggedIn = SharedPrefUtils.readBool(
        SharedPrefUtils.AUTH_LOGGED_IN,
      );
      final userJson = SharedPrefUtils.readJson(SharedPrefUtils.AUTH_USER_JSON);
      final userId = (userJson?['id'] as num?)?.toInt();

      if (isLoggedIn && userId != null && userId > 0) {
        final response = await UsersService().updatePreferredLanguage(
          userId: userId,
          preferredLanguage: nextCode,
        );

        switch (response) {
          case Success(value: final data):
            final user = data['user'];
            if (user is Map<String, dynamic>) {
              await SharedPrefUtils.saveJson(
                SharedPrefUtils.AUTH_USER_JSON,
                user,
              );
            }
            break;
          case Failure():
            break;
        }
      }
    } catch (_) {
      // Best-effort; ignore failures.
    }

    if (didChange) notifyListeners();
  }
}
