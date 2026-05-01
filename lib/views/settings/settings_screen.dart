// =============================================================================
//  settings_screen.dart
//  Flash Pay — Settings Screen
//  Target path:  lib/views/settings/settings_screen.dart
// =============================================================================

import 'package:flashpay/controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flashpay/controllers/auth_controller.dart';

import '../dashboards/user_dashboards/widgets/fp_theme.dart';
import 'widgets/animated_toggle_tile.dart';
import 'widgets/custom_settings_tile.dart';
import 'widgets/logout_button.dart';
import 'widgets/settings_section_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  Future<void> _openTelegram() async {
    final appUri = Uri.parse('tg://resolve?domain=Majdi_exchange');
    final webUri = Uri.parse('https://t.me/Majdi_exchange');

    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri);
    } else {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.put(AuthController());
    final ThemeController themeController = Get.put(ThemeController());
    final bool isDark = context.theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: context.theme.scaffoldBackgroundColor,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: const _SettingsPageHeader()
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.06, curve: Curves.easeOut),
              ),
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
                        CustomSettingsTile(
                          icon: Icons.language_rounded,
                          iconColor: FPColors.green,
                          title: 'اللغة',
                          subtitle: 'العربية',
                          onTap: () {},
                        ),
                        CustomSettingsTile(
                          icon: Icons.currency_exchange_rounded,
                          iconColor: FPColors.primary,
                          title: 'العملة الافتراضية',
                          subtitle: 'دولار أمريكي — USD',
                          onTap: () {},
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
                        // ── زر تيليغرام المخصص ──
                        _TelegramSupportTile(onTap: _openTelegram),

                        CustomSettingsTile(
                          icon: Icons.info_outline_rounded,
                          iconColor: FPColors.textMid,
                          title: 'عن التطبيق',
                          subtitle: 'Flash Pay — الإصدار 1.0.0',
                          onTap: () {},
                          showDivider: false,
                        ),
                      ],
                    )
                        .animate()
                        .fadeIn(delay: 420.ms, duration: 500.ms)
                        .slideY(begin: 0.10, curve: Curves.easeOut),

                    const SizedBox(height: 32),

                    LogoutButton(authController: authController)
                        .animate()
                        .fadeIn(delay: 520.ms, duration: 500.ms)
                        .slideY(begin: 0.10, curve: Curves.easeOut),

                    const SizedBox(height: 12),

                    Center(
                      child: Text(
                        'Flash Pay © 2026',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : FPColors.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
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
//  Telegram Support Tile — تصميم مميز بلون تيليغرام
// ─────────────────────────────────────────────────────────────────────────────
class _TelegramSupportTile extends StatelessWidget {
  final VoidCallback onTap;
  const _TelegramSupportTile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            // أيقونة تيليغرام
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1E96D0), Color(0xFF2AABEE)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2AABEE).withOpacity(0.30),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'تواصل مع الدعم عبر تيليغرام',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@Majdi_exchange · متاح 24/7',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12,
                      color: isDark ? Colors.white54 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 14,
              color: isDark ? Colors.white38 : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Settings page header
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.settings_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الإعدادات',
                    style: TextStyle(
                      color: Colors.white, fontSize: 22,
                      fontWeight: FontWeight.w800, letterSpacing: 0.4,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'تحكم كامل في حسابك وتفضيلاتك',
                    style: TextStyle(
                      color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500,
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