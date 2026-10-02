import 'package:flutter/services.dart';
import 'package:guessthegyarados/core/di/injection.dart';
import 'package:guessthegyarados/core/settings/app_preferences.dart';

/// Haptic feedback that respects the player's setting. Use this instead of
/// calling [HapticFeedback] directly.
class Haptics {
  const Haptics._();

  static bool get _on =>
      !getIt.isRegistered<AppPreferences>() ||
      getIt<AppPreferences>().hapticsEnabled;

  static void selection() {
    if (_on) HapticFeedback.selectionClick();
  }

  static void light() {
    if (_on) HapticFeedback.lightImpact();
  }

  static void medium() {
    if (_on) HapticFeedback.mediumImpact();
  }

  static void heavy() {
    if (_on) HapticFeedback.heavyImpact();
  }

  /// Two hard hits in a row: the "no" buzz.
  static void doubleBuzz() {
    if (!_on) return;
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 90), () {
      if (_on) HapticFeedback.heavyImpact();
    });
  }
}
