// import 'dart:async';
// import 'package:flutter/material.dart';
// import '../services/location_service.dart';
// import '../services/prayer_api_service.dart';
// import '../services/settings_service.dart';
// import '../services/location_name_service.dart';
// import '../services/notification_service.dart';
// import 'package:intl/intl.dart';
// import '../models/calculation_method.dart';
// import '../models/madhab_type.dart';
//
//
//
//
// class PrayerScreen extends StatefulWidget {
//   const PrayerScreen({super.key});
//
//   @override
//   State<PrayerScreen> createState() => _PrayerScreenState();
// }
//
// class _PrayerScreenState extends State<PrayerScreen> {
//   Map<String, String>? prayerTimes;
//   String? locationName;
//   String? hijriDate;
//
//   bool _isLoading = true;
//   bool _isOffline = false;
//
//   Timer? _timer;
//   String nextPrayerName = "";
//   String countdown = "";
//
//   final gregorian = DateFormat.yMMMMEEEEd().format(DateTime.now());
//
//   @override
//   void initState() {
//     super.initState();
//     _loadCachedData();
//     _loadData();
//   }
// //////
//
//
//   IconData _getPrayerIcon(String prayerName) {
//     switch (prayerName) {
//       case 'Fajr':
//         return Icons.nightlight_round;
//       case 'Sunrise':
//         return Icons.wb_sunny_rounded;
//       case 'Dhuhr':
//         return Icons.light_mode_rounded;
//       case 'Asr':
//         return Icons.wb_sunny_outlined;
//       case 'Maghrib':
//         return Icons.wb_twilight_rounded;
//       case 'Isha':
//         return Icons.dark_mode_rounded;
//       default:
//         return Icons.access_time_rounded;
//     }
//   }
//   ////
//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
//
//   // ===============================
//   // LOAD CACHED FIRST
//   // ===============================
//   Future<void> _loadCachedData() async {
//     final saved = await PrayerApiService.loadSavedPrayerTimes();
//
//     if (saved != null) {
//       final times = Map<String, String>.from(saved['timings']);
//
//       setState(() {
//         prayerTimes = times;
//         hijriDate = saved['hijri'];
//         _isLoading = false;
//       });
//
//       _startTimer(times);
//     }
//   }
//
//   // ===============================
//   // LOAD ONLINE DATA
//   // ===============================
//   Future<void> _loadData() async {
//     try {
//       final method = await SettingsService.getCalculationMethod();
//       final madhab = await SettingsService.getMadhab();
//       final globalOffset = await SettingsService.getOffset();
//       final notificationsEnabled =
//       await SettingsService.getNotificationsEnabled();
//
//       // ✅ NEW: load individual prayer offsets
//       final fajrOffset = await SettingsService.getPrayerOffset('Fajr');
//       final sunriseOffset = await SettingsService.getPrayerOffset('Sunrise');
//       final dhuhrOffset = await SettingsService.getPrayerOffset('Dhuhr');
//       final asrOffset = await SettingsService.getPrayerOffset('Asr');
//       final maghribOffset = await SettingsService.getPrayerOffset('Maghrib');
//       final ishaOffset = await SettingsService.getPrayerOffset('Isha');
//
//       final pos = await LocationService.getUserLocation();
//
//       if (pos == null) {
//         setState(() {
//           _isLoading = false;
//           _isOffline = true;
//           locationName = "Location unavailable";
//         });
//         return;
//       }
//
//       String name = "Current Location";
//
//       try {
//         final fetchedName = await LocationNameService.getLocationName(
//           pos.latitude,
//           pos.longitude,
//         );
//
//         if (fetchedName != null && fetchedName.trim().isNotEmpty) {
//           name = fetchedName;
//         }
//       } catch (e) {
//         debugPrint("Location name error: $e");
//       }
//
//       final response = await PrayerApiService.getPrayerTimes(
//         latitude: pos.latitude,
//         longitude: pos.longitude,
//         method: method.methodId,
//         school: madhab.schoolId,
//         globalOffset: globalOffset,
//
//         // ✅ pass all prayer offsets
//         fajrOffset: fajrOffset,
//         sunriseOffset: sunriseOffset,
//         dhuhrOffset: dhuhrOffset,
//         asrOffset: asrOffset,
//         maghribOffset: maghribOffset,
//         ishaOffset: ishaOffset,
//       );
//
//       final times = Map<String, String>.from(response['timings']);
//       final hijri = response['hijri'];
//
//       if (notificationsEnabled) {
//         await NotificationService.scheduleAllPrayerNotifications(times);
//       } else {
//         await NotificationService.flutterLocalNotificationsPlugin.cancelAll();
//       }
//
//
//
//
//       if (!mounted) return;
//
//       setState(() {
//         locationName = name;
//         prayerTimes = times;
//         hijriDate = hijri;
//         _isLoading = false;
//         _isOffline = false;
//       });
//
//       _startTimer(times);
//     } catch (e) {
//       debugPrint("Offline/Error: $e");
//
//       final saved = await PrayerApiService.loadSavedPrayerTimes();
//
//       if (!mounted) return;
//
//       if (saved != null) {
//         final times = Map<String, String>.from(saved['timings']);
//
//         setState(() {
//           prayerTimes = times;
//           hijriDate = saved['hijri'];
//           locationName ??= "Current Location";
//           _isLoading = false;
//           _isOffline = true;
//         });
//
//         _startTimer(times);
//       } else {
//         setState(() {
//           _isLoading = false;
//           _isOffline = true;
//           locationName = "No internet connection";
//         });
//       }
//     }
//   }
//
//   // ===============================
//   // TIMER
//   // ===============================
//   void _startTimer(Map<String, String> times) {
//     _timer?.cancel();
//
//     _timer = Timer.periodic(const Duration(seconds: 1), (_) {
//       final now = DateTime.now();
//       final sequence = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
//
//       for (final name in sequence) {
//         final t = _parseTime(times[name]!);
//
//         if (t.isAfter(now)) {
//           final diff = t.difference(now);
//
//           setState(() {
//             nextPrayerName = name;
//             countdown = _formatDuration(diff);
//           });
//
//           return;
//         }
//       }
//
//       final fajr = _parseTime(times['Fajr']!).add(const Duration(days: 1));
//       final diff = fajr.difference(now);
//
//       setState(() {
//         nextPrayerName = "Fajr";
//         countdown = _formatDuration(diff);
//       });
//     });
//   }
//
//   DateTime _parseTime(String time) {
//     final parts = time.split(':');
//     final now = DateTime.now();
//
//     return DateTime(
//       now.year,
//       now.month,
//       now.day,
//       int.parse(parts[0]),
//       int.parse(parts[1]),
//     );
//   }
//
//   String _formatDuration(Duration d) {
//     return "${d.inHours.toString().padLeft(2, '0')}:"
//         "${(d.inMinutes % 60).toString().padLeft(2, '0')}:"
//         "${(d.inSeconds % 60).toString().padLeft(2, '0')}";
//   }
//
//   String _findNextPrayerName(Map<String, String> times) {
//     final now = DateTime.now();
//     final sequence = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
//
//     for (final name in sequence) {
//       final t = _parseTime(times[name]!);
//       if (t.isAfter(now)) {
//         return name;
//       }
//     }
//
//     return 'Fajr';
//   }
//
//   String _findNextPrayerCountdown(Map<String, String> times) {
//     final now = DateTime.now();
//     final sequence = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
//
//     for (final name in sequence) {
//       final t = _parseTime(times[name]!);
//       if (t.isAfter(now)) {
//         return _formatDuration(t.difference(now));
//       }
//     }
//
//     final fajr = _parseTime(times['Fajr']!).add(const Duration(days: 1));
//     return _formatDuration(fajr.difference(now));
//   }
//
//   // ===============================
//   // UI
//   // ===============================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Prayer Salah Times"),
//         centerTitle: true,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : prayerTimes == null
//           ? Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(
//                 Icons.location_off_rounded,
//                 size: 70,
//                 color: Colors.grey.shade500,
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 "Location permission is required to load prayer times.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               const Text(
//                 "Please allow location access and try again.",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 15,
//                   color: Colors.grey,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton.icon(
//                 onPressed: () {
//                   setState(() {
//                     _isLoading = true;
//                   });
//                   _loadData();
//                 },
//                 icon: const Icon(Icons.refresh_rounded),
//                 label: const Text("Try Again"),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.teal,
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 20,
//                     vertical: 12,
//                   ),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       )
//           : Column(
//         children: [
//           if (_isOffline)
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.orange.shade50,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.orange.shade200),
//               ),
//               child: const Row(
//                 children: [
//                   Icon(Icons.cloud_off, color: Colors.orange),
//                   SizedBox(width: 10),
//                   Expanded(
//                     child: Text(
//                       "Offline mode — showing saved prayer times",
//                       style: TextStyle(
//                         color: Colors.orange,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//           Container(
//             margin: const EdgeInsets.fromLTRB(14, 10, 14, 6),
//             padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(22),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.05),
//                   blurRadius: 14,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//               border: Border.all(color: Colors.grey.shade200),
//             ),
//             child: Column(
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(
//                       Icons.location_on_rounded,
//                       color: Colors.teal,
//                       size: 20,
//                     ),
//                     const SizedBox(width: 6),
//                     Flexible(
//                       child: Text(
//                         locationName ?? "Current Location",
//                         textAlign: TextAlign.center,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           fontSize: 17,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.black87,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   gregorian,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     color: Colors.grey,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//                 if (hijriDate != null) ...[
//                   const SizedBox(height: 6),
//                   Text(
//                     "🌙 $hijriDate AH",
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.teal,
//                     ),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 6),
//
//           if (nextPrayerName.isNotEmpty)
//             Container(
//               margin: const EdgeInsets.fromLTRB(14, 6, 14, 6),
//               padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFF0F9D94), Color(0xFF13B8A6)],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.teal.withOpacity(0.20),
//                     blurRadius: 14,
//                     offset: const Offset(0, 5),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       const Icon(
//                         Icons.notifications_active_rounded,
//                         color: Colors.white,
//                         size: 16,
//                       ),
//                       const SizedBox(width: 6),
//                       Text(
//                         "Next Prayer",
//                         style: TextStyle(
//                           color: Colors.white.withOpacity(0.85),
//                           fontSize: 13,
//                           fontWeight: FontWeight.w600,
//                           letterSpacing: 0.3,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     nextPrayerName,
//                     style: const TextStyle(
//                       fontSize: 21,
//                       fontWeight: FontWeight.w700,
//                       color: Colors.white,
//                       letterSpacing: 0.2,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(14),
//                     ),
//                     child: Text(
//                       countdown.replaceAll(":", " : "),
//                       style: const TextStyle(
//                         fontSize: 19,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.white,
//                         letterSpacing: 1,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//           Expanded(
//             child: ListView(
//               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//               children: prayerTimes!.entries.map((e) {
//                 final isNext = e.key == nextPrayerName;
//
//                 return AnimatedContainer(
//                   duration: const Duration(milliseconds: 250),
//                   margin: const EdgeInsets.symmetric(vertical: 5),
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                   decoration: BoxDecoration(
//                     color: isNext ? Colors.teal : Colors.white,
//                     borderRadius: BorderRadius.circular(20),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.05),
//                         blurRadius: 12,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                     border: Border.all(
//                       color: isNext ? Colors.teal : Colors.grey.shade200,
//                       width: 1,
//                     ),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           Icon(
//                             isNext
//                                 ? Icons.notifications_active_rounded
//                                 : _getPrayerIcon(e.key),
//                             size: 20,
//                             color: isNext ? Colors.white : Colors.teal,
//                           ),
//                           const SizedBox(width: 10),
//                           Text(
//                             e.key,
//                             style: TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.w600,
//                               letterSpacing: 0.2,
//                               color: isNext ? Colors.white : Colors.black87,
//                             ),
//                           ),
//                         ],
//                       ),
//                       Text(
//                         e.value,
//                         style: TextStyle(
//                           fontSize: 15,
//                           fontWeight: FontWeight.w600,
//                           color: isNext ? Colors.white : Colors.black87,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
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
import 'package:url_launcher/url_launcher.dart';



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
//////

  Future<void> _openAppSettings() async {
    final Uri url = Uri.parse('app-settings:');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
  IconData _getPrayerIcon(String prayerName) {
    switch (prayerName) {
      case 'Fajr':
        return Icons.nightlight_round;
      case 'Sunrise':
        return Icons.wb_sunny_rounded;
      case 'Dhuhr':
        return Icons.light_mode_rounded;
      case 'Asr':
        return Icons.wb_sunny_outlined;
      case 'Maghrib':
        return Icons.wb_twilight_rounded;
      case 'Isha':
        return Icons.dark_mode_rounded;
      default:
        return Icons.access_time_rounded;
    }
  }
  ////
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

      String name = "Current Location";

      try {
        final fetchedName = await LocationNameService.getLocationName(
          pos.latitude,
          pos.longitude,
        );

        if (fetchedName != null && fetchedName.trim().isNotEmpty) {
          name = fetchedName;
        }
      } catch (e) {
        debugPrint("Location name error: $e");
      }

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
          locationName ??= "Current Location";
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

  String _findNextPrayerName(Map<String, String> times) {
    final now = DateTime.now();
    final sequence = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    for (final name in sequence) {
      final t = _parseTime(times[name]!);
      if (t.isAfter(now)) {
        return name;
      }
    }

    return 'Fajr';
  }

  String _findNextPrayerCountdown(Map<String, String> times) {
    final now = DateTime.now();
    final sequence = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];

    for (final name in sequence) {
      final t = _parseTime(times[name]!);
      if (t.isAfter(now)) {
        return _formatDuration(t.difference(now));
      }
    }

    final fajr = _parseTime(times['Fajr']!).add(const Duration(days: 1));
    return _formatDuration(fajr.difference(now));
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
          : prayerTimes == null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off_rounded,
                size: 70,
                color: Colors.grey.shade500,
              ),
              const SizedBox(height: 16),
              const Text(
                "Location permission is required to load prayer times.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Please allow location access in Settings and try again.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _isLoading = true;
                      });
                      _loadData();
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text("Try Again"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _openAppSettings,
                    icon: const Icon(Icons.settings_rounded),
                    label: const Text("Open Settings"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.teal,
                      side: const BorderSide(color: Colors.teal),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )
          : Column(
        children: [
          if (_isOffline)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.cloud_off, color: Colors.orange),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Offline mode — showing saved prayer times",
                      style: TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Container(
            margin: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: Colors.teal,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        locationName ?? "Current Location",
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  gregorian,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (hijriDate != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    "🌙 $hijriDate AH",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 6),

          if (nextPrayerName.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(14, 6, 14, 6),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F9D94), Color(0xFF13B8A6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.20),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.notifications_active_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Next Prayer",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    nextPrayerName,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      countdown.replaceAll(":", " : "),
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              children: prayerTimes!.entries.map((e) {
                final isNext = e.key == nextPrayerName;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isNext ? Colors.teal : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(
                      color: isNext ? Colors.teal : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            isNext
                                ? Icons.notifications_active_rounded
                                : _getPrayerIcon(e.key),
                            size: 20,
                            color: isNext ? Colors.white : Colors.teal,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            e.key,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.2,
                              color: isNext ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        e.value,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isNext ? Colors.white : Colors.black87,
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