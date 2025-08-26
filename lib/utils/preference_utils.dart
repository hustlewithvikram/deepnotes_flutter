import 'package:shared_preferences/shared_preferences.dart';

class PreferenceUtils {
  static late SharedPreferences _prefs;

  /// Initialize once before using anywhere (in main)
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ----------------- Generic Setters -----------------
  static Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  static Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  static Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  static Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  // ----------------- Generic Getters -----------------
  static String getString(String key, {String defValue = ""}) {
    return _prefs.getString(key) ?? defValue;
  }

  static bool getBool(String key, {bool defValue = false}) {
    return _prefs.getBool(key) ?? defValue;
  }

  static int getInt(String key, {int defValue = 0}) {
    return _prefs.getInt(key) ?? defValue;
  }

  static double getDouble(String key, {double defValue = 0.0}) {
    return _prefs.getDouble(key) ?? defValue;
  }

  static List<String> getStringList(
    String key, {
    List<String> defValue = const [],
  }) {
    return _prefs.getStringList(key) ?? defValue;
  }

  // ----------------- Utils -----------------
  static Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  static Future<void> clear() async {
    await _prefs.clear();
  }
}
