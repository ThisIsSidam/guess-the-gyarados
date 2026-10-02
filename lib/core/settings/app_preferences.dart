import 'package:shared_preferences/shared_preferences.dart';

/// The player's settings, persisted with shared_preferences. Everything is
/// read synchronously (the instance is loaded once at startup), so game code
/// can check a setting at the moment it needs it.
class AppPreferences {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const _soundKey = 'settings.sound';
  static const _hapticsKey = 'settings.haptics';
  static const _reduceMotionKey = 'settings.reduceMotion';

  bool get soundEnabled => _prefs.getBool(_soundKey) ?? true;
  bool get hapticsEnabled => _prefs.getBool(_hapticsKey) ?? true;

  /// Calms purely decorative motion (shakes, tilts, bounces, confetti, spins).
  /// The OS-level "remove animations" setting counts as on regardless.
  bool get reduceMotion => _prefs.getBool(_reduceMotionKey) ?? false;

  Future<void> setSoundEnabled(bool value) => _prefs.setBool(_soundKey, value);
  Future<void> setHapticsEnabled(bool value) =>
      _prefs.setBool(_hapticsKey, value);
  Future<void> setReduceMotion(bool value) =>
      _prefs.setBool(_reduceMotionKey, value);
}
