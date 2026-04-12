import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flashpay/views/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http; // أو Dio
import 'package:flashpay/data/network/api_client.dart'; // ✅ إضافة استيراد ApiClient

class NotificationController extends GetxController {
  
  @override
  void onInit() {
    super.onInit();
    setupPushNotifications();
  }
  

  Future<void> setupPushNotifications() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    // 1. طلب الصلاحية أولاً
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // 2. إجبار النظام على إظهار التنبيهات حتى والتطبيق مفتوح (خاصة لـ iOS)
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      String? token = await messaging.getToken();
      if (token != null) {
        print("FCM Token: $token");
        await sendTokenToServer(token);
      }

      messaging.onTokenRefresh.listen((newToken) {
        sendTokenToServer(newToken);
      });
    }

    // 3. الاستماع للإشعارات في الـ Foreground
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      try {
        print('✅ وصل إشعار والتطبيق مفتوح: ${message.notification?.title}');
        
        // محاولة تشغيل الصوت داخل try-catch حتى لا ينهار الكود لو فشل الصوت
        try {
          FlutterRingtonePlayer().playNotification();
        } catch (e) {
          print('⚠️ خطأ في تشغيل الصوت: $e');
        }

        String? type = message.data['type'];
        String? transferId = message.data['transfer_id'];

        // إظهار التنبيه العلوي (Snackbar)
        Get.snackbar(
  message.notification?.title ?? "تنبيه جديد",
  message.notification?.body ?? "",
  snackPosition: SnackPosition.TOP,
  backgroundColor: Colors.blueAccent.withOpacity(0.9),
  colorText: Colors.white,
  duration: const Duration(seconds: 4),
  margin: const EdgeInsets.all(10),
  onTap: (snack) {
    String? type = message.data['type'];
    
    if (type == 'chat') {
      // ✅ قراءة البيانات بشكل آمن (Safe Parsing) لتجنب الانهيار
      int tId = int.tryParse(message.data['transfer_id']?.toString() ?? '0') ?? 0;
      String tCode = message.data['tracking_code']?.toString() ?? 'N/A';
      int cUserId = int.tryParse(message.data['current_user_id']?.toString() ?? '0') ?? 0;

      // التأكد أن الـ ID موجود قبل الانتقال
      if (tId > 0) {
        Get.to(() => ChatScreen(
          transferId: tId,
          trackingCode: tCode,
          currentUserId: cUserId,
        ));
      }
    } else if (type == 'transfer_ready' || type == 'transfer_completed') {
      // هنا يمكنك التوجيه لصفحة تفاصيل الحوالة مستقبلاً
    }
  },
);
      } catch (e) {
        print('❌ خطأ غير متوقع أثناء عرض الإشعار: $e');
      }
    });
  }

  Future<void> sendTokenToServer(String token) async {
    try {
      // ✅ استخدام ApiClient بدلاً من http لضمان إرفاق توكن المصادقة (Sanctum) تلقائياً
      var dio = ApiClient().dio;
      await dio.post('/update-fcm-token', data: {
        'fcm_token': token
      });
      print("✅ تم تحديث الـ FCM Token في السيرفر بنجاح");
    } catch (e) {
      print("❌ فشل تحديث الـ FCM Token: $e");
    }
  }
}