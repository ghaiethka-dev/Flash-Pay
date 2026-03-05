import 'package:flashpay/views/dashboards/agent_dashboard.dart';
import 'package:flashpay/views/dashboards/user_dashboard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/register_screen.dart';
import 'data/local/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تهيئة الـ StorageService
  await Get.putAsync(() => StorageService().init());

  runApp(const FlashPayApp());
}

class FlashPayApp extends StatelessWidget {
  const FlashPayApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FlashPay',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => RegisterScreen()),
        // مسارات مبدئية سيتم إنشاؤها لاحقاً
        GetPage(name: '/user_dashboard', page: () => const UserDashboardView()),
        GetPage(name: '/agent_dashboard', page: () => const AgentDashboard()),
      ],
    );
  }
}