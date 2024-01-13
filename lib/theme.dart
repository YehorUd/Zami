import 'package:flutter/material.dart';

// Stworzenie niestandardowego motywu aplikacji
final appTheme = ThemeData(
  brightness: Brightness.light, // Jasny motyw
  primaryColor: Colors.green, // Główny kolor aplikacji - zielony
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.green, // Wybór kolorów bazujący na odcieniach zielonego
    accentColor: Colors.purple, // Kolor akcentu - fioletowy
  ),
  fontFamily: 'Roboto', // Domyślna czcionka aplikacji
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.green, // Kolor paska aplikacji
    elevation: 0, // Brak cienia paska
    titleTextStyle: TextStyle(
      color: Colors.white, // Kolor tekstu na pasku aplikacji
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.green, // Kolor przycisków "Elevated"
      foregroundColor: Colors.white, // Kolor tekstu na przyciskach "Elevated"
      textStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      backgroundColor: Colors.green, // Kolor przycisków tekstowych
      textStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.green), // Kolor obramowania pól tekstowych
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.green), // Kolor obramowania pól tekstowych w trybie focus
    ),
    labelStyle: TextStyle(color: Colors.green), // Kolor etykiety pól tekstowych
  ),
  textTheme: TextTheme(
    titleLarge: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
    ),
    bodyMedium: TextStyle(
      fontSize: 16,
    ),
  ),
);
