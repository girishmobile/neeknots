import 'package:shared_preferences/shared_preferences.dart';

class AppLockStorage {
  static const _key = 'app_lock_enabled';
  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> enable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
