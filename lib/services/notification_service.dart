import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // ============================
  // INIT
  // ============================
  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(settings);

    // Android permission
    if (Platform.isAndroid) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

    // iOS permission (extra safety)
    if (Platform.isIOS) {
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  // ============================
  // SCHEDULE ALL PRAYERS
  // ============================
  static Future<void> scheduleAllPrayerNotifications(
      Map<String, String> times) async {

    await flutterLocalNotificationsPlugin.cancelAll();

    final now = DateTime.now();

    for (final entry in times.entries) {
      final name = entry.key;
      final time = entry.value;

      final parts = time.split(':');

      final scheduled = DateTime(
        now.year,
        now.month,
        now.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
      );

      // skip past times
      if (scheduled.isBefore(now)) continue;

      final tzTime = tz.TZDateTime.from(scheduled, tz.local);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        name.hashCode,
        name == "Sunrise" ? "Sunrise" : "Prayer Time",
        "$name time",

        tzTime,

        NotificationDetails(
          android: AndroidNotificationDetails(
            'prayer_channel',
            'Prayer Times',
            importance: Importance.max,
            priority: Priority.high,
            playSound: name == "Sunrise" ? false : true, // 🔥 sunrise silent
          ),
          iOS: DarwinNotificationDetails(
            presentSound: name == "Sunrise" ? false : true,
          ),
        ),

        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}