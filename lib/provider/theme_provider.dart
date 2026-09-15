import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:guessthegyarados/theme/gyarados_theme.dart';

final themeProvider = StateNotifierProvider<ThemeProvider, ThemeData>((ref) {
  return ThemeProvider(gyaradosTheme);
});

class ThemeProvider extends StateNotifier<ThemeData> {
  ThemeProvider(super.initialTheme);

  void setTheme(ThemeData newTheme) {
    state = newTheme;
  }
}