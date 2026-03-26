import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart'; // 👈 ضروري
import 'fp_theme.dart';

class NotificationsTab extends StatelessWidget {
  const NotificationsTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark; // 👈

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(color: FPColors.primary.withOpacity(0.08), shape: BoxShape.circle),
            child: const Icon(Icons.notifications_none_rounded, size: 64, color: FPColors.primary),
          ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.65, 0.65), curve: Curves.easeOutBack),

          const SizedBox(height: 24),

          Text(
            'لا توجد إشعارات',
            style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : FPColors.textDark, // 👈
            ),
          ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(begin: 0.10, curve: Curves.easeOut),

          const SizedBox(height: 8),

          Text(
            'ستظهر هنا أحدث التنبيهات والتحديثات',
            style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : FPColors.textMid, // 👈
            ),
          ).animate().fadeIn(delay: 260.ms, duration: 400.ms).slideY(begin: 0.10, curve: Curves.easeOut),
        ],
      ),
    );
  }
}