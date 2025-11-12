import 'package:flutter/material.dart';

import '../core/hive/theme_cache.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDark = false;


  bool get isDark => _isDark;
  bool _isNotification = false;
  bool get isNotification => _isNotification;

  ThemeProvider() {
    _loadTheme();
  }

  /// Toggle between Dark & Light Theme
  void toggleTheme() {
    _isDark = !_isDark;
    ThemeCache.saveTheme(_isDark);
    notifyListeners();
  }

  /// Load theme preference from cache
  Future<void> _loadTheme() async {
    _isDark = await ThemeCache.getTheme();
    notifyListeners();
  }

  /// Set notification state explicitly
  void setNotification(bool value) {
    _isNotification = value;
    notifyListeners();
  }

  /// Toggle notification state
  void toggleNotification() {
    _isNotification = !_isNotification;
    notifyListeners();
  }
}
