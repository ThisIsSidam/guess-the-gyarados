import 'package:flutter/material.dart';
import 'package:guessthegyarados/core/di/injection.dart';
import 'package:guessthegyarados/core/settings/app_preferences.dart';
import 'package:guessthegyarados/core/settings/haptics.dart';
import 'package:guessthegyarados/core/theme/gyarados_theme.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/folded_backdrop.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/game_page_header.dart';
import 'package:guessthegyarados/shared/presentation/widgets/game/tap_bounce.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _prefs = getIt<AppPreferences>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FoldedBackdrop(
        accentColor: GameColors.primary,
        pattern: FoldPattern.broad,
        child: SafeArea(
          child: Column(
            children: [
              const GamePageHeader(title: 'SETTINGS'),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  children: [
                    _SettingTile(
                      icon: Icons.volume_up_rounded,
                      title: 'Sound',
                      subtitle: 'Pokemon cries',
                      value: _prefs.soundEnabled,
                      onChanged: (v) async {
                        await _prefs.setSoundEnabled(v);
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 14),
                    _SettingTile(
                      icon: Icons.vibration_rounded,
                      title: 'Haptics',
                      subtitle: 'Vibration on picks, catches and rewards',
                      value: _prefs.hapticsEnabled,
                      onChanged: (v) async {
                        await _prefs.setHapticsEnabled(v);
                        setState(() {});
                        // A taste of what was just switched on.
                        Haptics.light();
                      },
                    ),
                    const SizedBox(height: 14),
                    _SettingTile(
                      icon: Icons.animation_rounded,
                      title: 'Reduce motion',
                      subtitle: 'Fewer shakes, tilts, bounces and confetti',
                      value: _prefs.reduceMotion,
                      onChanged: (v) async {
                        await _prefs.setReduceMotion(v);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return TapBounce(
      pressedScale: 0.97,
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: GameColors.primaryDeep, offset: Offset(0, 5)),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 30, color: GameColors.backgroundDeep),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: GameColors.textOnLight,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: GameColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: Colors.white,
              activeTrackColor: GameColors.backgroundDeep,
            ),
          ],
        ),
      ),
    );
  }
}
