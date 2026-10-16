import 'package:flashpay/controllers/BiometricController.dart';
import 'package:flashpay/controllers/notification_controller.dart';
import 'package:flashpay/controllers/theme_controller.dart';
import 'package:flashpay/core/AppTheme.dart';
import 'package:flashpay/core/app_transitions.dart';
import 'package:flashpay/views/BlcokedScreen.dart';
import 'package:flashpay/views/auth/splash_screen.dart';
import 'package:flashpay/views/chat/chat_screen.dart';
import 'package:flashpay/views/dashboards/agent_dashboards/agent_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'firebase_options.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/forgot_password_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/dashboards/user_dashboards/user_dashboard.dart';
import 'data/local/storage_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// ✅ @pragma ضروري في نسخة Release (أندرويد) حتى لا تُحذف الدالة عند التحسين
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await GetStorage.init();
  Get.put(StorageService());
  Get.put(ThemeController());
  // permanent: حتى لا يُحذف المتحكم (وقائمة الإشعارات) عند التنقل بين الصفحات
  Get.put(NotificationController(), permanent: true);
  // ✅ سجّل BiometricController هنا حتى يكون جاهزاً في SplashScreen
  Get.put(BiometricController());

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

      // ✅ انتقال موحّد بين الصفحات (يحترم "تقليل الحركة" في النظام)
      customTransition: FPTransition(),
      transitionDuration: FPMotion.page,
      // احتياطي لمسارات Get.to(() => ...) التي لا تمر عبر getPages
      defaultTransition: Transition.fadeIn,

      getPages: [
        // السبلاش والحظر: تلاشي هادئ بدل الانزلاق
        GetPage(
          name: '/splash',
          page: () => const SplashScreen(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 450),
        ),
        GetPage(
          name: '/login',
          page: () => const LoginScreen(),
          customTransition: FPTransition(),
          transitionDuration: FPMotion.page,
        ),
        GetPage(
          name: '/register',
          page: () => const RegisterScreen(),
          customTransition: FPTransition(),
          transitionDuration: FPMotion.page,
        ),
        GetPage(
          name: '/forgot_password',
          page: () => const ForgotPasswordScreen(),
          customTransition: FPTransition(),
          transitionDuration: FPMotion.page,
        ),
        GetPage(
          name: '/user_dashboard',
          page: () => const UserDashboardView(),
          customTransition: FPTransition(),
          transitionDuration: FPMotion.page,
        ),
        GetPage(
          name: '/agent_dashboard',
          page: () => const AgentDashboard(),
          customTransition: FPTransition(),
          transitionDuration: FPMotion.page,
        ),
        GetPage(
          name: '/blocked',
          page: () => const BlockedScreen(),
          transition: Transition.fadeIn,
          transitionDuration: const Duration(milliseconds: 400),
        ),
      ],
    );
  }
}