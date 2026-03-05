import 'package:flutter/material.dart';

class AppColors {
  // التدرج اللوني الذي طلبته بناءً على HSL (28, 95%, 40%) إلى (28, 95%, 35%)
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFC75D05), // تقريبي لـ hsl(28, 95%, 40%)
      Color(0xFFA64D04), // تقريبي لـ hsl(28, 95%, 35%)
    ],
  );

  static const Color darkBackground = Color(0xFF132341); // لون الخلفية الأزرق الداكن
}