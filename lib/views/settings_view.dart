import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../core/constants.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // استدعاء AuthController الموجود في الذاكرة
    final AuthController authController = Get.find<AuthController>();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
       
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                'إعدادات الحساب',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 16),

              // قائمة الإعدادات (يمكنك إضافة المزيد هنا مستقبلاً)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
                  ],
                ),
                child: Column(
                  children: [
                    // زر تسجيل الخروج
                    ListTile(
                      onTap: () {
                        // نافذة منبثقة لتأكيد تسجيل الخروج
                        Get.defaultDialog(
                          title: "تسجيل الخروج",
                          titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                          middleText: "هل أنت متأكد أنك تريد تسجيل الخروج من حسابك؟",
                          textConfirm: "نعم، خروج",
                          textCancel: "إلغاء",
                          confirmTextColor: Colors.white,
                          buttonColor: Colors.red,
                          cancelTextColor: AppColors.primaryGradient.colors.first,
                          onConfirm: () => authController.logout(),
                        );
                      },
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.logout, color: Colors.red),
                      ),
                      title: const Text(
                        'تسجيل الخروج',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}