import 'package:shared_preferences/shared_preferences.dart';

import '../models/zikr_model.dart';

class ZikrService {
  static const _countKey = 'zikr_count';
  static const _zikrIdKey = 'zikr_id';

  static Future<int> loadCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_countKey) ?? 0;
  }

  static Future<void> saveCount(int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_countKey, count);
  }

  static Future<String?> loadZikrId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_zikrIdKey);
  }

  static Future<void> saveZikrId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_zikrIdKey, id);
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_countKey, 0);
  }

  static const _targetKey = 'zikr_target';

  static Future<int> loadTarget() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_targetKey) ?? 33; // default
  }

  static Future<void> saveTarget(int target) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_targetKey, target);
  }

  static const _customZikrArabic = 'custom_zikr_arabic';
  static const _customZikrEnglish = 'custom_zikr_english';

  static Future<void> saveCustomZikr(
      String arabic,
      String english,
      ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_customZikrArabic, arabic);
    await prefs.setString(_customZikrEnglish, english);
  }

  static Future<ZikrModel?> loadCustomZikr() async {
    final prefs = await SharedPreferences.getInstance();
    final arabic = prefs.getString(_customZikrArabic);
    final english = prefs.getString(_customZikrEnglish);

    if (arabic == null || english == null) return null;

    return ZikrModel(
      id: 'custom_user',
      arabic: arabic,
      english: english,
    );
  }


}
