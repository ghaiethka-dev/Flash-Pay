import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart'; // استيراد مكتبة Lottie
import '../../controllers/auth_controller.dart';
import '../../core/constants.dart';

class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // استبدال الأيقونة بملف الـ Lottie
                  Lottie.asset(
                    'images/CryptoWallet.json',
                    height: 160,
                    repeat: true,
                    animate: true,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "FlashPay",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "نظام إدارة الحوالات المالية",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  _buildTextField(
                    label: "البريد الإلكتروني *",
                    hint: "example@flashpay.com",
                    icon: Icons.email_outlined,
                    controller: authController.loginEmailController,
                  ),
                  const SizedBox(height: 16),

                  Obx(() => _buildTextField(
                        label: "كلمة المرور *",
                        hint: "أدخل كلمة المرور",
                        icon: Icons.lock_outline,
                        controller: authController.loginPasswordController,
                        isPassword: true,
                        isObscured: authController.isLoginPasswordHidden.value,
                        onTogglePassword: authController.toggleLoginPassword,
                      )),
                  const SizedBox(height: 32),

                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: ElevatedButton(
                      onPressed: () => authController.login(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      child: Obx(() => authController.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "تسجيل الدخول",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            )),
                    ),
                  ),
                  const SizedBox(height: 24),

                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "نسيت كلمة المرور؟",
                      style: TextStyle(color: AppColors.primaryGradient.colors.first),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("ليس لديك حساب؟"),
                      TextButton(
                        onPressed: () => Get.toNamed('/register'),
                        child: Text("إنشاء حساب", style: TextStyle(color: AppColors.primaryGradient.colors.first)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool isObscured = false,
    VoidCallback? onTogglePassword,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isObscured,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            suffixIcon: Icon(icon, color: AppColors.primaryGradient.colors.first),
            prefixIcon: isPassword
                ? IconButton(
                    icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
                    onPressed: onTogglePassword,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: AppColors.primaryGradient.colors.first),
            ),
          ),
        ),
      ],
    );
  }
}