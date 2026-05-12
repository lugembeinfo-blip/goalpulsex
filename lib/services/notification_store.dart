import 'dart:convert';
import 'package:flutter/foundation.dart';

class NotificationStore {
  static final List<Map<String, dynamic>> _notifications = [];

  static Future<void> saveNotification({
    required String title,
    required String body,
  }) async {
    final notification = {
      "title": title,
      "body": body,
      "time": DateTime.now().toIso8601String(),
    };
    _notifications.insert(0, notification);
    if (kDebugMode) {
      debugPrint("Notification saved: $title");
    }
  }

  static Future<List<Map<String, dynamic>>> getNotifications() async {
    // Return a copy to avoid external modification
    return List<Map<String, dynamic>>.from(_notifications);
  }

  static Future<void> clearNotifications() async {
    _notifications.clear();
  }
}
