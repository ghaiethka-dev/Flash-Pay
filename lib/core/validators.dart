// =============================================================================
//  lib/core/validators.dart
//  FlashPay — مدقّقات الإدخال (رسائل عربية واضحة تقول للمستخدم ما المشكلة وكيف يصلحها)
// =============================================================================

import 'package:flutter/material.dart';

class FPValidators {
  FPValidators._();

  static final RegExp _emailRe = RegExp(
    r"^[A-Za-z0-9._%+\-]+@[A-Za-z0-9\-]+(\.[A-Za-z0-9\-]+)*\.[A-Za-z]{2,}$",
  );

  /// أخطاء الكتابة الشائعة في نطاقات البريد.
  static const Map<String, String> _domainTypos = {
    'gmial.com': 'gmail.com',
    'gamil.com': 'gmail.com',
    'gmai.com': 'gmail.com',
    'gnail.com': 'gmail.com',
    'gmail.con': 'gmail.com',
    'gmail.co': 'gmail.com',
    'hotmial.com': 'hotmail.com',
    'hotmai.com': 'hotmail.com',
    'yaho.com': 'yahoo.com',
    'yahho.com': 'yahoo.com',
    'outlok.com': 'outlook.com',
  };

  /// يحوّل الأرقام العربية الهندية والفارسية إلى أرقام لاتينية.
  static String normalizeDigits(String input) {
    const arabic = '٠١٢٣٤٥٦٧٨٩';
    const persian = '۰۱۲۳۴۵۶۷۸۹';
    final sb = StringBuffer();
    for (final ch in input.runes) {
      final c = String.fromCharCode(ch);
      final a = arabic.indexOf(c);
      final p = persian.indexOf(c);
      sb.write(a >= 0 ? a : (p >= 0 ? p : c));
    }
    return sb.toString();
  }

  // ───────────────────────────── البريد ─────────────────────────────
  static String? email(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return 'أدخل بريدك الإلكتروني';
    if (s.contains(' ')) return 'البريد الإلكتروني لا يجب أن يحتوي على مسافات';
    if (s.length > 254) return 'البريد الإلكتروني طويل جدًا';
    if (!s.contains('@')) {
      return 'البريد الإلكتروني ينقصه الرمز @، مثال: name@example.com';
    }
    if (!_emailRe.hasMatch(s)) {
      return 'صيغة البريد غير صحيحة، مثال: name@example.com';
    }
    final at = s.lastIndexOf('@');
    final domain = s.substring(at + 1).toLowerCase();
    final fix = _domainTypos[domain];
    if (fix != null) {
      return 'هل تقصد ${s.substring(0, at)}@$fix؟ تحقق من كتابة البريد';
    }
    return null;
  }

  // ───────────────────────────── كلمة المرور ─────────────────────────────
  /// تسجيل الدخول: التحقق من الإدخال فقط، دون كشف أي قاعدة عن كلمات المرور.
  static String? loginPassword(String? v) {
    if ((v ?? '').isEmpty) return 'أدخل كلمة المرور';
    return null;
  }

  /// إنشاء حساب / إعادة تعيين: الحد الأدنى 8 أحرف.
  static String? newPassword(String? v) {
    final s = v ?? '';
    if (s.isEmpty) return 'أدخل كلمة المرور';
    if (s.trim().isEmpty) return 'كلمة المرور لا يمكن أن تكون مسافات فقط';
    if (s.length < 8) {
      return 'كلمة المرور قصيرة (${s.length} من 8 أحرف على الأقل)';
    }
    if (RegExp(r'^(.)\1+$').hasMatch(s)) {
      return 'لا تستخدم حرفًا واحدًا مكرّرًا، اختر كلمة مرور أصعب';
    }
    return null;
  }

  /// مدقّق تأكيد كلمة المرور؛ يقارن مع حقل كلمة المرور الأصلي.
  static String? Function(String?) confirmPassword(
      TextEditingController original) {
    return (String? v) {
      if ((v ?? '').isEmpty) return 'أعد كتابة كلمة المرور للتأكيد';
      if (v != original.text) return 'كلمتا المرور غير متطابقتين';
      return null;
    };
  }

  // ───────────────────────────── الاسم ─────────────────────────────
  static String? fullName(String? v, {String who = 'اسمك'}) {
    final s = (v ?? '').trim().replaceAll(RegExp(r'\s+'), ' ');
    if (s.isEmpty) return 'أدخل $who الكامل';
    if (RegExp(r'[0-9٠-٩۰-۹]').hasMatch(s)) {
      return 'الاسم لا يجب أن يحتوي على أرقام';
    }
    if (!RegExp(r'^[\u0600-\u06FFA-Za-z\s\.\-]+$').hasMatch(s)) {
      return 'الاسم يجب أن يتكوّن من أحرف فقط، بدون رموز';
    }
    final parts = s.split(' ');
    if (parts.length < 2) return 'أدخل الاسم الأول واسم العائلة على الأقل';
    if (parts.any((p) => p.length < 2)) {
      return 'كل جزء من الاسم يجب أن يكون حرفين على الأقل';
    }
    return null;
  }

  // ───────────────────────────── رمز التحقق ─────────────────────────────
  static String? otpCode(String? v, {int length = 6}) {
    final s = normalizeDigits((v ?? '').trim());
    if (s.isEmpty) return 'أدخل رمز التحقق الذي وصلك على البريد';
    if (!RegExp(r'^\d+$').hasMatch(s)) return 'رمز التحقق أرقام فقط';
    if (s.length != length) {
      return 'رمز التحقق مكوّن من $length أرقام (أدخلت ${s.length})';
    }
    return null;
  }

  // ───────────────────────────── القوائم المنسدلة ─────────────────────────────
  static String? Function(T?) selected<T>(String message) {
    return (T? v) => v == null ? message : null;
  }

  // ───────────────────────────── المبالغ (لنماذج الحوالات) ─────────────────────────────
  /// ينظّف المبلغ بعد نجاح التحقق: أرقام لاتينية، بدون فواصل آلاف.
  /// استخدمه قبل double.tryParse وقبل الإرسال إلى الخادم.
  static String cleanAmount(String? v) {
    return normalizeDigits((v ?? '').trim())
        .replaceAll('٬', ',')
        .replaceAll('٫', '.')
        .replaceAll(',', '')
        .replaceAll(RegExp(r'\s'), '');
  }

  static String? amount(String? v, {double min = 0.01, double? max}) {
    final raw = normalizeDigits((v ?? '').trim())
        .replaceAll('٬', ',')
        .replaceAll('٫', '.')
        .replaceAll(RegExp(r'\s'), '');
    if (raw.isEmpty) return 'أدخل المبلغ';
    if (RegExp(r'[A-Za-z\u0600-\u06FF]').hasMatch(raw)) {
      return 'المبلغ يجب أن يتكوّن من أرقام فقط';
    }
    // الفاصلة مقبولة كفاصل آلاف فقط (1,000)، أما 1,5 فمبهمة فنرفضها بدل أن تُقرأ 15
    if (raw.contains(',') &&
        !RegExp(r'^\d{1,3}(,\d{3})+(\.\d+)?$').hasMatch(raw)) {
      return 'استخدم النقطة للفاصلة العشرية، مثال: 250.50';
    }
    final cleaned = raw.replaceAll(',', '');
    if (RegExp(r'^\d+\.\d{3,}$').hasMatch(cleaned)) {
      return 'المبلغ لا يقبل أكثر من خانتين عشريتين';
    }
    if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(cleaned)) {
      return 'صيغة المبلغ غير صحيحة، مثال: 500 أو 250.50';
    }
    final n = double.tryParse(cleaned);
    if (n == null) return 'صيغة المبلغ غير صحيحة';
    if (n <= 0) return 'المبلغ يجب أن يكون أكبر من صفر';
    if (n < min) return 'أقل مبلغ مسموح هو $min';
    if (max != null && n > max) return 'المبلغ يتجاوز الحد المسموح ($max)';
    return null;
  }
}