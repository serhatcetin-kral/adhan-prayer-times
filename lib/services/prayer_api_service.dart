import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PrayerApiService {
  // 🔥 MAIN API FUNCTION (WITH HIJRI)
  static Future<Map<String, dynamic>> getPrayerTimes({
    required double latitude,
    required double longitude,
    required int method,
    required int school,

    int globalOffset = 0,

    // ✅ NEW: individual prayer offsets
    int fajrOffset = 0,
    int sunriseOffset = 0,
    int dhuhrOffset = 0,
    int asrOffset = 0,
    int maghribOffset = 0,
    int ishaOffset = 0,
  }) async {
    final url =
        'https://api.aladhan.com/v1/timings'
        '?latitude=$latitude'
        '&longitude=$longitude'
        '&method=$method'
        '&school=$school';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode != 200) {
      throw Exception('Failed to load prayer times');
    }

    final json = jsonDecode(response.body)['data'];

    final timings = json['timings'];
    final hijri = json['date']['hijri'];

    // 🔧 FORMAT FUNCTION
    String formatTime(String time, int offset) {
      final cleanTime = time.split(' ').first; // just in case
      final parts = cleanTime.split(':');

      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      minute += offset;

      while (minute < 0) {
        minute += 60;
        hour -= 1;
      }

      while (minute >= 60) {
        minute -= 60;
        hour += 1;
      }

      if (hour < 0) hour += 24;
      if (hour >= 24) hour -= 24;

      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }

    final result = {
      'Fajr': formatTime(timings['Fajr'], globalOffset + fajrOffset),
      'Sunrise': formatTime(timings['Sunrise'], globalOffset + sunriseOffset),
      'Dhuhr': formatTime(timings['Dhuhr'], globalOffset + dhuhrOffset),
      'Asr': formatTime(timings['Asr'], globalOffset + asrOffset),
      'Maghrib': formatTime(timings['Maghrib'], globalOffset + maghribOffset),
      'Isha': formatTime(timings['Isha'], globalOffset + ishaOffset),
    };

    final hijriDate =
        "${hijri['day']} ${hijri['month']['en']} ${hijri['year']}";

    // 💾 SAVE FOR OFFLINE
    await savePrayerTimes(result, hijriDate);

    return {
      'timings': result,
      'hijri': hijriDate,
    };
  }

  // 💾 SAVE DATA
  static Future<void> savePrayerTimes(
      Map<String, String> data,
      String hijri,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    final today = DateTime.now().toIso8601String();
    await prefs.setString('prayer_times_date', today);
    await prefs.setString('hijri_date', hijri);

    for (final entry in data.entries) {
      await prefs.setString('prayer_${entry.key}', entry.value);
    }
  }

  // 📥 LOAD SAVED DATA
  static Future<Map<String, dynamic>?> loadSavedPrayerTimes() async {
    final prefs = await SharedPreferences.getInstance();

    final savedDate = prefs.getString('prayer_times_date');

    if (savedDate == null) return null;

    final savedDay = DateTime.parse(savedDate);
    final now = DateTime.now();

    // ✅ SAME DAY CHECK
    if (savedDay.year != now.year ||
        savedDay.month != now.month ||
        savedDay.day != now.day) {
      return null;
    }

    final times = {
      'Fajr': prefs.getString('prayer_Fajr') ?? '--:--',
      'Sunrise': prefs.getString('prayer_Sunrise') ?? '--:--',
      'Dhuhr': prefs.getString('prayer_Dhuhr') ?? '--:--',
      'Asr': prefs.getString('prayer_Asr') ?? '--:--',
      'Maghrib': prefs.getString('prayer_Maghrib') ?? '--:--',
      'Isha': prefs.getString('prayer_Isha') ?? '--:--',
    };

    final hijri = prefs.getString('hijri_date') ?? '';

    return {
      'timings': times,
      'hijri': hijri,
    };
  }
}