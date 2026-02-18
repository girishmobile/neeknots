import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'local_notification.dart';

class NotificationStorage {
  static const String _key = 'notifications';

  /// Save a notification (latest first)
  static Future<void> saveNotification(LocalNotification n) async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> existing =
        prefs.getStringList(_key) ?? [];

    existing.insert(0, jsonEncode(n.toMap())); // latest first

    await prefs.setStringList(_key, existing);
  }

  /// Get all notifications
  static Future<List<LocalNotification>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> jsonList =
        prefs.getStringList(_key) ?? [];

    return jsonList
        .map((e) => LocalNotification.fromMap(jsonDecode(e)))
        .toList();
  }

  /// Clear all notifications
  static Future<void> clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// Delete a single notification by index
  static Future<void> deleteNotification(int index) async {
    final prefs = await SharedPreferences.getInstance();

    final List<String> existing =
        prefs.getStringList(_key) ?? [];

    if (index >= 0 && index < existing.length) {
      existing.removeAt(index);
      await prefs.setStringList(_key, existing);
    }
  }
}
