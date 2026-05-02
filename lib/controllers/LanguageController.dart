// lib/controllers/language_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SupportedLanguage {
  final String code;      // 'ar'
  final String locale;    // 'SA'
  final String label;     // 'العربية'
  final String flag;      // '🇸🇦'

  const SupportedLanguage({
    required this.code,
    required this.locale,
    required this.label,
    required this.flag,
  });
}

class LanguageController extends GetxController {
  static const List<SupportedLanguage> supportedLanguages = [
    SupportedLanguage(code: 'ar', locale: 'SA', label: 'العربية', flag: '🇸🇦'),
    SupportedLanguage(code: 'en', locale: 'US', label: 'English', flag: '🇺🇸'),

  ];

  final Rx<SupportedLanguage> currentLanguage =
      supportedLanguages.first.obs; // الافتراضي: العربية

  String get currentLabel => currentLanguage.value.label;

  void changeLanguage(SupportedLanguage lang) {
    currentLanguage.value = lang;
    Get.updateLocale(Locale(lang.code, lang.locale));
    Get.back(); // إغلاق البوتوم شيت
  }
}