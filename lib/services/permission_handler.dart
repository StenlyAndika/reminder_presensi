import 'dart:io';
import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHandler {
  static Future<void> checkAndRequestAlarmPermission(BuildContext context) async {
    if (Platform.isAndroid) {
      await Permission.notification.request();

      final ignoreStatus = await Permission.ignoreBatteryOptimizations.status;
      if (!ignoreStatus.isGranted) {
        final intent = AndroidIntent(
            action: 'android.settings.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS',
            data: 'package:com.example.reminder_presensi',
          );
          await intent.launch();
      }

      // ✅ Request exact alarm permission
      final alarmStatus = await Permission.scheduleExactAlarm.request();
      if (!alarmStatus.isGranted) {
        final intent = AndroidIntent(
          action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
          data: 'package:com.example.reminder_presensi',
        );
        await intent.launch();
      }
    }
  }
}
