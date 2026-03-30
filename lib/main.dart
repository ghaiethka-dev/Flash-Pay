import 'package:flashpay/controllers/notification_controller.dart';
import 'package:flashpay/controllers/theme_controller.dart';
import 'package:flashpay/core/AppTheme.dart';
import 'package:flashpay/views/BlcokedScreen.dart';
import 'package:flashpay/views/chat/chat_screen.dart';
import 'package:flashpay/views/dashboards/agent_dashboards/agent_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'views/dashboards/user_dashboards/user_dashboard.dart';
import 'data/local/storage_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


// دالة لاستقبال الإشعارات والتطبيق مغلق أو في الخلفية
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await GetStorage.init();
  // 1. حقن خدمة التخزين في الذاكرة لتبدأ بالاستيقاظ
  Get.put(StorageService());
  Get.put(ThemeController());
  Get.put(NotificationController());
  // 2. تشغيل التطبيق بدون تحديد مسار مسبق، سنترك صفحة التحميل تقرر
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

      // مسار البداية أصبح صفحة التحميل الذكية
      initialRoute: '/splash',
      // ====== إضافة الثيمات هنا ======
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeController.themeMode, // يقرأ الثيم المحفوظ
      // ==============================

      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        GetPage(name: '/user_dashboard', page: () => const UserDashboardView()),
        GetPage(name: '/agent_dashboard', page: () => const AgentDashboard()),
        GetPage(name: '/blocked', page: () => const BlockedScreen()),
        
        
      ],
    );
  }
}

// ==========================================
// صفحة التحميل الذكية (Splash Screen)
// ==========================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final storageService = Get.find<StorageService>();

    // الحل السحري: إعطاء التطبيق نصف ثانية ليقرأ الذاكرة براحة وبدون أخطاء
    await Future.delayed(const Duration(milliseconds: 500));

    String? token = storageService.getToken();
    String? role = storageService.getUserRole();
    bool isBlocked = storageService.getIsBlocked();

    // فحص التوكن والتوجه للصفحة المناسبة
    if (token != null && token.isNotEmpty) {
      if (isBlocked) {
        Get.offAllNamed('/blocked');
      } else if (role == 'agent') {
        Get.offAllNamed('/agent_dashboard');
      } else {
        Get.offAllNamed('/user_dashboard');
      }
    } else {
      Get.offAllNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      body: Center(
        // مؤشر تحميل دائري يظهر للحظات بألوان تطبيقك
        child: CircularProgressIndicator(color: Color(0xFFA64D04)),
      ),
    );
  }
}