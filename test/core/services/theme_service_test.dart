import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:naru/core/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const service = ThemeService();

  test('uses the system mode when no preference has been saved', () async {
    SharedPreferences.setMockInitialValues({});

    expect(await service.loadThemeMode(), ThemeMode.system);
  });

  test('persists and restores each supported theme mode', () async {
    SharedPreferences.setMockInitialValues({});

    for (final mode in ThemeMode.values) {
      await service.saveThemeMode(mode);
      expect(await service.loadThemeMode(), mode);
    }
  });

  test('reports an invalid stored theme mode', () async {
    SharedPreferences.setMockInitialValues({
      ThemeService.preferenceKey: 'sepia',
    });

    expect(service.loadThemeMode(), throwsFormatException);
  });
}
