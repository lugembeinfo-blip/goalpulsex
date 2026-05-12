import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationStore {
  static const String key = "real_notifications";

  static Future<void> saveNotification({
    required String title,
    required String body,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final oldList = prefs.getStringList(key) ?? [];

    final item = jsonEncode({
      "title": title,
      "body": body,
      "time": DateTime.now().toIso8601String(),
    });

    oldList.insert(0, item);

    await prefs.setStringList(key, oldList);
  }

  static Future<List<Map<String, dynamic>>> getNotifications() async {
    final prefs = await SharedPreferences.getInstance();

    final list = prefs.getStringList(key) ?? [];

    return list.map((item) {
      return jsonDecode(item) as Map<String, dynamic>;
    }).toList();
  }

  static Future<void> clearNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}