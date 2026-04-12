import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import 'package:flashpay/controllers/profile_controller.dart';
import 'package:flashpay/core/constants.dart';

import '../../dashboards/user_dashboards/widgets/fp_theme.dart';

class ProfileInfoCard extends StatelessWidget {
  final ProfileController controller;

  const ProfileInfoCard({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // السحر هنا: استخدام لون البطاقة من الثيم الحالي
    final cardColor = context.theme.cardColor;

    return Container(
      decoration: BoxDecoration(
        color: cardColor, // 👈 يتغير حسب الثيم
        borderRadius: BorderRadius.circular(28),
        boxShadow: FPShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            decoration: const BoxDecoration(
              gradient: FPGradients.domestic,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Row(
              children: const [
                Icon(Icons.manage_accounts_rounded, color: Colors.white, size: 22),
                SizedBox(width: 10),
                Text('البيانات الشخصية', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w800, letterSpacing: 0.2)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _PremiumField(label: 'الاسم الكامل', icon: Icons.person_outline_rounded, controller: controller.nameController)
                    .animate().fadeIn(delay: 100.ms, duration: 400.ms).slideY(begin: 0.08, curve: Curves.easeOut),
                const SizedBox(height: 18),
                _PremiumField(label: 'البريد الإلكتروني', icon: Icons.email_outlined, controller: controller.emailController, keyboardType: TextInputType.emailAddress)
                    .animate().fadeIn(delay: 180.ms, duration: 400.ms).slideY(begin: 0.08, curve: Curves.easeOut),
                const SizedBox(height: 18),
                _PremiumField(label: 'رقم الهاتف', icon: Icons.phone_android_rounded, controller: controller.phoneController, keyboardType: TextInputType.phone)
                    .animate().fadeIn(delay: 260.ms, duration: 400.ms).slideY(begin: 0.08, curve: Curves.easeOut),
                const SizedBox(height: 18),
                _PremiumField(label: 'كلمة المرور الجديدة (اختياري)', hint: 'اتركه فارغاً إذا لم ترغب بتغييره', icon: Icons.lock_outline_rounded, controller: controller.passwordController, isPassword: true)
                    .animate().fadeIn(delay: 340.ms, duration: 400.ms).slideY(begin: 0.08, curve: Curves.easeOut),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity, height: 52,
                  child: ElevatedButton(
                    onPressed: () => controller.updateProfile(),
                    style: ElevatedButton.styleFrom(backgroundColor: FPColors.primary, foregroundColor: Colors.white, elevation: 0, shadowColor: FPColors.primary.withOpacity(0.40), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: Obx(
                      () => controller.isSaving.value
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                          : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.save_alt_rounded, size: 20), SizedBox(width: 8), Text('حفظ التعديلات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.3))]),
                    ),
                  ),
                ).animate().fadeIn(delay: 420.ms, duration: 450.ms).slideY(begin: 0.10, curve: Curves.easeOut),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumField extends StatefulWidget {
  final String label;
  final String? hint;
  final IconData icon;
  final TextEditingController controller;
  final bool isPassword;
  final TextInputType keyboardType;

  const _PremiumField({required this.label, required this.icon, required this.controller, this.hint, this.isPassword = false, this.keyboardType = TextInputType.text});

  @override
  State<_PremiumField> createState() => _PremiumFieldState();
}

class _PremiumFieldState extends State<_PremiumField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() => _focused = _focusNode.hasFocus));
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color focusColour = AppColors.primaryGradient.colors.first;
    // 👈 معرفة حالة الثيم
    final bool isDark = context.theme.brightness == Brightness.dark; 
    final Color textColor = isDark ? Colors.white70 : FPColors.textMid;
    final Color fieldBg = isDark ? context.theme.scaffoldBackgroundColor : const Color(0xFFF7F8FA);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 200),
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _focused ? focusColour : textColor),
          child: Text(widget.label),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _focused ? focusColour.withOpacity(isDark ? 0.15 : 0.04) : fieldBg, // 👈 لون حقل الإدخال يتغير
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _focused ? focusColour.withOpacity(0.70) : Colors.transparent, width: 1.5),
            boxShadow: _focused ? [BoxShadow(color: focusColour.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 4))] : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: widget.isPassword,
            keyboardType: widget.keyboardType,
            style: TextStyle(color: context.textTheme.bodyLarge?.color), // 👈 لون نص الكتابة
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : FPColors.textLight),
              prefixIcon: Icon(widget.icon, color: _focused ? focusColour : textColor, size: 20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              filled: false, border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}