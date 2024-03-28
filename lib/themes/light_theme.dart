import 'package:flutter/material.dart';

ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.black!,
    foregroundColor: Colors.white!,
  ),
  colorScheme: ColorScheme.light(
    background: Colors.grey[300]!,
    primary: Colors.grey[200]!,
    secondary: Colors.grey[300]!,
    tertiary: Color.fromARGB(255, 55, 53, 53)!,
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: Colors.black),
  ),
);
