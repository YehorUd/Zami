import 'package:flutter/material.dart';

final appTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.green,
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.green,
    accentColor: Colors.purple,
  ),
  fontFamily: 'Roboto',
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.green,
    elevation: 0,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green,
      foregroundColor: Colors.white,
      textStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      backgroundColor: Colors.green,
      textStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.green),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.green),
    ),
    labelStyle: TextStyle(color: Colors.green),
  ),
  textTheme: TextTheme(
    titleLarge: TextStyle( // Zaktualizowano z 'headline6' na 'titleLarge'
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    bodyMedium: TextStyle( // Zaktualizowano z 'bodyText2' na 'bodyMedium'
      fontSize: 16,
    ),
  ),
);
