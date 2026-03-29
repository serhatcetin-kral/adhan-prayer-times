import 'dart:async';
import 'package:flutter/material.dart';
import '../services/location_service.dart';
import '../services/prayer_api_service.dart';
import '../services/settings_service.dart';
import '../services/location_name_service.dart';
import '../services/notification_service.dart';
import 'package:intl/intl.dart';
import '../models/calculation_method.dart';
import '../models/madhab_type.dart';

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
      final globalOffset = await SettingsService.getOffset();
      final notificationsEnabled =
      await SettingsService.getNotificationsEnabled();

      // ✅ NEW: load individual prayer offsets
      final fajrOffset = await SettingsService.getPrayerOffset('Fajr');
      final sunriseOffset = await SettingsService.getPrayerOffset('Sunrise');
      final dhuhrOffset = await SettingsService.getPrayerOffset('Dhuhr');
      final asrOffset = await SettingsService.getPrayerOffset('Asr');
      final maghribOffset = await SettingsService.getPrayerOffset('Maghrib');
      final ishaOffset = await SettingsService.getPrayerOffset('Isha');

      final pos = await LocationService.getUserLocation();

      if (pos == null) {
        setState(() {
          _isLoading = false;
          _isOffline = true;
          locationName = "Location unavailable";
        });
        return;
      }

      final name = await LocationNameService.getLocationName(
        pos.latitude,
        pos.longitude,
      );

      final response = await PrayerApiService.getPrayerTimes(
        latitude: pos.latitude,
        longitude: pos.longitude,
        method: method.methodId,
        school: madhab.schoolId,
        globalOffset: globalOffset,

        // ✅ pass all prayer offsets
        fajrOffset: fajrOffset,
        sunriseOffset: sunriseOffset,
        dhuhrOffset: dhuhrOffset,
        asrOffset: asrOffset,
        maghribOffset: maghribOffset,
        ishaOffset: ishaOffset,
      );

      final times = Map<String, String>.from(response['timings']);
      final hijri = response['hijri'];

      if (notificationsEnabled) {
        await NotificationService.scheduleAllPrayerNotifications(times);
      } else {
        await NotificationService.flutterLocalNotificationsPlugin.cancelAll();
      }

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

      final saved = await PrayerApiService.loadSavedPrayerTimes();

      if (!mounted) return;

      if (saved != null) {
        final times = Map<String, String>.from(saved['timings']);

        setState(() {
          prayerTimes = times;
          hijriDate = saved['hijri'];
          _isLoading = false;
          _isOffline = true;
        });

        _startTimer(times);
      } else {
        setState(() {
          _isLoading = false;
          _isOffline = true;
          locationName = "No internet connection";
        });
      }
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
        title: const Text("Prayer Salah Times"),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // 🔴 FIRST INSTALL (no data at all)
          if (_isOffline && prayerTimes == null)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Please connect to internet for first setup",
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            )

          // 🟡 OFFLINE BUT HAS DATA
          else if (_isOffline)
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

          // 📍 LOCATION + DATE
          Column(
            children: [
              Text(
                locationName ?? "Loading location...",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                gregorian,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              if (hijriDate != null)
                Text(
                  "🌙 $hijriDate AH",
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
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    "Next Prayer",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    nextPrayerName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    countdown,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 10),

          // 📋 PRAYER LIST
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: prayerTimes!.entries.map((e) {
                final isNext = e.key == nextPrayerName;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isNext ? Colors.teal : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.key,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isNext ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        e.value,
                        style: TextStyle(
                          fontSize: 18,
                          color: isNext ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}