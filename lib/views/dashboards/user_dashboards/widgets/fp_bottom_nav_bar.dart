import 'package:flutter/material.dart';
import 'package:flashpay/controllers/notification_controller.dart';
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
            tabs: [
              const GButton(icon: Icons.home_rounded, text: 'الرئيسية', textStyle: FPTextStyles.navActive),
              // ✅ أيقونة الإشعارات مع شارة عدد غير المقروء
              GButton(
                icon: Icons.notifications_rounded,
                text: 'الإشعارات',
                textStyle: FPTextStyles.navActive,
                leading: _NotifNavIcon(
                  active: selectedIndex == 1,
                  inactiveColor: isDark ? Colors.white54 : FPColors.textMid,
                  badgeBorder: context.theme.cardColor,
                ),
              ),
              const GButton(icon: Icons.settings_rounded, text: 'الإعدادات', textStyle: FPTextStyles.navActive),
              const GButton(icon: Icons.person_rounded, text: 'الحساب', textStyle: FPTextStyles.navActive),
            ],
            selectedIndex: selectedIndex,
            onTabChange: onTabChange,
          ),
        ),
      ),
    );
  }
}

// ── أيقونة الإشعارات + شارة غير المقروء ──────────────────────────────────────
class _NotifNavIcon extends StatelessWidget {
  final bool active;
  final Color inactiveColor;
  final Color badgeBorder;

  const _NotifNavIcon({
    required this.active,
    required this.inactiveColor,
    required this.badgeBorder,
  });

  @override
  Widget build(BuildContext context) {
    final nc = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : null;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(
          Icons.notifications_rounded,
          size: 24,
          color: active ? FPColors.primary : inactiveColor,
        ),
        if (nc != null)
          Positioned(
            top: -6,
            right: -8,
            child: Obx(() {
              final n = nc.unread.value;
              if (n == 0) return const SizedBox.shrink();
              return Semantics(
                label: '$n إشعارات غير مقروءة',
                child: Container(
                  constraints: const BoxConstraints(minWidth: 17, minHeight: 17),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDC2626),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: badgeBorder, width: 1.5),
                  ),
                  child: Text(
                    n > 9 ? '9+' : '$n',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                ),
              );
            }),
          ),
      ],
    );
  }
}