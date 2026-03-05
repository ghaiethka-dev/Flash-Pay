import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart'; // استيراد مكتبة Lottie
import '../../controllers/auth_controller.dart';
import '../../core/constants.dart';

class RegisterScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Get.back(),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5)),
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
                    "حساب جديد",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "أنشئ حسابك للبدء في تحويل الأموال",
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  _buildTextField(
                    label: "الاسم الكامل *",
                    hint: "أدخل اسمك الثلاثي",
                    icon: Icons.person_outline,
                    controller: authController.fullNameController,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    label: "البريد الإلكتروني *",
                    hint: "مثال: email@domain.com",
                    icon: Icons.email_outlined,
                    controller: authController.registerEmailController,
                  ),
                  const SizedBox(height: 16),
                  
                  _buildTextField(
                    label: "رقم الهاتف *",
                    hint: "مثال: 0591234567",
                    icon: Icons.phone_outlined,
                    controller: authController.registerPhoneController,
                  ),
                  const SizedBox(height: 16),

                  // صف البلد والمدينة باستخدام Dropdowns المضافة سابقاً
                  Row(
                    children: [
                      Expanded(
                        child: Obx(() => _buildDropdownField(
                          label: "البلد *",
                          hint: "اختر البلد",
                          icon: Icons.public,
                          value: authController.selectedCountry.value,
                          items: authController.countriesAndCities.keys.toList(),
                          onChanged: (val) => authController.changeCountry(val),
                        )),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Obx(() => _buildDropdownField(
                          label: "المدينة *",
                          hint: "اختر المدينة",
                          icon: Icons.location_city,
                          value: authController.selectedCity.value,
                          items: authController.availableCities,
                          onChanged: (val) => authController.selectedCity.value = val,
                        )),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Obx(() => _buildTextField(
                    label: "كلمة المرور *",
                    hint: "أدخل كلمة مرور قوية",
                    icon: Icons.lock_outline,
                    controller: authController.registerPasswordController,
                    isPassword: true,
                    isObscured: authController.isRegisterPasswordHidden.value,
                    onTogglePassword: authController.toggleRegisterPassword,
                  )),
                  const SizedBox(height: 16),

                  Obx(() => _buildTextField(
                    label: "تأكيد كلمة المرور *",
                    hint: "أعد إدخال كلمة المرور",
                    icon: Icons.lock_reset,
                    controller: authController.confirmRegisterPasswordController,
                    isPassword: true,
                    isObscured: authController.isConfirmRegisterPasswordHidden.value,
                    onTogglePassword: authController.toggleConfirmRegisterPassword,
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
                      onPressed: () => authController.register(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                      ),
                      child: Obx(() => authController.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              "إنشاء حساب",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            )),
                    ),
                  ),

                  // زر الرجوع لتسجيل الدخول تمت إضافته في النهاية
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "لديك حساب بالفعل ؟",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          "تسجيل الدخول",
                          style: TextStyle(
                            fontSize: 14, 
                            fontWeight: FontWeight.bold, 
                            color: AppColors.primaryGradient.colors.first
                          ),
                        ),
                      ),
                    ],
                  ),
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
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: AppColors.primaryGradient.colors.first)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            suffixIcon: Icon(icon, color: AppColors.primaryGradient.colors.first),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0), borderSide: BorderSide(color: AppColors.primaryGradient.colors.first)),
          ),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, style: const TextStyle(fontSize: 14)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}