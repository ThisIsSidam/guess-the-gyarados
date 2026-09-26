import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guessthegyarados/core/providers/theme_provider.dart';
import 'package:guessthegyarados/features/home/presentation/pages/home_page.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTheme = ref.watch(appThemeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guess the Gyarados',
      home: const HomePage(),
      theme: currentTheme,
    );
  }
}
