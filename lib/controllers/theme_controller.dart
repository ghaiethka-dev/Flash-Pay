import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/local/storage_service.dart'; // تأكد من مسار التخزين لديك

class ThemeController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  // 1. السر هنا: تعريف المتغير كـ RxBool باستخدام .obs
  var isDarkMode = false.obs; 

  @override
  void onInit() {
    super.onInit();
    // 2. إعطاء القيمة الابتدائية من الذاكرة
    isDarkMode.value = _storageService.isDarkMode(); 
  }

  ThemeMode get themeMode => isDarkMode.value ? ThemeMode.dark : ThemeMode.light;

  void toggleTheme(bool isDark) {
    isDarkMode.value = isDark; // تحديث القيمة التفاعلية
    _storageService.saveThemeMode(isDark); // حفظ في الذاكرة
    Get.changeThemeMode(isDark ? ThemeMode.dark : ThemeMode.light); // تغيير الثيم
  }
}