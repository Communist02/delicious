import 'package:flutter/material.dart';

class AppThemes {
  static ThemeMode getMode(String theme) {
    switch (theme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
    }
    return ThemeMode.system;
  }

  static ThemeData light() {
    final Color accentColor = Colors.amber.shade600;

    final ThemeData base = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.amber, backgroundColor: Colors.white),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: Colors.white,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          side: WidgetStatePropertyAll(BorderSide(color: Colors.grey.shade400))
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: accentColor,
        unselectedItemColor: Colors.black,
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: Colors.black,
        unselectedLabelColor: Colors.black,
      ),
    );
    return base;
  }

  static ThemeData dark() {
    const Color primaryColor = Color(0xFF202020);
    final Color accentColor = Colors.amber.shade200;

    final ThemeData base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorSchemeSeed: Colors.amber,
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: accentColor,
        unselectedItemColor: Colors.grey,
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: Colors.black,
        unselectedLabelColor: Colors.white,
      ),
    );
    return base;
  }
}
