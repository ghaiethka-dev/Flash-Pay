import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:flashpay/core/constants.dart';
import 'package:get/get.dart';

class AgentBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChange;

  const AgentBottomNav({
    Key? key,
    required this.selectedIndex,
    required this.onTabChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color brand = AppColors.primaryGradient.colors.first;
    final bool isDark = context.theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: isDark
            ? []
            : [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 28,
            spreadRadius: 0,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: GNav(
            rippleColor: brand.withOpacity(0.12),
            hoverColor: brand.withOpacity(0.06),
            activeColor: brand,
            tabBackgroundColor: brand.withOpacity(0.10),
            color: isDark ? Colors.white54 : const Color(0xFF6B7280),
            iconSize: 24,
            gap: 6,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            duration: const Duration(milliseconds: 350),
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            tabs: [
              // تاب 0: إرسال حوالة (بدل "الواردة")
              GButton(
                icon: Icons.send_rounded,
                text: 'إرسال',
                textStyle: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: brand),
              ),
              // تاب 1: التحويل البنكي
              GButton(
                icon: Icons.account_balance_rounded,
                text: 'بنكي',
                textStyle: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: brand),
              ),
              // تاب 2: الإعدادات
              GButton(
                icon: Icons.settings_rounded,
                text: 'الإعدادات',
                textStyle: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: brand),
              ),
              // تاب 3: الحساب
              GButton(
                icon: Icons.person_rounded,
                text: 'الحساب',
                textStyle: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w700, color: brand),
              ),
            ],
            selectedIndex: selectedIndex,
            onTabChange: onTabChange,
          ),
        ),
      ),
    );
  }
}