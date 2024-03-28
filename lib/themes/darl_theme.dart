import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
    appBarTheme: AppBarTheme(backgroundColor: Colors.black),
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      background: Colors.black,
      primary: Colors.grey[900]!,
      secondary: Colors.grey[800]!,
      tertiary: Colors.grey[200]!,
    ),
    textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: Colors.white)));
