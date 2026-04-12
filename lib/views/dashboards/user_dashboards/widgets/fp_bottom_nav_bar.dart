import 'package:flutter/material.dart';
import 'package:get/get.dart'; // 👈 ضروري
import 'package:google_nav_bar/google_nav_bar.dart';
import 'fp_theme.dart';

class FPBottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChange;

  const FPBottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.onTabChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark; // 👈

    return Container(
      decoration: BoxDecoration(
        color: context.theme.cardColor, // 👈 لون يتجاوب مع الثيم
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: isDark ? [] : FPShadows.navBar, // 👈 إخفاء الظل في الدارك مود لجمالية أكبر
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: GNav(
            rippleColor: FPColors.primary.withOpacity(0.12),
            hoverColor: FPColors.primary.withOpacity(0.06),
            activeColor: FPColors.primary,
            tabBackgroundColor: FPColors.primary.withOpacity(0.10),
            color: isDark ? Colors.white54 : FPColors.textMid, // 👈 لون الأيقونات غير النشطة
            iconSize: 24, gap: 6,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            duration: const Duration(milliseconds: 350),
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            tabs: const [
              GButton(icon: Icons.home_rounded, text: 'الرئيسية', textStyle: FPTextStyles.navActive),
              GButton(icon: Icons.notifications_rounded, text: 'الإشعارات', textStyle: FPTextStyles.navActive),
              GButton(icon: Icons.settings_rounded, text: 'الإعدادات', textStyle: FPTextStyles.navActive),
              GButton(icon: Icons.person_rounded, text: 'الحساب', textStyle: FPTextStyles.navActive),
            ],
            selectedIndex: selectedIndex,
            onTabChange: onTabChange,
          ),
        ),
      ),
    );
  }
}