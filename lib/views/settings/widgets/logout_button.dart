import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flashpay/controllers/auth_controller.dart';
import 'package:flashpay/core/constants.dart';
import '../../dashboards/user_dashboards/widgets/fp_theme.dart';

class LogoutButton extends StatefulWidget {
  final AuthController authController;
  const LogoutButton({Key? key, required this.authController}) : super(key: key);
  @override
  State<LogoutButton> createState() => _LogoutButtonState();
}

class _LogoutButtonState extends State<LogoutButton> with SingleTickerProviderStateMixin {
  late final AnimationController _scaleAc = AnimationController(vsync: this, duration: const Duration(milliseconds: 100), reverseDuration: const Duration(milliseconds: 180), lowerBound: 0.0, upperBound: 0.03);

  @override
  void dispose() { _scaleAc.dispose(); super.dispose(); }
  void _onTapDown(_) => _scaleAc.forward();
  void _onTapUp(_) { _scaleAc.reverse(); _showConfirmSheet(context); }
  void _onTapCancel() => _scaleAc.reverse();

  void _showConfirmSheet(BuildContext context) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent, isScrollControlled: true,
      builder: (_) => _LogoutConfirmSheet(
        onConfirm: () { Get.back(); widget.authController.logout(); },
        onCancel: () => Get.back(),
        cancelColor: AppColors.primaryGradient.colors.first,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown, onTapUp: _onTapUp, onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAc, builder: (_, child) => Transform.scale(scale: 1.0 - _scaleAc.value, child: child),
        child: Container(
          width: double.infinity, height: 56,
          decoration: BoxDecoration(color: Colors.red.withOpacity(0.06), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.red.withOpacity(0.35), width: 1.5)),
          child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.logout_rounded, color: Colors.red, size: 22), SizedBox(width: 10), Text('تسجيل الخروج', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.red, letterSpacing: 0.3))]),
        ),
      ),
    );
  }
}

class _LogoutConfirmSheet extends StatelessWidget {
  final VoidCallback onConfirm; final VoidCallback onCancel; final Color cancelColor;
  const _LogoutConfirmSheet({required this.onConfirm, required this.onCancel, required this.cancelColor});

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark; // 👈

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.theme.cardColor, // 👈 خلفية النافذة
        borderRadius: const BorderRadius.all(Radius.circular(28)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: context.theme.dividerColor, borderRadius: BorderRadius.circular(2))), // 👈 مقبض السحب
            const SizedBox(height: 24),
            Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.red.withOpacity(0.08), shape: BoxShape.circle), child: const Icon(Icons.logout_rounded, color: Colors.red, size: 34)),
            const SizedBox(height: 20),
            const Text('تسجيل الخروج', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.red)),
            const SizedBox(height: 10),
            Text(
              'هل أنت متأكد أنك تريد تسجيل الخروج من حسابك؟',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : FPColors.textMid, height: 1.5, fontWeight: FontWeight.w500), // 👈
            ),
            const SizedBox(height: 28),
            SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: onConfirm, style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: const Text('نعم، خروج', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)))),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, height: 52, child: OutlinedButton(onPressed: onCancel, style: OutlinedButton.styleFrom(side: BorderSide(color: cancelColor.withOpacity(0.40), width: 1.5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))), child: Text('إلغاء', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cancelColor)))),
          ],
        ),
      ),
    );
  }
}