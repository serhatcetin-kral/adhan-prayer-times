import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/calculation_method.dart';
import '../models/madhab_type.dart';
import '../services/location_service.dart';
import '../services/prayer_api_service.dart';
import '../services/settings_service.dart';
import '../services/location_name_service.dart';
import '../services/notification_service.dart';
import 'package:intl/intl.dart';
class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  Map<String, String>? prayerTimes;
  String? locationName;
  String? hijriDate;

  bool _isLoading = true;
  bool _isOffline = false;

  Timer? _timer;
  String nextPrayerName = "";
  String countdown = "";
  final gregorian = DateFormat.yMMMMEEEEd().format(DateTime.now());
  @override
  void initState() {
    super.initState();
    _loadCachedData();
    _loadData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // ===============================
  // LOAD CACHED FIRST
  // ===============================
  Future<void> _loadCachedData() async {
    final saved = await PrayerApiService.loadSavedPrayerTimes();

    if (saved != null) {
      final times = Map<String, String>.from(saved['timings']);

      setState(() {
        prayerTimes = times;
        hijriDate = saved['hijri'];
        _isLoading = false;
      });

      _startTimer(times);
    }
  }

  // ===============================
  // LOAD ONLINE DATA
  // ===============================
  Future<void> _loadData() async {
    try {
      final method = await SettingsService.getCalculationMethod();
      final madhab = await SettingsService.getMadhab();
      final offset = await SettingsService.getOffset();
      final notificationsEnabled =
      await SettingsService.getNotificationsEnabled();

      final pos = await LocationService.getUserLocation();

      final name = await LocationNameService.getLocationName(
        pos.latitude,
        pos.longitude,
      );

      final response = await PrayerApiService.getPrayerTimes(
        latitude: pos.latitude,
        longitude: pos.longitude,
        method: method.methodId,
        school: madhab.schoolId,
        globalOffset: offset,
      );

      final times = Map<String, String>.from(response['timings']);
      final hijri = response['hijri'];

      if (notificationsEnabled) {
        await NotificationService.scheduleAllPrayerNotifications(times);
      } else {
        await NotificationService.flutterLocalNotificationsPlugin.cancelAll();
      }

      final prefs = await SettingsService.getPrefs();
      await prefs.setString('cached_prayer_times', jsonEncode(times));
      await prefs.setString('cached_location_name', name);

      if (!mounted) return;

      setState(() {
        locationName = name;
        prayerTimes = times;
        hijriDate = hijri;
        _isLoading = false;
        _isOffline = false;
      });

      _startTimer(times);

    } catch (e) {
      debugPrint("Offline/Error: $e");

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _isOffline = true;
      });
    }
  }

  // ===============================
  // TIMER
  // ===============================
  void _startTimer(Map<String, String> times) {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();
      final sequence = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

      for (final name in sequence) {
        final t = _parseTime(times[name]!);

        if (t.isAfter(now)) {
          final diff = t.difference(now);

          setState(() {
            nextPrayerName = name;
            countdown = _formatDuration(diff);
          });

          return;
        }
      }

      final fajr = _parseTime(times['Fajr']!).add(const Duration(days: 1));
      final diff = fajr.difference(now);

      setState(() {
        nextPrayerName = "Fajr";
        countdown = _formatDuration(diff);
      });
    });
  }

  DateTime _parseTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();

    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  String _formatDuration(Duration d) {
    return "${d.inHours.toString().padLeft(2, '0')}:"
        "${(d.inMinutes % 60).toString().padLeft(2, '0')}:"
        "${(d.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  // ===============================
  // UI
  // ===============================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Prayer Times"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // 🔴 OFFLINE
          if (_isOffline)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.red,
              width: double.infinity,
              child: const Text(
                "No Internet - Showing saved prayer times",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              ),
            ),

          // 📍 LOCATION
          Text(
            locationName ??
                (_isOffline ? "Offline Mode" : "Locating..."),
          ),

          // 📅 HIJRI DATE
          Column(
            children: [
              Text(
                gregorian,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                hijriDate != null ? "🌙 $hijriDate AH" : "",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ⏳ NEXT PRAYER
          if (nextPrayerName.isNotEmpty)
            Column(
              children: [
                Text("NEXT: $nextPrayerName"),
                Text(countdown),
              ],
            ),

          const SizedBox(height: 10),

          // 📋 PRAYER LIST
          Expanded(
            child: ListView(
              children: prayerTimes!.entries.map((e) {
                return ListTile(
                  title: Text(e.key),
                  trailing: Text(e.value),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}