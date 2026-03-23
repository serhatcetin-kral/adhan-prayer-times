import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PrayerApiService {

  // 🔥 MAIN API FUNCTION
  static Future<Map<String, String>> getPrayerTimes({
    required double latitude,
    required double longitude,
    required int method,
    required int school,

    int globalOffset = 0,
    int fajrOffset = 0,
    int maghribOffset = 0,
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

    final data = jsonDecode(response.body)['data']['timings'];

    // 🔧 FORMAT FUNCTION
    String formatTime(String time, int offset) {
      final parts = time.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      minute += offset;

      hour = (hour + minute ~/ 60) % 24;
      minute = minute % 60;

      return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
    }

    final result = {
      'Fajr': formatTime(data['Fajr'], globalOffset + fajrOffset),
      'Sunrise': formatTime(data['Sunrise'], globalOffset),
      'Dhuhr': formatTime(data['Dhuhr'], globalOffset),
      'Asr': formatTime(data['Asr'], globalOffset),
      'Maghrib': formatTime(data['Maghrib'], globalOffset + maghribOffset),
      'Isha': formatTime(data['Isha'], globalOffset),
    };

    // 💾 SAVE FOR OFFLINE
    await savePrayerTimes(result);

    return result;
  }

  // 💾 SAVE DATA
  static Future<void> savePrayerTimes(Map<String, String> data) async {
    final prefs = await SharedPreferences.getInstance();

    final today = DateTime.now().toIso8601String();
    await prefs.setString('prayer_times_date', today);

    data.forEach((key, value) {
      prefs.setString('prayer_$key', value);
    });
  }

  // 📥 LOAD SAVED DATA
  static Future<Map<String, String>?> loadSavedPrayerTimes() async {
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

    return {
      'Fajr': prefs.getString('prayer_Fajr') ?? '--:--',
      'Sunrise': prefs.getString('prayer_Sunrise') ?? '--:--',
      'Dhuhr': prefs.getString('prayer_Dhuhr') ?? '--:--',
      'Asr': prefs.getString('prayer_Asr') ?? '--:--',
      'Maghrib': prefs.getString('prayer_Maghrib') ?? '--:--',
      'Isha': prefs.getString('prayer_Isha') ?? '--:--',
    };
  }
}