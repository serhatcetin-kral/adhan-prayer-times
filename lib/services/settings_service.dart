import 'package:shared_preferences/shared_preferences.dart';
import '../models/calculation_method.dart';
import '../models/madhab_type.dart'; // ✅ FIXED NAME

class SettingsService {

  // 🔰 FIRST LAUNCH
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('first_launch') ?? true;
  }

  static Future<void> completeFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('first_launch', false);
  }

  // 📍 Calculation Method
  static Future<void> saveCalculationMethod(CalculationMethod method) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('calculation_method', method.index);
  }

  static Future<CalculationMethod> getCalculationMethod() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('calculation_method') ?? CalculationMethod.isna.index;
    return CalculationMethod.values[index];
  }

  // 📍 Madhab (FIXED NAME)
  static Future<void> saveMadhab(MadhabType madhab) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('madhab', madhab.index);
  }

  static Future<MadhabType> getMadhab() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('madhab') ?? MadhabType.standard.index;
    return MadhabType.values[index];
  }

  // 🔔 Notifications ON/OFF
  static Future<void> setNotificationsEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
  }

  static Future<bool> getNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  // ⏰ OFFSET (-10 to +10)
  static Future<void> setOffset(int offset) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('offset', offset);
  }

  static Future<int> getOffset() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('offset') ?? 0;
  }
// 🔊 ADHAN SETTING
  static Future<void> setAdhanEnabled(String prayer, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('adhan_$prayer', value);
  }

  static Future<bool> isAdhanEnabled(String prayer) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('adhan_$prayer') ?? true;
  }

// 🔔 POPUP SETTING
  static Future<void> setPopupEnabled(String prayer, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('popup_$prayer', value);
  }

  static Future<bool> isPopupEnabled(String prayer) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('popup_$prayer') ?? true;
  }
  // 🔥 EXTRA (NEEDED FOR YOUR PRAYER SCREEN)

  static Future<SharedPreferences> getPrefs() async {
    return await SharedPreferences.getInstance();
  }
}