import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guessthegyarados/core/di/injection.dart';
import 'package:guessthegyarados/core/settings/app_preferences.dart';
import 'package:guessthegyarados/features/settings/presentation/pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = AppPreferences(await SharedPreferences.getInstance());
    getIt.registerSingleton<AppPreferences>(prefs);
  });

  tearDown(() => getIt.reset());

  testWidgets('toggling a setting persists it', (tester) async {
    expect(prefs.soundEnabled, isTrue);
    expect(prefs.reduceMotion, isFalse);

    await tester.pumpWidget(const MaterialApp(home: SettingsPage()));
    final switches = find.byType(Switch);
    expect(switches, findsNWidgets(3));

    await tester.tap(switches.at(0)); // sound
    await tester.tap(switches.at(2)); // reduce motion
    await tester.pumpAndSettle();

    expect(prefs.soundEnabled, isFalse);
    expect(prefs.hapticsEnabled, isTrue);
    expect(prefs.reduceMotion, isTrue);
  });
}
