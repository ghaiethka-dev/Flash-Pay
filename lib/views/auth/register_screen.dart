import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants.dart';

class RegisterScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    // جلب الدول والمدن عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authController.countries.isEmpty) {
        authController.fetchCountriesAndCities();
      }
    });

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,
                color: isDark ? Colors.white : Colors.black87),
            onPressed: () => Get.back(),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: context.theme.cardColor,
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: isDark
                    ? []
                    : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset('images/CryptoWallet.json',
                      height: 160, repeat: true, animate: true),
                  const SizedBox(height: 16),
                  Text(
                    "حساب جديد",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "أنشئ حسابك للبدء في تحويل الأموال",
                    style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.grey),
                  ),
                  const SizedBox(height: 32),

                  _buildTextField(
                    context: context,
                    label: "الاسم الكامل *",
                    hint: "أدخل اسمك الثلاثي",
                    icon: Icons.person_outline,
                    controller: authController.fullNameController,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    context: context,
                    label: "البريد الإلكتروني *",
                    hint: "مثال: email@domain.com",
                    icon: Icons.email_outlined,
                    controller: authController.registerEmailController,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    context: context,
                    label: "رقم الهاتف *",
                    hint: "مثال: 0591234567",
                    icon: Icons.phone_outlined,
                    controller: authController.registerPhoneController,
                  ),
                  const SizedBox(height: 16),

                  // ✅ قوائم الدولة والمدينة — تُجلب من الـ API
                  Obx(() {
                    if (authController.isLoadingCountries.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return Row(
                      children: [
                        // قائمة الدول
                        Expanded(
                          child: Obx(() => _buildApiDropdown<int>(
                            context: context,
                            label: "البلد *",
                            hint: "اختر البلد",
                            icon: Icons.public,
                            value: authController.selectedCountryId.value,
                            items: authController.countries
                                .map((c) => DropdownMenuItem<int>(
                              value: c['id'] as int,
                              child: Text(c['name'] as String,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87)),
                            ))
                                .toList(),
                            onChanged: (val) {
                              if (val == null) return;
                              final country = authController.countries
                                  .firstWhere((c) => c['id'] == val);
                              authController.changeCountry(
                                  val, country['name'] as String);
                            },
                          )),
                        ),
                        const SizedBox(width: 16),
                        // قائمة المدن — تتصفى حسب الدولة المختارة
                        Expanded(
                          child: Obx(() => _buildApiDropdown<int>(
                            context: context,
                            label: "المدينة *",
                            hint: "اختر المدينة",
                            icon: Icons.location_city,
                            value: authController.selectedCityId.value,
                            items: authController.availableCities
                                .map((c) => DropdownMenuItem<int>(
                              value: c['id'] as int,
                              child: Text(c['name'] as String,
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87)),
                            ))
                                .toList(),
                            onChanged: (val) {
                              if (val == null) return;
                              final city = authController.availableCities
                                  .firstWhere((c) => c['id'] == val);
                              authController.changeCity(
                                  val, city['name'] as String);
                            },
                          )),
                        ),
                      ],
                    );
                  }),
                  const SizedBox(height: 16),

                  Obx(() => _buildTextField(
                    context: context,
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
                    context: context,
                    label: "تأكيد كلمة المرور *",
                    hint: "أعد إدخال كلمة المرور",
                    icon: Icons.lock_reset,
                    controller:
                    authController.confirmRegisterPasswordController,
                    isPassword: true,
                    isObscured:
                    authController.isConfirmRegisterPasswordHidden.value,
                    onTogglePassword:
                    authController.toggleConfirmRegisterPassword,
                  )),
                  const SizedBox(height: 32),

                  // رفع صورة الهوية
                  Obx(() {
                    final img = authController.idCardImage.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'صورة الهوية *',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: authController.pickIdCardImage,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: double.infinity,
                            height: img != null ? 160 : 100,
                            decoration: BoxDecoration(
                              color: img != null
                                  ? Colors.transparent
                                  : (isDark
                                  ? context.theme.scaffoldBackgroundColor
                                  : Colors.grey.shade50),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: img != null
                                    ? AppColors.primaryGradient.colors.first
                                    : context.theme.dividerColor,
                                width: img != null ? 2 : 1.5,
                              ),
                            ),
                            child: img != null
                                ? Stack(
                              fit: StackFit.expand,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(img, fit: BoxFit.cover),
                                ),
                                Positioned(
                                  top: 8,
                                  left: 8,
                                  child: GestureDetector(
                                    onTap: () => authController
                                        .idCardImage.value = null,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close,
                                          color: Colors.white, size: 16),
                                    ),
                                  ),
                                ),
                              ],
                            )
                                : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined,
                                    size: 36,
                                    color: isDark
                                        ? Colors.white54
                                        : AppColors
                                        .primaryGradient.colors.first),
                                const SizedBox(height: 8),
                                Text(
                                  'اضغط لرفع صورة الهوية',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark
                                        ? Colors.white70
                                        : AppColors
                                        .primaryGradient.colors.first,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'صورة واضحة للهوية الشخصية',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? Colors.white38
                                          : Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }),

                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ElevatedButton(
                      onPressed: () => authController.register(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                      ),
                      child: Obx(() => authController.isLoading.value
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                        "إنشاء حساب",
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      )),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "لديك حساب بالفعل ؟",
                        style: TextStyle(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.grey),
                      ),
                      TextButton(
                        onPressed: () => Get.back(),
                        child: Text(
                          "تسجيل الدخول",
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryGradient.colors.first),
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
        Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isObscured,
          style: TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor:
            isDark ? context.theme.scaffoldBackgroundColor : Colors.white,
            hintText: hint,
            hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.grey.shade400,
                fontSize: 13),
            suffixIcon:
            Icon(icon, color: AppColors.primaryGradient.colors.first),
            prefixIcon: isPassword
                ? IconButton(
              icon: Icon(
                  isObscured ? Icons.visibility_off : Icons.visibility,
                  color: isDark ? Colors.white54 : Colors.grey),
              onPressed: onTogglePassword,
            )
                : null,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: context.theme.dividerColor)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: context.theme.dividerColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                    color: AppColors.primaryGradient.colors.first, width: 1.5)),
          ),
        ),
      ],
    );
  }

  // Dropdown يعمل بأي نوع T (int للـ IDs)
  Widget _buildApiDropdown<T>({
    required BuildContext context,
    required String label,
    required String hint,
    required IconData icon,
    required T? value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87)),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          isExpanded: true,
          dropdownColor: context.theme.cardColor,
          decoration: InputDecoration(
            filled: true,
            fillColor:
            isDark ? context.theme.scaffoldBackgroundColor : Colors.white,
            hintText: hint,
            hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.grey.shade400,
                fontSize: 13),
            suffixIcon:
            Icon(icon, color: AppColors.primaryGradient.colors.first),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: context.theme.dividerColor)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(color: context.theme.dividerColor)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
                borderSide: BorderSide(
                    color: AppColors.primaryGradient.colors.first, width: 1.5)),
          ),
          icon: Icon(Icons.arrow_drop_down,
              color: isDark ? Colors.white54 : Colors.grey),
          items: items,
          onChanged: onChanged,
        ),
      ],
    );
  }
}