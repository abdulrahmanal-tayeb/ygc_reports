import 'package:flutter/material.dart';

const Color whiteMain = Colors.white;
const Color blackText = Color(0xFF1C1C1C);
const Color softGray = Color(0xFFAAAAAA);

/// Defines the Light Theme in the entire app.
final ThemeData lightTheme = ThemeData(
  fontFamily: 'Cairo',
  useMaterial3: true,
  colorScheme: const ColorScheme.light(
    primary: Colors.black,
    secondary: Colors.black,
    surface: whiteMain,
    onPrimary: whiteMain,
    onSecondary: whiteMain,
    onSurface: blackText,
  ),
  scaffoldBackgroundColor: whiteMain,
  appBarTheme: const AppBarTheme(
    backgroundColor: whiteMain,
    foregroundColor: blackText,
    elevation: 0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      foregroundColor: whiteMain,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.black,
      side: const BorderSide(color: Colors.black),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.black,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: const TextStyle(color: blackText),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.black),
      borderRadius: BorderRadius.circular(12),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.black,
    foregroundColor: whiteMain,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: whiteMain,
    selectedItemColor: Colors.black,
    unselectedItemColor: softGray,
    elevation: 8,
  ),
  cardTheme: CardTheme(
    color: whiteMain,
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  chipTheme: ChipThemeData.fromDefaults(
    secondaryColor: Colors.black,
    brightness: Brightness.light,
    labelStyle: const TextStyle(color: whiteMain),
  ),
  hintColor: softGray,
  textTheme: ThemeData.light().textTheme.apply(
        displayColor: blackText,
        bodyColor: blackText,
      ),
  );
