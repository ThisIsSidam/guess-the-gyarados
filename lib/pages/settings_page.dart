import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/provider/theme_provider.dart';
import 'package:guessthegyarados/theme/gyarados_theme.dart';
import 'package:guessthegyarados/theme/shiny_gyarados_theme.dart';
import 'package:guessthegyarados/theme/mega_gyarados_theme.dart';

// Underdevelopment

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(15)
              ),
              child: ListTile(
                title: const Text('Theme'),
                trailing: DropdownButtonHideUnderline(
                  child: DropdownButton<ThemeData>(
                    value: currentTheme,
                    onChanged: (ThemeData? newTheme) {
                      if (newTheme != null && newTheme != currentTheme) {
                        ref.read(themeProvider.notifier).setTheme(newTheme);
                      }
                    },
                    dropdownColor: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(15),
                    items: [
                      DropdownMenuItem(
                        value: gyaradosTheme,
                        child: const Text('Gyarados Theme'),
                      ),
                      DropdownMenuItem(
                        value: shinyGyaradosTheme,
                        child: const Text('Shiny Gyarados Theme'),
                      ),
                      DropdownMenuItem(
                        value: megaGyaradosTheme,
                        child: const Text('Mega Gyarados Theme'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(15)
                ),
                child: const Placeholder(),
              ),
            ),
          )
        ],
      ),
    );
  }
}