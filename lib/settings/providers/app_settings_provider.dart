import 'package:flutter/foundation.dart';

import '../../utils/custom_exception.dart';
import '../../utils/result.dart';
import '../../utils/shared_pref.dart';
import '../models/app_settings.dart';
import '../services/app_settings_service.dart';

class AppSettingsProvider extends ChangeNotifier {
  final AppSettingsService _service;

  AppSettings _settings;
  bool _loadedOnce = false;
  bool _isLoading = false;
  CustomException? _lastError;

  AppSettingsProvider({AppSettingsService? service})
    : _service = service ?? AppSettingsService(),
      _settings = AppSettings.fromJson(
        SharedPrefUtils.readJson(SharedPrefUtils.APP_SETTINGS_JSON),
      ) {
    _loadedOnce = !_settings.isEmpty;
  }

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;
  CustomException? get lastError => _lastError;

  void reset() {
    _settings = const AppSettings.empty();
    _loadedOnce = false;
    _isLoading = false;
    _lastError = null;
    notifyListeners();
  }

  Future<void> loadSettings({bool force = false}) async {
    if (_isLoading) return;
    if (!force && _loadedOnce) return;

    _isLoading = true;
    _lastError = null;
    notifyListeners();

    final result = await _service.getSettings();
    switch (result) {
      case Success(value: final data):
        _settings = data;
        _loadedOnce = true;
        await SharedPrefUtils.saveJson(
          SharedPrefUtils.APP_SETTINGS_JSON,
          data.toJson(),
        );
        break;
      case Failure(exception: final exception):
        _lastError = exception;
        break;
    }

    _isLoading = false;
    notifyListeners();
  }
}
