import 'package:flutter/widgets.dart';
import 'package:guessthegyarados/core/di/injection.dart';
import 'package:guessthegyarados/core/settings/app_preferences.dart';

/// Whether decorative motion should be skipped: the in-app setting or the
/// OS's "remove animations".
class ReducedMotion {
  const ReducedMotion._();

  // Tolerates a missing registration so widgets can be pumped in isolation.
  static bool get preferred =>
      getIt.isRegistered<AppPreferences>() && getIt<AppPreferences>().reduceMotion;

  static bool of(BuildContext context) =>
      preferred || MediaQuery.disableAnimationsOf(context);
}
