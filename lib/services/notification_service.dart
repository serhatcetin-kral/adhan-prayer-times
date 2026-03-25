import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:intl/intl.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // ============================
  // INIT
  // ============================
  static Future<void> init() async {
    tz_data.initializeTimeZones();

    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestSoundPermission: true,
      requestBadgePermission: true,
    );

    const settings = InitializationSettings(
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

    // iOS permission
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
  // 🔥 MAIN SCHEDULER (FIXED)
  // ============================
  static Future<void> scheduleAllPrayerNotifications(
      Map<String, String> times) async {
    await flutterLocalNotificationsPlugin.cancelAll(); // 🔥 IMPORTANT

    final now = DateTime.now();

    final prayerNames = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    int id = 0;

    for (final name in prayerNames) {
      if (!times.containsKey(name)) continue;

      final parsed = DateFormat("HH:mm").parse(times[name]!);

      var scheduleDate = DateTime(
        now.year,
        now.month,
        now.day,
        parsed.hour,
        parsed.minute,
      );

      // 🔥 FIX: move to tomorrow if passed
      if (scheduleDate.isBefore(now)) {
        scheduleDate = scheduleDate.add(const Duration(days: 1));
      }

      final scheduled = tz.TZDateTime.from(scheduleDate, tz.local);

      print("Scheduling $name at $scheduled");

      await flutterLocalNotificationsPlugin.zonedSchedule(
        id++,
        'Prayer Time: $name',
        'It is time for $name',

        scheduled,

        const NotificationDetails(
          android: AndroidNotificationDetails(
            'prayer_channel',
            'Prayer Times',
            channelDescription: 'Prayer alerts',
            importance: Importance.max,
            priority: Priority.high,
            playSound: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            sound: 'adhan.caf'
          ),
        ),

        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,

        // 🔥 DAILY repeat
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }

    print("✅ Notifications scheduled correctly");
  }

  // ============================
  // TEST
  // ============================
  static Future<void> testZonedNotification() async {
    final scheduled =
    tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5));

    await flutterLocalNotificationsPlugin.zonedSchedule(
      999,
      'Test Notification',
      'If you see this → notifications are FIXED',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'prayer_channel',
          'Prayer Times',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}