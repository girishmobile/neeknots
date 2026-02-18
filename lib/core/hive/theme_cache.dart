import 'package:shared_preferences/shared_preferences.dart';

class ThemeCache {
  static const String _themeKey = 'isDarkTheme';

  /// Save theme
  static Future<void> saveTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  /// Load theme
  static Future<bool> getTheme() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false; // false = Light Theme
  }

  /// Clear theme
  static Future<void> clearTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeKey);
  }
}
