import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  bool _isDarkMode = false;

  ThemeProvider() {
    _loadTheme();
  }

  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_themeKey) ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, _isDarkMode);
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, value);
  }

  // Theme data
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: const Color(0xFF4F46E5),
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      colorScheme: const ColorScheme.light(
        primary: Color(0xFF4F46E5),
        secondary: Color(0xFF10B981),
        surface: Colors.white,
        error: Color(0xFFEF4444),
        onPrimary: Colors.white,
        onSurface: Color(0xFF1F2937),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE5E7EB)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF1F2937)),
        titleTextStyle: TextStyle(
          color: Color(0xFF1F2937),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      dividerColor: const Color(0xFFE5E7EB),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFF1F2937)),
        bodyMedium: TextStyle(color: Color(0xFF1F2937)),
        titleLarge: TextStyle(color: Color(0xFF1F2937)),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: const Color(0xFF6366F1),
      scaffoldBackgroundColor: const Color(0xFF0F172A),
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF6366F1),
        secondary: Color(0xFF10B981),
        surface: Color(0xFF1E293B),
        error: Color(0xFFEF4444),
        onPrimary: Colors.white,
        onSurface: Color(0xFFF1F5F9),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF334155)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1E293B),
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFFF1F5F9)),
        titleTextStyle: TextStyle(
          color: Color(0xFFF1F5F9),
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      dividerColor: const Color(0xFF334155),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Color(0xFFF1F5F9)),
        bodyMedium: TextStyle(color: Color(0xFFF1F5F9)),
        titleLarge: TextStyle(color: Color(0xFFF1F5F9)),
      ),
    );
  }
}
