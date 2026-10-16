// =============================================================================
//  fp_feedback.dart — FlashPay
//  Target path: lib/core/fp_feedback.dart
//
//  رسائل تغذية راجعة موحّدة (خطأ / نجاح / معلومة) عبر GetX فقط.
//  • تُغلق أي رسالة سابقة قبل إظهار الجديدة (لا تتراكم الرسائل)
//  • أيقونة + عنوان + نص، ولون دلالي لكل نوع
//  • مدة العرض تتناسب مع طول النص
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

enum _FPKind { error, success, info }

class FPFeedback {
  FPFeedback._();

  static const Color _red = Color(0xFFDC2626);
  static const Color _green = Color(0xFF16A34A);
  static const Color _blue = Color(0xFF2563EB);

  static void error(String message, {String title = 'تعذّر إكمال العملية'}) {
    HapticFeedback.mediumImpact();
    _show(_FPKind.error, title, message);
  }

  static void success(String message, {String title = 'تمت العملية بنجاح'}) {
    HapticFeedback.lightImpact();
    _show(_FPKind.success, title, message);
  }

  static void info(String message, {String title = 'تنبيه'}) {
    _show(_FPKind.info, title, message);
  }

  static void _show(_FPKind kind, String title, String message) {
    final Color color;
    final IconData icon;
    switch (kind) {
      case _FPKind.error:
        color = _red;
        icon = Icons.error_outline_rounded;
        break;
      case _FPKind.success:
        color = _green;
        icon = Icons.check_circle_outline_rounded;
        break;
      case _FPKind.info:
        color = _blue;
        icon = Icons.info_outline_rounded;
        break;
    }

    // مدة مقروءة: 3 ثوانٍ كحد أدنى + ثانية لكل 40 حرفًا
    final int seconds = (3 + (message.length / 40)).ceil().clamp(3, 7);

    // نغلق السابق فورًا حتى لا تتراكم الرسائل فوق بعضها
    if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

    Get.snackbar(
      title,
      message,
      titleText: Text(
        title,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 14,
        ),
      ),
      messageText: Text(
        message,
        textDirection: TextDirection.rtl,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          height: 1.4,
        ),
      ),
      icon: Icon(icon, color: Colors.white, size: 26),
      shouldIconPulse: false,
      backgroundColor: color,
      borderRadius: 16,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: seconds),
      animationDuration: const Duration(milliseconds: 320),
      forwardAnimationCurve: Curves.easeOutCubic,
      reverseAnimationCurve: Curves.easeInCubic,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      boxShadows: [
        BoxShadow(
          color: color.withOpacity(0.35),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }
}