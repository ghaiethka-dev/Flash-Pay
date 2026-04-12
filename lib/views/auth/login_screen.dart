import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart'; 
import '../../controllers/auth_controller.dart';
import '../../core/constants.dart';

class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    // 👈 معرفة الثيم الحالي لتحديد الألوان بذكاء
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        // 🚀 السطر السحري للخلفية:
        backgroundColor: context.theme.scaffoldBackgroundColor,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: context.theme.cardColor, // 👈 لون البطاقة يتجاوب مع الثيم
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: isDark 
                    ? [] // إخفاء الظل في الدارك مود لجمالية أكبر
                    : [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'images/CryptoWallet.json',
                    height: 160,
                    repeat: true,
                    animate: true,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "FlashPay",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87), // 👈
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "نظام إدارة الحوالات المالية",
                    style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.grey), // 👈
                  ),
                  const SizedBox(height: 32),

                  _buildTextField(
                    context: context, // نمرر الـ context لمعرفة الثيم بداخل الدالة
                    label: "البريد الإلكتروني *",
                    hint: "example@flashpay.com",
                    icon: Icons.email_outlined,
                    controller: authController.loginEmailController,
                  ),
                  const SizedBox(height: 16),

                  Obx(() => _buildTextField(
                        context: context,
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
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ElevatedButton(
                      onPressed: () => authController.login(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
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
                      Text("ليس لديك حساب؟", style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)), // 👈
                      TextButton(
                        onPressed: () => Get.toNamed('/register'),
                        child: Text("إنشاء حساب", style: TextStyle(color: AppColors.primaryGradient.colors.first, fontWeight: FontWeight.bold)),
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
    required BuildContext context,
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool isObscured = false,
    VoidCallback? onTogglePassword,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isObscured,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87), // 👈 لون نص الإدخال
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? context.theme.scaffoldBackgroundColor : Colors.white, // 👈 خلفية الحقل
            hintText: hint,
            hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade400, fontSize: 13),
            suffixIcon: Icon(icon, color: AppColors.primaryGradient.colors.first),
            prefixIcon: isPassword
                ? IconButton(
                    icon: Icon(isObscured ? Icons.visibility_off : Icons.visibility, color: isDark ? Colors.white54 : Colors.grey),
                    onPressed: onTogglePassword,
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: context.theme.dividerColor), // 👈
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: context.theme.dividerColor), // 👈
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(color: AppColors.primaryGradient.colors.first, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}