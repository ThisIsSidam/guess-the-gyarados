import 'package:flutter/material.dart';

const Color completionPill = Color.fromARGB(255, 251, 231, 146);
const Color neutralPill = Color.fromARGB(255, 211, 211, 211);

final myTheme = ThemeData(

  scaffoldBackgroundColor: const Color.fromARGB(255, 43, 173, 225),
  appBarTheme: const AppBarTheme(
    color: Colors.transparent
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.all(0),
      backgroundColor: neutralPill,
      foregroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15))
      ),
    )
  ),

  

  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontSize: 25
    ),
    titleMedium: TextStyle(
      fontSize: 20
    ),
    titleSmall: TextStyle(
      fontSize: 18
    ),
    bodyLarge: TextStyle(
      fontSize: 18
    ),
    bodyMedium: TextStyle(
      fontSize: 15
    ),
    bodySmall: TextStyle(
      fontSize: 12
    )
  )

);