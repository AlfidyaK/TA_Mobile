import 'package:flutter/material.dart';

/// ThemeProvider: State management untuk tema aplikasi
/// Menyimpan pilihan tema user (light/dark/system) secara independen
/// dari setting device, menggunakan ChangeNotifier agar UI auto-rebuild
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;
  bool get isLight => _themeMode == ThemeMode.light;
  bool get isSystem => _themeMode == ThemeMode.system;

  /// Ganti tema ke mode tertentu
  void setTheme(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  /// Toggle antara light dan dark (berguna untuk switch button)
  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    notifyListeners();
  }
}