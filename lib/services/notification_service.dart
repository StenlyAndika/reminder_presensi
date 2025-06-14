import 'dart:io';

import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:timezone/timezone.dart' as tz;
import '../main.dart';
import '../models/schedule_model.dart';

void saveSchedule(String key, TimeOfDay time) {
  var box = Hive.box('scheduleBox');
  box.put(key, ScheduleModel(hour: time.hour, minute: time.minute));
}

TimeOfDay loadSchedule(String key, {required TimeOfDay fallback}) {
  var box = Hive.box('scheduleBox');
  final saved = box.get(key);
  return saved?.toTimeOfDay() ?? fallback;
}

class NotificationService {
	static final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    await _initNotification();
    await _requestNotificationPermission();
  }
}

Future<void> _initNotification() async {
  const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');

  final initSettings = InitializationSettings(android: androidInit);

  await notificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      openAbsenApp();
    },
  );
}

void openAbsenApp() async {
  await LaunchApp.openApp(
    androidPackageName: 'com.waroengweb.absensi',
    openStore: true,
  );
}

Future<void> _requestNotificationPermission() async {
  if (Platform.isAndroid) {
    final androidPlugin =
        notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }
}

String _formatTime(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

void scheduleCustomNotifications({
  required TimeOfDay monThuPagi,
  required TimeOfDay monThuSiang,
  required TimeOfDay monThuSore,
  required TimeOfDay friPagi,
  required TimeOfDay friSore,
}) {
  for (int weekday = DateTime.monday; weekday <= DateTime.thursday; weekday++) {
    _scheduleDailyNotification(
      weekday * 10 + 0,
      weekday,
      monThuPagi.hour,
      monThuPagi.minute,
      '${_formatTime(monThuPagi)} - Absen Pagi',
    );
    _scheduleDailyNotification(
      weekday * 10 + 1,
      weekday,
      monThuSiang.hour,
      monThuSiang.minute,
      '${_formatTime(monThuSiang)} - Absen Siang',
    );
    _scheduleDailyNotification(
      weekday * 10 + 2,
      weekday,
      monThuSore.hour,
      monThuSore.minute,
      '${_formatTime(monThuSore)} - Absen Sore',
    );
  }

  _scheduleDailyNotification(
    50,
    DateTime.friday,
    friPagi.hour,
    friPagi.minute,
    '${_formatTime(friPagi)} - Absen Pagi',
  );
  _scheduleDailyNotification(
    51,
    DateTime.friday,
    friSore.hour,
    friSore.minute,
    '${_formatTime(friSore)} - Absen Sore',
  );
}

void _scheduleDailyNotification(int id, int weekday, int hour, int minute, String message) async {
  await notificationsPlugin.zonedSchedule(
    id,
    'Absen Reminder',
    message,
    _nextInstanceOfWeekdayTime(weekday, hour, minute),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_notif_channel',
        'Daily Notifications',
        channelDescription: 'Scheduled daily reminders',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
  );
}

tz.TZDateTime _nextInstanceOfWeekdayTime(int weekday, int hour, int minute) {
  final now = tz.TZDateTime.now(tz.local);
  tz.TZDateTime scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

  while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
    scheduled = scheduled.add(const Duration(days: 1));
  }

  return scheduled;
}
