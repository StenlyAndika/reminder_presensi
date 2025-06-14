import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'models/schedule_model.dart';
import 'screens/schedule_settings_page.dart';
import 'services/notification_service.dart';

final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocDir = await getApplicationDocumentsDirectory();
  Hive.init(appDocDir.path);
  Hive.registerAdapter(ScheduleModelAdapter());

  await Hive.openBox('scheduleBox');

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

  await NotificationService.initialize();

  // Check if app was launched by tapping a notification
  final details = await NotificationService.notificationsPlugin.getNotificationAppLaunchDetails();

  final didNotificationLaunchApp = details?.didNotificationLaunchApp ?? false;

  if (didNotificationLaunchApp && details!.notificationResponse != null) {
    openAbsenApp();
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: ScheduleSettingsPage(),
      ),
    );
  }
}
