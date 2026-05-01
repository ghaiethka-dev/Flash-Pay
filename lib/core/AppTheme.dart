import 'package:flutter/material.dart';

class AppTheme {
  // الألوان الأساسية
  static const Color primaryColor = Color(0xFFA64D04);
  static const Color primaryLight = Color(0xFFE8834A);

  // ألوان الوضع الفاتح
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightCardColor  = Colors.white;
  static const Color lightTextColor  = Colors.black87;

  // ألوان الوضع الداكن — أسود فاخر
  static const Color darkBackground  = Color(0xFF0A0A0A); // أسود عميق
  static const Color darkSurface     = Color(0xFF141414); // أسود أفتح للبطاقات
  static const Color darkCardColor   = Color(0xFF1C1C1C); // رمادي داكن جداً للعناصر
  static const Color darkTextColor   = Color(0xFFF0F0F0); // أبيض ناعم

  // ================= الثيم الفاتح =================
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: primaryColor,
    scaffoldBackgroundColor: lightBackground,
    cardColor: lightCardColor,
    dividerColor: Colors.grey.shade300,
    iconTheme: const IconThemeData(color: primaryColor),
    appBarTheme: const AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Tajawal',
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge:  TextStyle(color: lightTextColor),
      bodyMedium: TextStyle(color: lightTextColor),
      titleLarge: TextStyle(color: lightTextColor, fontWeight: FontWeight.bold),
    ),
    colorScheme: const ColorScheme.light(
      primary:    primaryColor,
      surface:    lightCardColor,
      background: lightBackground,
    ),
  );

  // ================= الثيم الداكن — أسود فاخر =================
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryLight,
    scaffoldBackgroundColor: darkBackground,
    cardColor: darkCardColor,
    dividerColor: const Color(0xFF2A2A2A),
    iconTheme: const IconThemeData(color: primaryLight),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Tajawal',
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge:  TextStyle(color: darkTextColor),
      bodyMedium: TextStyle(color: Color(0xFFAAAAAA)),
      titleLarge: TextStyle(color: darkTextColor, fontWeight: FontWeight.bold),
    ),
    colorScheme: const ColorScheme.dark(
      primary:    primaryLight,
      surface:    darkSurface,
      background: darkBackground,
      onSurface:  darkTextColor,
      onBackground: darkTextColor,
    ),
  );
}