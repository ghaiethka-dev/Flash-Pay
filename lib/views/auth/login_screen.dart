import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../core/constants.dart';

class LoginScreen extends StatelessWidget {
  final AuthController authController = Get.put(AuthController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: context.theme.scaffoldBackgroundColor,
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

                  // ── لوغو التطبيق المخصص ──────────────────────────────
                  const _FlashPayLogo(),

                  const SizedBox(height: 24),

                  // ── اسم التطبيق ───────────────────────────────────────
                  const _FlashPayBrand(),

                  const SizedBox(height: 8),

                  Text(
                    'نظام إدارة الحوالات المالية',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white54 : Colors.grey.shade500,
                      fontFamily: 'Cairo',
                    ),
                  ),

                  const SizedBox(height: 36),

                  _buildTextField(
                    context: context,
                    label: 'البريد الإلكتروني',
                    hint: 'example@flashpay.com',
                    icon: Icons.email_outlined,
                    controller: authController.loginEmailController,
                  ),
                  const SizedBox(height: 16),

                  Obx(() => _buildTextField(
                    context: context,
                    label: 'كلمة المرور',
                    hint: 'أدخل كلمة المرور',
                    icon: Icons.lock_outline,
                    controller: authController.loginPasswordController,
                    isPassword: true,
                    isObscured: authController.isLoginPasswordHidden.value,
                    onTogglePassword: authController.toggleLoginPassword,
                  )),

                  const SizedBox(height: 32),

                  // ── زر تسجيل الدخول ──────────────────────────────────
                  Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(14.0),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFA64D04).withOpacity(0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () => authController.login(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14.0)),
                      ),
                      child: Obx(() => authController.isLoading.value
                          ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                          : const Text(
                        'تسجيل الدخول',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      )),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'نسيت كلمة المرور؟',
                      style: TextStyle(
                          color: AppColors.primaryGradient.colors.first),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'ليس لديك حساب؟',
                        style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black87),
                      ),
                      TextButton(
                        onPressed: () => Get.toNamed('/register'),
                        child: Text(
                          'إنشاء حساب',
                          style: TextStyle(
                            color: AppColors.primaryGradient.colors.first,
                            fontWeight: FontWeight.bold,
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
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isObscured,
          style:
          TextStyle(color: isDark ? Colors.white : Colors.black87),
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark
                ? context.theme.scaffoldBackgroundColor
                : Colors.white,
            hintText: hint,
            hintStyle: TextStyle(
              color: isDark ? Colors.white38 : Colors.grey.shade400,
              fontSize: 13,
            ),
            suffixIcon: Icon(icon,
                color: AppColors.primaryGradient.colors.first),
            prefixIcon: isPassword
                ? IconButton(
              icon: Icon(
                isObscured ? Icons.visibility_off : Icons.visibility,
                color: isDark ? Colors.white54 : Colors.grey,
              ),
              onPressed: onTogglePassword,
            )
                : null,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide:
              BorderSide(color: context.theme.dividerColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide:
              BorderSide(color: context.theme.dividerColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
              borderSide: BorderSide(
                color: AppColors.primaryGradient.colors.first,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
//  لوغو FlashPay المرسوم بـ Flutter (بدون assets)
// =============================================================================
class _FlashPayLogo extends StatelessWidget {
  const _FlashPayLogo();

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark;

    return Container(
      width: 110,
      height: 110,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFCC6010), Color(0xFFA64D04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA64D04).withOpacity(0.40),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: const Color(0xFFECB651).withOpacity(0.20),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // دائرة داخلية شفافة للعمق
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.10),
            ),
          ),
          // أيقونة البرق ⚡
          const Icon(
            Icons.bolt_rounded,
            size: 58,
            color: Color(0xFFFFF0CC),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
//  اسم FlashPay بخط ذهبي متدرج أنيق
// =============================================================================
class _FlashPayBrand extends StatelessWidget {
  const _FlashPayBrand();

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark;

    return Column(
      children: [
        // الاسم بتدرج ذهبي في الدارك، وبرتقالي في الفاتح
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: isDark
                ? const [Color(0xFFECB651), Color(0xFFF5D27A), Color(0xFFECB651)]
                : const [Color(0xFFCC6010), Color(0xFFA64D04)],
            stops: isDark ? const [0.0, 0.5, 1.0] : null,
          ).createShader(bounds),
          child: const Text(
            'FlashPay',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Colors.white, // يُستبدل بالـ shader
              letterSpacing: 1.2,
              height: 1.0,
            ),
          ),
        ),

        const SizedBox(height: 6),

        // خط تحت الاسم
        Container(
          width: 50,
          height: 2.5,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.transparent, Color(0xFFA64D04), Colors.transparent],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}