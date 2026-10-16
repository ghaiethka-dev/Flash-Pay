// =============================================================================
//  notification_controller.dart — FlashPay
//  Target path: lib/controllers/notification_controller.dart
//
//  ✅ يحفظ كل إشعار يصل (foreground + عند فتحه من الخلفية/الإغلاق) في قائمة دائمة
//  ✅ عدّاد غير المقروء (يُستخدم في شريط التنقل والجرس)
//  ✅ تنبيه داخل التطبيق بتصميم متسق، ويُكتم إذا كانت المحادثة نفسها مفتوحة
//  ✅ فتح المحادثة عند الضغط على الإشعار
//  ⚠️ يحتاج حزمة shared_preferences:  flutter pub add shared_preferences
//  ⚠️ استدعِ NotificationController.to.clearAll() عند تسجيل الخروج
// =============================================================================
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flashpay/controllers/chat_controller.dart';
import 'package:flashpay/data/network/api_client.dart';
import 'package:flashpay/models/app_notification.dart';
import 'package:flashpay/views/chat/chat_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationController extends GetxController {
  static NotificationController get to => Get.find<NotificationController>();

  static const String _prefsKey = 'fp_notifications_v1';
  static const int _maxItems = 100;

  // ── الحالة ────────────────────────────────────────────────────────────────
  final items = <AppNotification>[].obs;
  final unread = 0.obs;
  final unreadOnly = false.obs; // فلتر "غير المقروءة"
  final now = DateTime.now().obs; // يُحدَّث كل دقيقة لتجديد "منذ x دقائق"

  SharedPreferences? _prefs;
  Timer? _tick;
  StreamSubscription<RemoteMessage>? _onMessageSub;
  StreamSubscription<RemoteMessage>? _openedSub;
  StreamSubscription<String>? _tokenSub;

  @override
  void onInit() {
    super.onInit();
    ever(items, (_) => unread.value = items.where((n) => !n.read).length);
    debounce(items, (_) => _persist(),
        time: const Duration(milliseconds: 400));
    _tick = Timer.periodic(
        const Duration(minutes: 1), (_) => now.value = DateTime.now());

    _load();
    setupPushNotifications();
  }

  @override
  void onClose() {
    _tick?.cancel();
    _onMessageSub?.cancel();
    _openedSub?.cancel();
    _tokenSub?.cancel();
    super.onClose();
  }

  // ===========================================================================
  //  التخزين
  // ===========================================================================
  Future<void> _load() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final raw = _prefs!.getString(_prefsKey);
      if (raw == null) return;
      final loaded = AppNotification.decodeList(raw);
      // دمج دون كتم ما وصل أثناء التحميل
      final existing = items.map((n) => n.id).toSet();
      items.addAll(loaded.where((n) => !existing.contains(n.id)));
      items.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    } catch (e) {
      debugPrint('Notifications load error: $e');
    }
  }

  Future<void> _persist() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs!.setString(_prefsKey, AppNotification.encodeList(items));
    } catch (e) {
      debugPrint('Notifications persist error: $e');
    }
  }

  // ===========================================================================
  //  إجراءات القائمة
  // ===========================================================================
  void markRead(String id) {
    final i = items.indexWhere((n) => n.id == id);
    if (i != -1 && !items[i].read) items[i] = items[i].copyWith(read: true);
  }

  void markAllRead() {
    if (unread.value == 0) return;
    items.assignAll(items.map((n) => n.read ? n : n.copyWith(read: true)));
  }

  void remove(String id) => items.removeWhere((n) => n.id == id);

  /// تراجع عن الحذف: يعيد الإشعار في موضعه الزمني
  void restore(AppNotification n) {
    if (items.any((x) => x.id == n.id)) return;
    final i = items.indexWhere((x) => x.receivedAt.isBefore(n.receivedAt));
    if (i == -1) {
      items.add(n);
    } else {
      items.insert(i, n);
    }
  }

  Future<void> clearAll() async {
    items.clear();
    unreadOnly.value = false;
    await _persist();
  }

  /// يفتح وجهة الإشعار ويعلّمه مقروءاً
  void open(AppNotification n) {
    markRead(n.id);
    if (n.type == 'chat') {
      final tId = int.tryParse(n.data['transfer_id'] ?? '') ?? 0;
      final cUserId = int.tryParse(n.data['current_user_id'] ?? '') ?? 0;
      if (tId > 0) {
        Get.to(() => ChatScreen(
          transferId: tId,
          trackingCode: n.data['tracking_code'] ?? 'N/A',
          currentUserId: cUserId,
        ));
      }
    }
    // transfer_ready / transfer_completed: وجهة تفاصيل الحوالة مستقبلاً
  }

  // ===========================================================================
  //  تحويل رسالة FCM إلى إشعار محفوظ (مع منع التكرار بالـ messageId)
  // ===========================================================================
  AppNotification _record(RemoteMessage m, {bool read = false}) {
    final id = m.messageId ?? '${DateTime.now().microsecondsSinceEpoch}';
    final existing = items.firstWhereOrNull((n) => n.id == id);
    if (existing != null) return existing;

    final n = AppNotification(
      id: id,
      title: m.notification?.title ?? m.data['title']?.toString() ?? 'تنبيه جديد',
      body: m.notification?.body ?? m.data['body']?.toString() ?? '',
      type: m.data['type']?.toString() ?? '',
      data: m.data.map((k, v) => MapEntry(k.toString(), v.toString())),
      receivedAt: DateTime.now(),
      read: read,
    );
    items.insert(0, n);
    if (items.length > _maxItems) items.removeRange(_maxItems, items.length);
    return n;
  }

  // ===========================================================================
  //  FCM
  // ===========================================================================
  Future<void> setupPushNotifications() async {
    try {
      final messaging = FirebaseMessaging.instance;

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // iOS: إظهار التنبيهات والتطبيق مفتوح
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        final token = await messaging.getToken();
        if (token != null) await sendTokenToServer(token);
        _tokenSub = messaging.onTokenRefresh.listen(sendTokenToServer);
      }

      // ── التطبيق مفتوح ────────────────────────────────────────────────────
      _onMessageSub = FirebaseMessaging.onMessage.listen(_onForegroundMessage);

      // ── ضغط على إشعار النظام والتطبيق في الخلفية ──────────────────────
      _openedSub = FirebaseMessaging.onMessageOpenedApp.listen((m) {
        open(_record(m, read: true));
      });

      // ── فتح التطبيق من إشعار وهو مغلق تماماً ───────────────────────────
      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        final n = _record(initial, read: true);
        Future.delayed(const Duration(milliseconds: 600), () => open(n));
      }
    } catch (e) {
      debugPrint('❌ setupPushNotifications error: $e');
    }
  }

  void _onForegroundMessage(RemoteMessage message) {
    try {
      final type = message.data['type']?.toString();
      final tId = int.tryParse(message.data['transfer_id']?.toString() ?? '') ?? 0;

      // المحادثة نفسها مفتوحة: تتحدّث تلقائياً، فلا داعي لتنبيه أو سجل
      final bool inSameChat = type == 'chat' &&
          Get.isRegistered<ChatController>() &&
          Get.find<ChatController>().transferId == tId;
      if (inSameChat) return;

      final n = _record(message);

      try {
        FlutterRingtonePlayer().playNotification();
      } catch (e) {
        debugPrint('⚠️ خطأ في تشغيل الصوت: $e');
      }

      _showBanner(n);
    } catch (e) {
      debugPrint('❌ خطأ أثناء عرض الإشعار: $e');
    }
  }

  /// تنبيه علوي بتصميم متسق مع الثيم (بدل الأزرق الافتراضي)
  void _showBanner(AppNotification n) {
    final bool isDark = Get.isDarkMode;
    final Color surface = isDark ? const Color(0xFF1F2430) : Colors.white;
    final Color fg = isDark ? Colors.white : const Color(0xFF132341);

    Get.closeCurrentSnackbar();
    Get.snackbar(
      n.title,
      n.body,
      snackPosition: SnackPosition.TOP,
      backgroundColor: surface,
      colorText: fg,
      borderRadius: 18,
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      duration: const Duration(seconds: 4),
      borderColor: n.color.withOpacity(0.35),
      borderWidth: 1.2,
      boxShadows: [
        BoxShadow(
          color: Colors.black.withOpacity(isDark ? 0.4 : 0.14),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
      icon: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsetsDirectional.only(start: 4),
        decoration: BoxDecoration(
          color: n.color.withOpacity(0.14),
          shape: BoxShape.circle,
        ),
        child: Icon(n.icon, color: n.color, size: 21),
      ),
      shouldIconPulse: false,
      onTap: (_) => open(n),
    );
  }

  Future<void> sendTokenToServer(String token) async {
    try {
      // ApiClient يُرفق توكن Sanctum تلقائياً
      await ApiClient().dio.post('/update-fcm-token', data: {'fcm_token': token});
      debugPrint('✅ تم تحديث الـ FCM Token في السيرفر بنجاح');
    } catch (e) {
      debugPrint('❌ فشل تحديث الـ FCM Token: $e');
    }
  }
}