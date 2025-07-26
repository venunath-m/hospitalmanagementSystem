import 'package:hms/service_utilities/enums_utils.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const _themePrefKey = 'appThemeMode';
  static const _backgroundPrefKey = 'selectedBackgroundImage';

  AppThemeMode _themeMode = AppThemeMode.system;
  bool _isDarkBackground = false;

  // Add this:
  String _selectedBackground = 'assets/backgrounds/bg6.png';

  AppThemeMode get themeMode => _themeMode;

  ThemeMode get materialThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
      default:
        return ThemeMode.light; // fallback
    }
  }

  /// You can also add this to get custom ThemeData for colors:
  ThemeData get customThemeData {
    switch (_themeMode) {
      case AppThemeMode.dark:
        return ThemeData.dark();
      case AppThemeMode.light:
        return ThemeData.light();
      default:
        return ThemeData.light();
    }
  }

  bool get isDarkBackground => _isDarkBackground;

  String get selectedBackground => _selectedBackground;

  void updateDarkBackground(bool value) {
    _isDarkBackground = value;
    notifyListeners();
  }

  // New method to update background image and save to preferences:
  Future<void> setSelectedBackground(String bg) async {
    _selectedBackground = bg;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backgroundPrefKey, bg);
    notifyListeners();
  }

  // Update loadTheme to also load saved background:
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    final storedTheme = prefs.getString(_themePrefKey);
    if (storedTheme != null) {
      _themeMode = AppThemeMode.values.firstWhere(
        (e) => e.toString() == storedTheme,
        orElse: () => AppThemeMode.system,
      );
    }

    _selectedBackground =
        prefs.getString(_backgroundPrefKey) ?? 'assets/backgrounds/bg6.png';

    // Also update _isDarkBackground based on the loaded background:
    _isDarkBackground = _selectedBackground.toLowerCase().contains('dark');

    notifyListeners();
  }

  Future<void> setTheme(AppThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themePrefKey, mode.toString());
    notifyListeners();
  }
}
