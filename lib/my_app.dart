import 'package:flutter/material.dart';
import 'package:guessthegyarados/pages/homepage.dart';
import 'package:guessthegyarados/theme/theme.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guess the Gyarados',
      home: const HomePage(),
      theme: myTheme,
    );
  }
}