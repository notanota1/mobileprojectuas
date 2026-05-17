// lib/services/notification_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AppNotification {
  final String title;
  final String subtitle;
  final int timestamp;

  AppNotification({
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() => {
        'title': title,
        'subtitle': subtitle,
        'timestamp': timestamp,
      };

  factory AppNotification.fromMap(Map<String, dynamic> map) => AppNotification(
        title: map['title'] as String,
        subtitle: map['subtitle'] as String,
        timestamp: map['timestamp'] as int,
      );
}

class NotificationService {
  static const _key = 'app_notifications';
  static const _lastReadKey = 'notif_last_read';

  static Future<List<AppNotification>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key) ?? '[]';
    final list = json.decode(raw) as List<dynamic>;
    return list
        .map((e) => AppNotification.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> add(AppNotification notif) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAll();
    list.insert(0, notif);
    final trimmed = list.take(30).toList();
    await prefs.setString(
      _key,
      json.encode(trimmed.map((e) => e.toMap()).toList()),
    );
  }

  static Future<int> getUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    final lastRead = prefs.getInt(_lastReadKey) ?? 0;
    final list = await getAll();
    return list.where((n) => n.timestamp > lastRead).length;
  }

  static Future<void> markAllRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _lastReadKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }
}