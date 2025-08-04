import 'package:flutter/material.dart';

// Thème clair
final ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.pink,
    brightness: Brightness.light, // Important pour éviter l'erreur
  ),
  brightness: Brightness.light,
  useMaterial3: true,
);

// Thème sombre
final ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color.fromARGB(255, 0, 0, 0),
    brightness: Brightness.dark, // Important pour éviter l'erreur
  ),
  brightness: Brightness.dark,
  useMaterial3: true,
);

// Provider pour le mode sombre/clair
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
