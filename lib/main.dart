import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'screens/settings_screen.dart';
import 'screens/main_screen.dart';
import 'services/notification_service.dart';
import 'services/settings_service.dart';

Future<void> setupTimezone() async {
  tz.setLocalLocation(tz.local);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // LOCK APP TO PORTRAIT ONLY
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  tz.initializeTimeZones();
  await setupTimezone();

  await NotificationService.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? isFirstLaunch;

  @override
  void initState() {
    super.initState();
    checkFirstLaunch();
  }

  Future<void> checkFirstLaunch() async {
    isFirstLaunch = await SettingsService.isFirstLaunch();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (isFirstLaunch == null) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Salat Times',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: isFirstLaunch!
          ? const SettingsScreen() // first install
          : const MainScreen(),    // normal app
    );
  }
}