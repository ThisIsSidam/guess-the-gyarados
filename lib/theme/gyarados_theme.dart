import 'package:flutter/material.dart';

final gyaradosTheme = ThemeData(

  scaffoldBackgroundColor: Colors.grey[350],
  appBarTheme: const AppBarTheme(
    color: Colors.transparent
  ),

  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 43, 173, 225),
    primary: const Color.fromARGB(255, 251, 231, 146),
    secondary: const Color.fromARGB(255, 211, 211, 211)
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.all(0),
      backgroundColor: const Color.fromARGB(255, 211, 211, 211),
      foregroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(15))
      ),
    )
  ), 

  inputDecorationTheme: const InputDecorationTheme(
    outlineBorder: BorderSide(
      color: Color.fromARGB(255, 43, 173, 225)
    ),
    focusColor: Color.fromARGB(255, 43, 173, 225),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color.fromARGB(255, 43, 173, 225))
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