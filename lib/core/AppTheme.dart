import 'package:flutter/material.dart';

class AppTheme {
  // الألوان الأساسية
  static const Color primaryColor = Color(0xFFA64D04);
  static const Color primaryLight = Color(0xFFC75D05);
  
  // ألوان الوضع الفاتح
  static const Color lightBackground = Color(0xFFF5F7FA);
  static const Color lightCardColor = Colors.white;
  static const Color lightTextColor = Colors.black87;

  // ألوان الوضع الداكن (بناءً على ما كتبته في constants.dart)
  static const Color darkBackground = Color(0xFF132341);
  static const Color darkCardColor = Color(0xFF1E325C); // لون أفتح قليلاً للبطاقات
  static const Color darkTextColor = Colors.white;

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
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Tajawal'),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: lightTextColor),
      bodyMedium: TextStyle(color: lightTextColor),
      titleLarge: TextStyle(color: lightTextColor, fontWeight: FontWeight.bold),
    ),
    colorScheme: const ColorScheme.light(
      primary: primaryColor,
      surface: lightCardColor,
      background: lightBackground,
    ),
  );

  // ================= الثيم الداكن =================
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: primaryLight,
    scaffoldBackgroundColor: darkBackground,
    cardColor: darkCardColor,
    dividerColor: Colors.grey.shade800,
    iconTheme: const IconThemeData(color: primaryLight),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkBackground, // في الدارك مود يفضل أن يكون الأب بار بلون الخلفية
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
      titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Tajawal'),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: darkTextColor),
      bodyMedium: TextStyle(color: Colors.white70),
      titleLarge: TextStyle(color: darkTextColor, fontWeight: FontWeight.bold),
    ),
    colorScheme: const ColorScheme.dark(
      primary: primaryLight,
      surface: darkCardColor,
      background: darkBackground,
    ),
  );
}