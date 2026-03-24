import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'settings_service.dart'; // ✅ IMPORTANT

class NotificationService {
  static final FlutterLocalNotificationsPlugin
  flutterLocalNotificationsPlugin =
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
  // SCHEDULE ALL PRAYERS
  // ============================
  static Future<void> scheduleAllPrayerNotifications(
      Map<String, String> times) async {

    await flutterLocalNotificationsPlugin.cancelAll();

    for (final entry in times.entries) {
      final name = entry.key;
      final time = entry.value;

      // 🔥 LOAD USER SETTINGS
      final adhanEnabled =
      await SettingsService.isAdhanEnabled(name);
      final popupEnabled =
      await SettingsService.isPopupEnabled(name);

      // ❌ SKIP if both OFF
      if (!adhanEnabled && !popupEnabled) continue;

      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final scheduled = tz.TZDateTime(
        tz.local,
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        hour,
        minute,
      );

      await flutterLocalNotificationsPlugin.zonedSchedule(
        name.hashCode,

        // 🔔 TITLE
        popupEnabled
            ? (name == "Sunrise" ? "Sunrise" : "Prayer Time")
            : null,

        // 🔔 BODY
        popupEnabled ? "$name time" : null,

        scheduled,

        NotificationDetails(
          android: AndroidNotificationDetails(
            'prayer_channel',
            'Prayer Times',
            importance: Importance.max,
            priority: Priority.high,

            sound: adhanEnabled && name != "Sunrise"
                ? const RawResourceAndroidNotificationSound('adhan')
                : null,

            playSound: adhanEnabled && name != "Sunrise",
          ),

          iOS: DarwinNotificationDetails(
            presentSound: adhanEnabled && name != "Sunrise",
            sound: adhanEnabled && name != "Sunrise"
                ? 'adhan.caf'
                : null,
          ),
        ),

        androidScheduleMode:
        AndroidScheduleMode.exactAllowWhileIdle,

        // 🔁 DAILY REPEAT
        matchDateTimeComponents: DateTimeComponents.time,

        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}