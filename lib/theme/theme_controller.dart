// lib/theme/theme_controller.dart
import 'package:flutter/material.dart';
import 'app_theme.dart';

class ThemeController extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;
  ThemeData get lightTheme => AppTheme.light();
  ThemeData get darkTheme => AppTheme.dark();

  void setMode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }

  void toggleMode() {
    if (_mode == ThemeMode.light) {
      _mode = ThemeMode.dark;
    } else if (_mode == ThemeMode.dark) {
      _mode = ThemeMode.light;
    } else {
      // if system, default to light on toggle
      _mode = ThemeMode.light;
    }
    notifyListeners();
  }
}
