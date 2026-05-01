import 'package:flashpay/controllers/notification_controller.dart';
import 'package:flashpay/controllers/theme_controller.dart';
import 'package:flashpay/core/AppTheme.dart';
import 'package:flashpay/views/BlcokedScreen.dart';
import 'package:flashpay/views/auth/splash_screen.dart'; // ← السبلاش الجديدة
import 'package:flashpay/views/chat/chat_screen.dart';
import 'package:flashpay/views/dashboards/agent_dashboards/agent_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'firebase_options.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/dashboards/user_dashboards/user_dashboard.dart';
import 'data/local/storage_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


// دالة لاستقبال الإشعارات والتطبيق مغلق أو في الخلفية
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await GetStorage.init();
  Get.put(StorageService());
  Get.put(ThemeController());
  Get.put(NotificationController());
  runApp(const FlashPayApp());
}

class FlashPayApp extends StatelessWidget {
  const FlashPayApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();
    return GetMaterialApp(
      title: 'FlashPay',
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode,
      getPages: [
        GetPage(name: '/splash',           page: () => const SplashScreen()),
        GetPage(name: '/login',            page: () => LoginScreen()),
        GetPage(name: '/register',         page: () => RegisterScreen()),
        GetPage(name: '/user_dashboard',   page: () => const UserDashboardView()),
        GetPage(name: '/agent_dashboard',  page: () => const AgentDashboard()),
        GetPage(name: '/blocked',          page: () => const BlockedScreen()),
      ],
    );
  }
}