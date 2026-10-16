// =============================================================================
//  lib/core/api_error.dart
//  FlashPay — تحويل أخطاء الشبكة/الخادم إلى رسائل عربية واضحة
//  (العرض للمستخدم عبر FPFeedback.error في fp_feedback.dart)
//  يتطلب dio >= 5 (DioException).
//
//  الأولوية: انقطاع الشبكة ← رسالة الخادم (إن كانت عربية أو قابلة للترجمة)
//            ← statusMessages التي يمررها المستدعي ← رسالة افتراضية حسب الـ status
// =============================================================================

import 'package:dio/dio.dart';

class ApiError {
  ApiError._();

  static const Map<String, String> _labels = {
    'email': 'البريد الإلكتروني',
    'password': 'كلمة المرور',
    'password_confirmation': 'تأكيد كلمة المرور',
    'phone': 'رقم الهاتف',
    'name': 'الاسم',
    'full_name': 'الاسم الكامل',
    'code': 'رمز التحقق',
    'country_id': 'البلد',
    'city_id': 'المدينة',
    'amount': 'المبلغ',
    'send_currency_id': 'عملة الإرسال',
    'currency_id': 'عملة الاستلام',
    'destination_office_id': 'مكتب الاستلام',
    'destination_country_id': 'دولة الاستلام',
    'destination_city': 'مدينة الاستلام',
    'receiver_name': 'اسم المستلم',
    'receiver_phone': 'رقم هاتف المستلم',
    'message': 'الرسالة',
    'image': 'الصورة',
    'selfie_with_id': 'الصورة الشخصية مع الهوية',
    'id_card_front': 'وجه الهوية',
    'id_card_back': 'ظهر الهوية',
  };

  static bool _hasArabic(String s) => RegExp(r'[\u0600-\u06FF]').hasMatch(s);

  /// الرسالة النهائية التي تُعرض للمستخدم.
  /// [statusMessages]: رسائل خاصة بكل status تُستخدم إذا لم يرسل الخادم رسالة مفهومة.
  static String message(
      Object error, {
        String? fallback,
        Map<int, String>? statusMessages,
      }) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'انتهت مهلة الاتصال، تحقق من الإنترنت وحاول مرة أخرى';
        case DioExceptionType.connectionError:
          return 'تعذّر الاتصال بالخادم، تحقق من اتصالك بالإنترنت';
        case DioExceptionType.cancel:
          return 'تم إلغاء الطلب';
        default:
          break;
      }

      final status = error.response?.statusCode;

      final fromServer = _fromBody(error.response?.data);
      if (fromServer != null) return fromServer;

      if (status != null && statusMessages != null) {
        final custom = statusMessages[status];
        if (custom != null) return custom;
      }

      switch (status) {
        case 401:
          return 'انتهت الجلسة، سجّل الدخول من جديد';
        case 403:
          return 'ليس لديك صلاحية لتنفيذ هذا الإجراء';
        case 404:
          return 'العنصر المطلوب غير موجود';
        case 413:
          return 'حجم الملف كبير جدًا، اختر صورة أصغر';
        case 422:
          return 'بعض البيانات غير صحيحة، راجع الحقول وحاول مرة أخرى';
        case 429:
          return 'محاولات كثيرة، انتظر دقيقة ثم أعد المحاولة';
      }
      if ((status ?? 0) >= 500) {
        return 'حدث خلل مؤقت في الخادم، حاول بعد قليل';
      }
    }
    return fallback ?? 'حدث خطأ غير متوقع، حاول مرة أخرى';
  }

  /// أخطاء كل حقل (من استجابة 422 في Laravel): {field: رسالة عربية}
  static Map<String, String> fieldErrors(Object error) {
    final out = <String, String>{};
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['errors'] is Map) {
        (data['errors'] as Map).forEach((k, v) {
          final raw =
          v is List && v.isNotEmpty ? v.first.toString() : v.toString();
          out[k.toString()] = _translate(raw, k.toString()) ?? 'قيمة غير صحيحة';
        });
      }
    }
    return out;
  }

  static String? _fromBody(dynamic data) {
    if (data is! Map) return null;

    final errors = data['errors'];
    if (errors is Map && errors.isNotEmpty) {
      final key = errors.keys.first.toString();
      final v = errors[key];
      final raw = v is List && v.isNotEmpty ? v.first.toString() : v.toString();
      final t = _translate(raw, key);
      if (t != null) return t;
    }

    final msg = data['message'] ?? data['error'];
    if (msg is String && msg.trim().isNotEmpty) {
      return _translate(msg, '');
    }
    return null;
  }

  /// يرجع null إذا لم تُفهم الرسالة، فيُستخدم الاحتياطي حسب الـ status.
  static String? _translate(String raw, String field) {
    if (_hasArabic(raw)) return raw; // الخادم أرسل رسالة عربية جاهزة
    final lower = raw.toLowerCase();
    final bool known = _labels.containsKey(field);
    final String label = _labels[field] ?? 'هذا الحقل';

    if (lower.contains('already been taken')) {
      if (field == 'email') {
        return 'هذا البريد الإلكتروني مسجّل مسبقًا، جرّب تسجيل الدخول';
      }
      if (field == 'phone') return 'رقم الهاتف مسجّل مسبقًا';
      return '$label مستخدم مسبقًا';
    }
    if (lower.contains('valid email')) return 'صيغة البريد الإلكتروني غير صحيحة';
    if (lower.contains('confirmation does not match')) {
      return 'كلمتا المرور غير متطابقتين';
    }
    if (lower.contains('field is required')) return '$label مطلوب';
    if (lower.contains('must be at least')) {
      final n = RegExp(r'at least (\d+)').firstMatch(lower)?.group(1);
      if (n != null) {
        return lower.contains('characters')
            ? '$label يجب ألا يقل عن $n أحرف'
            : '$label يجب ألا يقل عن $n';
      }
    }
    if (lower.contains('may not be greater than') ||
        lower.contains('must not be greater than')) {
      return lower.contains('kilobytes')
          ? 'حجم الملف كبير جدًا، اختر صورة أصغر'
          : '$label أكبر من المسموح';
    }
    if (lower.contains('must be an image') ||
        lower.contains('must be a file of type')) {
      return 'نوع الملف غير مدعوم، اختر صورة بصيغة JPG أو PNG';
    }
    if (lower.contains('too many')) {
      return 'محاولات كثيرة، انتظر دقيقة ثم أعد المحاولة';
    }
    if (lower.contains('unauthenticated')) {
      return 'انتهت الجلسة، سجّل الدخول من جديد';
    }
    if (lower.contains('credentials') || lower.contains('invalid login')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }
    if (known && (lower.contains('invalid') || lower.contains('incorrect'))) {
      return '$label غير صحيح';
    }
    return null;
  }
}