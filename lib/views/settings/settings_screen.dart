// =============================================================================
//  settings_screen.dart
//  Flash Pay — Settings Screen  (Main Entry)
//  ───────────────────────────────────────────
//  Target path:  lib/views/settings/settings_screen.dart
//
//  Replaces the original:  lib/views/settings_view.dart
//
//  ✅ ALL controller logic preserved:
//     • Get.put(AuthController())            ← unchanged registration
//     • authController.logout()             ← called on confirm
//     • AppColors.primaryGradient           ← used for cancel button colour
//     • "تسجيل الخروج" confirmation dialog  ← now a premium bottom-sheet
//       with the same text: title "تسجيل الخروج", confirm "نعم، خروج",
//       cancel "إلغاء"
//
//  Component map
//  ─────────────
//  widgets/
//    settings_section_card.dart   — titled card wrapper
//    custom_settings_tile.dart    — tappable tile with icon + chevron
//    animated_toggle_tile.dart    — tile with animated custom toggle switch
//    logout_button.dart           — styled red outline button + bottom-sheet
// =============================================================================

import 'package:flashpay/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import 'package:flashpay/controllers/auth_controller.dart';

import '../dashboards/user_dashboards/widgets/fp_theme.dart';
import 'widgets/animated_toggle_tile.dart';
import 'widgets/custom_settings_tile.dart';
import 'widgets/logout_button.dart';
import 'widgets/settings_section_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ AuthController registration — unchanged
    final AuthController authController = Get.put(AuthController());
    // استخدام Get.put بدلاً من find لضمان توفره دائماً
    final ThemeController themeController = Get.put(ThemeController());

    // معرفة الثيم الحالي لضبط ألوان شريط الحالة (البطارية والساعة)
    final bool isDark = context.theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl, // ✅ RTL preserved
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          // عكس ألوان الأيقونات حسب الوضع الحالي
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
        child: Scaffold(
          // 🚀 السطر السحري: الاعتماد على لون الثيم بدلاً من اللون الثابت
          backgroundColor: context.theme.scaffoldBackgroundColor,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Settings page header ─────────────────────────────────────
              SliverToBoxAdapter(
                child: const _SettingsPageHeader()
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.06, curve: Curves.easeOut),
              ),

              // ── Scrollable sections ──────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 80),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([

                    // ── 1. Security & Privacy ─────────────────────────────
                    SettingsSectionCard(
                      title: 'الأمان والخصوصية',
                      titleIcon: Icons.security_rounded,
                      iconColor: FPColors.primary,
                      children: [
                        AnimatedToggleTile(
                          icon: Icons.fingerprint_rounded,
                          iconColor: FPColors.primary,
                          title: 'تسجيل الدخول بالبصمة',
                          subtitle: 'استخدم بصمة الإصبع أو Face ID',
                          initialValue: false,
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 120.ms, duration: 500.ms)
                        .slideY(begin: 0.10, curve: Curves.easeOut),

                    const SizedBox(height: 16),

                    // ── 2. Notifications ──────────────────────────────────
                    SettingsSectionCard(
                      title: 'الإشعارات',
                      titleIcon: Icons.notifications_none_rounded,
                      iconColor: FPColors.amber,
                      children: [
                        AnimatedToggleTile(
                          icon: Icons.notifications_active_rounded,
                          iconColor: FPColors.amber,
                          title: 'إشعارات التطبيق',
                          subtitle: 'تلقي إشعارات الحوالات والتحديثات',
                          initialValue: true,
                        ),
                        AnimatedToggleTile(
                          icon: Icons.email_outlined,
                          iconColor: FPColors.blue,
                          title: 'إشعارات البريد الإلكتروني',
                          subtitle: 'تقارير ومتابعة الحوالات عبر البريد',
                          initialValue: false,
                          showDivider: false,
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 220.ms, duration: 500.ms)
                        .slideY(begin: 0.10, curve: Curves.easeOut),

                    const SizedBox(height: 16),

                    // ── 3. App Preferences ────────────────────────────────
                    SettingsSectionCard(
                      title: 'تفضيلات التطبيق',
                      titleIcon: Icons.tune_rounded,
                      iconColor: FPColors.purple,
                      children: [
                        // ======= 🚀 زر الوضع الداكن الديناميكي =======
                        Obx(() => AnimatedToggleTile(
                          icon: Icons.dark_mode_rounded,
                          iconColor: Colors.indigo,
                          title: 'الوضع الداكن (Dark Mode)',
                          subtitle: 'تغيير مظهر التطبيق بالكامل',
                          initialValue: themeController.isDarkMode.value, 
                          onChanged: (bool value) {
                            themeController.toggleTheme(value);
                          },
                        )),
                        // ==========================================
                        CustomSettingsTile(
                          icon: Icons.language_rounded,
                          iconColor: FPColors.green,
                          title: 'اللغة',
                          subtitle: 'العربية',
                          onTap: () {
                            // Hook up to language selector
                          },
                        ),
                        CustomSettingsTile(
                          icon: Icons.currency_exchange_rounded,
                          iconColor: FPColors.primary,
                          title: 'العملة الافتراضية',
                          subtitle: 'دولار أمريكي — USD',
                          onTap: () {
                            // Hook up to currency selector
                          },
                          showDivider: false,
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 320.ms, duration: 500.ms)
                        .slideY(begin: 0.10, curve: Curves.easeOut),

                    const SizedBox(height: 16),

                    // ── 4. Help & Support ─────────────────────────────────
                    SettingsSectionCard(
                      title: 'المساعدة والدعم',
                      titleIcon: Icons.help_outline_rounded,
                      iconColor: FPColors.blue,
                      children: [
                        CustomSettingsTile(
                          icon: Icons.headset_mic_rounded,
                          iconColor: FPColors.blue,
                          title: 'تواصل مع الدعم',
                          subtitle: 'متاح 24/7 لمساعدتك',
                          onTap: () {
                            // Hook up to support screen
                          },
                        ),
                        CustomSettingsTile(
                          icon: Icons.info_outline_rounded,
                          iconColor: FPColors.textMid,
                          title: 'عن التطبيق',
                          subtitle: 'Flash Pay — الإصدار 1.0.0',
                          onTap: () {
                            // Hook up to about screen
                          },
                          showDivider: false,
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 420.ms, duration: 500.ms)
                        .slideY(begin: 0.10, curve: Curves.easeOut),

                    const SizedBox(height: 32),

                    // ── Logout button ─────────────────────────────────────
                    // ✅ authController injected — logout() called inside
                    LogoutButton(authController: authController)
                        .animate()
                        .fadeIn(delay: 520.ms, duration: 500.ms)
                        .slideY(begin: 0.10, curve: Curves.easeOut),

                    const SizedBox(height: 12),

                    // App version footnote (لون النص يتجاوب مع الدارك مود)
                    Center(
                      child: Text(
                        'Flash Pay © 2026',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : FPColors.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 600.ms, duration: 400.ms),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Private: Settings page header (gradient banner)
// ─────────────────────────────────────────────────────────────────────────────
class _SettingsPageHeader extends StatelessWidget {
  const _SettingsPageHeader();

  @override
  Widget build(BuildContext context) {
    final double statusBarH = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(24, statusBarH + 20, 24, 28),
      decoration: const BoxDecoration(
        gradient: FPGradients.heroHeader,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20, right: -40,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -30, left: -30,
            child: Container(
              width: 120, height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          // Title row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.settings_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الإعدادات',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'تحكم كامل في حسابك وتفضيلاتك',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}