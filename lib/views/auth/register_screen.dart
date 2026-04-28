import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants.dart';

class RegisterScreen extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
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
                    label: "الاسم الكامل ",
                    hint: "أدخل اسمك الثلاثي",
                    icon: Icons.person_outline,
                    controller: authController.fullNameController,
                  ),
                  const SizedBox(height: 16),

                  _buildTextField(
                    context: context,
                    label: "البريد الإلكتروني ",
                    hint: "مثال: email@domain.com",
                    icon: Icons.email_outlined,
                    controller: authController.registerEmailController,
                  ),
                  const SizedBox(height: 16),

                  // ✅ حقل رقم الهاتف مع كود الدولة
                  _buildPhoneField(context, isDark),
                  const SizedBox(height: 16),

                  // قوائم الدولة والمدينة
                  Obx(() {
                    if (authController.isLoadingCountries.value) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return Row(
                      children: [
                        Expanded(
                          child: Obx(() => _buildApiDropdown<int>(
                            context: context,
                            label: "البلد ",
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
                        Expanded(
                          child: Obx(() => _buildApiDropdown<int>(
                            context: context,
                            label: "المدينة ",
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
                    label: "كلمة المرور ",
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
                    label: "تأكيد كلمة المرور ",
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

                  // ✅ قسم صور الهوية الثلاث
                  _buildIdImagesSection(context, isDark),

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

  // ✅ حقل الهاتف الدولي
  Widget _buildPhoneField(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'رقم الهاتف ',
          style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87),
        ),
        const SizedBox(height: 8),
        Directionality(
          // IntlPhoneField يعمل بـ LTR دائماً لأن الأرقام LTR
          textDirection: TextDirection.ltr,
          child: IntlPhoneField(
            controller: authController.registerPhoneController,
            initialCountryCode: 'SY',
            keyboardType: TextInputType.phone,
            style: TextStyle(color: isDark ? Colors.white : Colors.black87),
            dropdownTextStyle:
            TextStyle(color: isDark ? Colors.white : Colors.black87),
            dropdownIcon: Icon(Icons.arrow_drop_down,
                color: isDark ? Colors.white54 : Colors.grey),
            decoration: InputDecoration(
              hintText: '912 345 678',
              hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : Colors.grey.shade400,
                  fontSize: 13),
              filled: true,
              fillColor:
              isDark ? context.theme.scaffoldBackgroundColor : Colors.white,
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
                      color: AppColors.primaryGradient.colors.first,
                      width: 1.5)),
              errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide:
                  const BorderSide(color: Colors.red, width: 1.5)),
            ),
            // ✅ نحفظ الرقم الكامل (كود الدولة + الرقم) في الكنترولر
            onChanged: (phone) {
              authController.setRegisterPhone(phone.completeNumber);
            },
            onCountryChanged: (country) {
              // إعادة حساب الرقم الكامل عند تغيير الدولة
              final current = authController.registerPhoneController.text;
              if (current.isNotEmpty) {
                authController
                    .setRegisterPhone('+${country.dialCode}$current');
              }
            },
          ),
        ),
      ],
    );
  }

  // ✅ قسم صور الهوية الثلاث
  Widget _buildIdImagesSection(BuildContext context, bool isDark) {
    return Obx(() {
      final images = authController.idCardImages;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.badge_outlined,
                  size: 20,
                  color: isDark
                      ? Colors.white70
                      : AppColors.primaryGradient.colors.first),
              const SizedBox(width: 8),
              Text(
                'صور الهوية ',
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'يرجى رفع الصور الثلاث للتحقق من هويتك',
            style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white38 : Colors.grey.shade500),
          ),
          const SizedBox(height: 16),

          // الصورة الأولى — صورة شخصية مع الهوية (عرض كامل)
          _buildSingleImagePicker(
            context: context,
            isDark: isDark,
            index: 0,
            image: images[0],
            heightIfEmpty: 120,
          ),
          const SizedBox(height: 12),

          // الصورتان الثانية والثالثة — جنباً إلى جنب
          Row(
            children: [
              Expanded(
                child: _buildSingleImagePicker(
                  context: context,
                  isDark: isDark,
                  index: 1,
                  image: images[1],
                  heightIfEmpty: 110,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSingleImagePicker(
                  context: context,
                  isDark: isDark,
                  index: 2,
                  image: images[2],
                  heightIfEmpty: 110,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // مؤشر الاكتمال
          _buildImagesProgressIndicator(isDark),
        ],
      );
    });
  }

  Widget _buildSingleImagePicker({
    required BuildContext context,
    required bool isDark,
    required int index,
    required dynamic image, // File?
    required double heightIfEmpty,
  }) {
    final accentColor = AppColors.primaryGradient.colors.first;
    final label = authController.imageLabel(index);
    final icon = authController.imageIcon(index);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black54),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () => authController.pickIdCardImage(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: image != null ? (index == 0 ? 160 : 120) : heightIfEmpty,
            decoration: BoxDecoration(
              color: image != null
                  ? Colors.transparent
                  : (isDark
                  ? context.theme.scaffoldBackgroundColor
                  : Colors.grey.shade50),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: image != null
                    ? accentColor
                    : context.theme.dividerColor,
                width: image != null ? 2 : 1.5,
              ),
            ),
            child: image != null
                ? Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(image, fit: BoxFit.cover),
                ),
                // زر الحذف
                Positioned(
                  top: 6,
                  left: 6,
                  child: GestureDetector(
                    onTap: () => authController.removeIdCardImage(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close,
                          color: Colors.white, size: 14),
                    ),
                  ),
                ),
                // زر التغيير
                Positioned(
                  bottom: 6,
                  right: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text('تغيير',
                            style: TextStyle(
                                color: Colors.white, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ],
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    size: index == 0 ? 36 : 28,
                    color: isDark ? Colors.white38 : accentColor),
                const SizedBox(height: 6),
                Text(
                  'اضغط لرفع الصورة',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : accentColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // مؤشر الاكتمال (كم صورة تم رفعها)
  Widget _buildImagesProgressIndicator(bool isDark) {
    final uploaded = authController.idCardImages
        .where((img) => img != null)
        .length;
    final color = uploaded == 3
        ? Colors.green
        : AppColors.primaryGradient.colors.first;

    return Row(
      children: [
        ...List.generate(3, (i) {
          final done = authController.idCardImages[i] != null;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(left: i < 2 ? 6 : 0),
              height: 4,
              decoration: BoxDecoration(
                color: done ? color : (isDark ? Colors.white12 : Colors.grey.shade200),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
        const SizedBox(width: 10),
        Text(
          '$uploaded / 3',
          style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: uploaded == 3 ? Colors.green : (isDark ? Colors.white54 : Colors.grey)),
        ),
      ],
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