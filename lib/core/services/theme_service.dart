import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  const ThemeService();

  static const preferenceKey = 'naru.theme_mode';

  Future<ThemeMode> loadThemeMode() async {
    final preferences = await SharedPreferences.getInstance();
    final savedMode = preferences.getString(preferenceKey);

    if (savedMode == null) {
      return ThemeMode.system;
    }

    return ThemeMode.values.firstWhere(
      (mode) => mode.name == savedMode,
      orElse: () =>
          throw FormatException('Unknown saved Naru theme mode: $savedMode'),
    );
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    final preferences = await SharedPreferences.getInstance();
    final saved = await preferences.setString(preferenceKey, mode.name);

    if (!saved) {
      throw StateError('Unable to persist the Naru theme preference.');
    }
  }
}
