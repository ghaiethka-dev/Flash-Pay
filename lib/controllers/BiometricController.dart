// lib/controllers/biometric_controller.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_auth/local_auth.dart';

class BiometricController extends GetxController {
  final LocalAuthentication _auth = LocalAuthentication();
  final _box = GetStorage();

  static const _kBiometricEnabled = 'biometric_enabled';

  final RxBool isBiometricEnabled = false.obs;
  final RxBool isBiometricAvailable = false.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAvailability();
    // استرجاع الحالة المحفوظة من التخزين المحلي
    isBiometricEnabled.value = _box.read<bool>(_kBiometricEnabled) ?? false;
  }

  /// فحص دعم الجهاز للبصمة
  Future<void> _checkAvailability() async {
    try {
      final bool canCheck = await _auth.canCheckBiometrics;
      final bool isDeviceSupported = await _auth.isDeviceSupported();
      isBiometricAvailable.value = canCheck && isDeviceSupported;

      // إذا كان الجهاز لا يدعم البصمة → ألغِ الحالة المحفوظة
      if (!isBiometricAvailable.value) {
        isBiometricEnabled.value = false;
        await _box.write(_kBiometricEnabled, false);
      }
    } on PlatformException {
      isBiometricAvailable.value = false;
    }
  }

  /// تفعيل/إلغاء البصمة مع طلب المصادقة الفعلية
  Future<void> toggleBiometric(bool value) async {
    if (!isBiometricAvailable.value) {
      Get.snackbar(
        'غير مدعوم',
        'جهازك لا يدعم تسجيل الدخول بالبصمة',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: value
            ? 'قم بالتحقق لتفعيل تسجيل الدخول بالبصمة'
            : 'قم بالتحقق لإلغاء تسجيل الدخول بالبصمة',
        options: const AuthenticationOptions(
          biometricOnly: false, // يسمح بـ PIN كبديل
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        isBiometricEnabled.value = value;
        // ✅ حفظ الحالة في التخزين المحلي
        await _box.write(_kBiometricEnabled, value);

        Get.snackbar(
          value ? 'تم التفعيل ✓' : 'تم الإلغاء',
          value
              ? 'تسجيل الدخول بالبصمة مفعّل الآن'
              : 'تم إلغاء تسجيل الدخول بالبصمة',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: value
              ? const Color(0xFF4CAF50).withOpacity(0.9)
              : const Color(0xFFFF5722).withOpacity(0.9),
          colorText: const Color(0xFFFFFFFF),
        );
      }
      // إذا فشل المستخدم في المصادقة → لا تغير الحالة
      // isBiometricEnabled يبقى على قيمته القديمة تلقائياً
    } on PlatformException catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل التحقق: ${e.message}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// مصادقة بالبصمة عند فتح التطبيق (تُستدعى من SplashScreen)
  Future<bool> authenticateOnLaunch() async {
    if (!isBiometricEnabled.value || !isBiometricAvailable.value) return true;

    try {
      return await _auth.authenticate(
        localizedReason: 'قم بالتحقق للدخول إلى FlashPay',
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );
    } on PlatformException {
      return false;
    }
  }
}