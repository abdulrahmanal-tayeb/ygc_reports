import 'package:flutter/material.dart';

const Color darkBackground = Color(0xFF121212);
const Color pureWhite = Colors.white;
const Color dimWhite = Color(0xFFDDDDDD);

/// Defines the Dark Themes in the entire app.
final ThemeData darkTheme = ThemeData(
  fontFamily: 'Cairo',
  useMaterial3: true,
  colorScheme: const ColorScheme.dark(
    primary: Colors.white,
    secondary: Colors.white,
    surface: darkBackground,
    onPrimary: darkBackground,
    onSecondary: darkBackground,
    onSurface: pureWhite,
  ),
  scaffoldBackgroundColor: darkBackground,
  appBarTheme: const AppBarTheme(
    backgroundColor: darkBackground,
    foregroundColor: pureWhite,
    elevation: 0,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: darkBackground,
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: Colors.white,
      side: const BorderSide(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: Colors.white,
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    labelStyle: const TextStyle(color: pureWhite),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: pureWhite),
      borderRadius: BorderRadius.circular(12),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.white,
    foregroundColor: darkBackground,
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: darkBackground,
    selectedItemColor: Colors.white,
    unselectedItemColor: Color(0xFF888888),
    elevation: 8,
  ),
  cardTheme: CardTheme(
    color: const Color(0xFF1C1C1C),
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  chipTheme: ChipThemeData.fromDefaults(
    secondaryColor: Colors.white,
    brightness: Brightness.dark,
    labelStyle: const TextStyle(color: darkBackground),
  ),
  hintColor: dimWhite,
  textTheme: ThemeData.dark().textTheme.apply(
        displayColor: pureWhite,
        bodyColor: pureWhite,
      ),
);
