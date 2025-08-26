import 'package:flutter/material.dart';
import 'preference_utils.dart';

class ThemeUtils {
  static ThemeMode getThemeMode() {
    final isDark = PreferenceUtils.getBool("darkMode", defValue: false);
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }

  static ThemeMode toggleThemeMode() {
    final isDark = PreferenceUtils.getBool("darkMode", defValue: false);
    final newIsDark = !isDark;
    PreferenceUtils.setBool("darkMode", newIsDark);
    return newIsDark ? ThemeMode.dark : ThemeMode.light;
  }

  static void setThemeMode(ThemeMode mode) {
    PreferenceUtils.setBool("darkMode", mode == ThemeMode.dark);
  }
}
