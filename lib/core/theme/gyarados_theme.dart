import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Arcade/game-console inspired palette: a bright backdrop built around the
/// single electric-cyan/blue accent (`primary`) rather than purple, with
/// gold as the separate "reward" accent (level-ups, points, catches).
/// Cards/chips/dialogs/buttons (`surface`/`surfaceRaised`) are white/near-white
/// — the same white used for the play page's back button — so every raised
/// component reads consistently across the app; [textOnLight] is the dark
/// text color used on top of them, while [textOnDark] remains for text sitting
/// on saturated color (the colorful scaffold background, type chips, badges).
class GameColors {
  static const Color background = Color(0xFF2E86FF);
  static const Color backgroundDeep = Color(0xFF1657C4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceRaised = Color(0xFFF3F3F6);
  static const Color primary = Color(0xFF3DE8FF);
  static const Color primaryDeep = Color(0xFF1C7FA8);
  static const Color gold = Color(0xFFFFC93D);
  static const Color goldDeep = Color(0xFFC98A00);
  static const Color danger = Color(0xFFFF5D6C);
  static const Color success = Color(0xFF52E48F);
  static const Color textOnDark = Color(0xFFF4F6FF);
  static const Color textOnLight = Color(0xFF23262E);
  static const Color textMuted = Color(0xFF767A85);
}

final _gameFont = GoogleFonts.baloo2TextTheme();

final gyaradosTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: GameColors.background,
  fontFamily: GoogleFonts.baloo2().fontFamily,
  splashFactory: InkRipple.splashFactory,

  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
  ),

  colorScheme: const ColorScheme.dark(
    surface: GameColors.surface,
    primary: GameColors.primary,
    secondary: GameColors.gold,
    error: GameColors.danger,
  ),

  chipTheme: ChipThemeData(
    labelStyle: GoogleFonts.baloo2(fontWeight: FontWeight.w700, color: GameColors.textOnDark),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
      side: BorderSide(color: Colors.white.withValues(alpha: 0.25), width: 1.5),
    ),
    side: BorderSide.none,
  ),

  cardTheme: CardThemeData(
    color: GameColors.surface,
    elevation: 8,
    shadowColor: GameColors.primary.withValues(alpha: 0.4),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.all(0),
      backgroundColor: GameColors.surfaceRaised,
      foregroundColor: GameColors.textOnLight,
      elevation: 0,
      textStyle: GoogleFonts.baloo2(fontWeight: FontWeight.w700),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: GameColors.surface,
    hintStyle: const TextStyle(color: GameColors.textMuted),
    outlineBorder: const BorderSide(color: GameColors.primary),
    focusColor: GameColors.primary,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: GameColors.primary, width: 2),
    ),
  ),

  textTheme: _gameFont.copyWith(
    titleLarge: GoogleFonts.baloo2(
      fontSize: 26,
      fontWeight: FontWeight.w800,
      color: GameColors.textOnDark,
    ),
    titleMedium: GoogleFonts.baloo2(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: GameColors.textOnDark,
    ),
    titleSmall: GoogleFonts.baloo2(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: GameColors.textOnDark,
    ),
    bodyLarge: GoogleFonts.baloo2(
      fontSize: 18,
      color: GameColors.textOnDark,
    ),
    bodyMedium: GoogleFonts.baloo2(
      fontSize: 15,
      color: GameColors.textOnDark,
    ),
    bodySmall: GoogleFonts.baloo2(
      fontSize: 12,
      color: GameColors.textMuted,
    ),
  ),
);
