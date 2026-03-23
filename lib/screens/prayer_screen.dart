import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/calculation_method.dart';
import '../models/madhab_type.dart';
import '../services/location_service.dart';
import '../services/prayer_api_service.dart';
import '../services/settings_service.dart';
import '../services/location_name_service.dart';
import '../services/notification_service.dart';

class PrayerScreen extends StatefulWidget {
  const PrayerScreen({super.key});

  @override
  State<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends State<PrayerScreen> {
  Map<String, String>? prayerTimes;
  String? locationName;
  bool _isLoading = true;
  bool _isOffline = false;

  Timer? _timer;
  String nextPrayerName = "";
  String countdown = "";

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
    final prefs = await SettingsService.getPrefs();

    final cachedTimes = prefs.getString('cached_prayer_times');
    final cachedLocation = prefs.getString('cached_location_name');

    if (cachedTimes != null) {
      final decoded = Map<String, String>.from(jsonDecode(cachedTimes));
      setState(() {
        prayerTimes = decoded;
        locationName = cachedLocation;
        _isLoading = false;
      });

      _startTimer(decoded);
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
      final notificationsEnabled = await SettingsService.getNotificationsEnabled();

      final pos = await LocationService.getUserLocation();

      final name = await LocationNameService.getLocationName(
        pos.latitude,
        pos.longitude,
      );

      final times = await PrayerApiService.getPrayerTimes(
        latitude: pos.latitude,
        longitude: pos.longitude,
        method: method.methodId,
        school: madhab.schoolId,
        globalOffset: offset,
      );

      if (notificationsEnabled) {
        await NotificationService.scheduleAllPrayerNotifications(times);
      }

      final prefs = await SettingsService.getPrefs();
      await prefs.setString('cached_prayer_times', jsonEncode(times));
      await prefs.setString('cached_location_name', name);

      if (!mounted) return;

      setState(() {
        locationName = name;
        prayerTimes = times;
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
  // TIMER (NEXT PRAYER ONLY)
  // ===============================
  void _startTimer(Map<String, String> times) {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final now = DateTime.now();

      // ❗ DO NOT include Sunrise here
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

      // next day fallback
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
    final hijri = DateFormat.yMMMMEEEEd().format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Prayer Times"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [

          // 🌙 Ramadan Banner
          // if (isRamadan())
          //   Container(
          //     margin: const EdgeInsets.all(12),
          //     padding: const EdgeInsets.all(10),
          //     decoration: BoxDecoration(
          //       color: Colors.green.withOpacity(0.2),
          //       borderRadius: BorderRadius.circular(12),
          //     ),
          //     child: const Text("🌙 Ramadan Mubarak"),
          //   ),

          // 🔴 OFFLINE BANNER
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

          // 📍 Location
          Text(
            locationName ?? (_isOffline ? "Offline Mode" : "Locating..."),
          ),

          // 📅 Hijri
          Text(hijri),

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

          // 📋 LIST
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