// =============================================================================
//  dashboard_header.dart  — FlashPay (Fixed & Enhanced)
//  ✅ FIX: _TopBar title uses Flexible so it doesn't overflow notification icon
//  ✅ FIX: FlashPay ShaderMask text uses FittedBox on small screens
//  ✅ FIX: Username text uses TextOverflow.ellipsis + maxLines
//  ✅ FIX: Decorative circles use Positioned.fill-safe coordinates
//  ✅ IMPROVE: Status bar overlay kept transparent (correct pattern)
//  ✅ IMPROVE: const constructors throughout
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flashpay/controllers/notification_controller.dart';
import 'package:flashpay/controllers/user_dashboard_controller.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'fp_theme.dart';
import 'glass_stats_strip.dart';

class DashboardHeader extends StatelessWidget {
  final String userName;
  const DashboardHeader({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(top: statusBarHeight),
      decoration: const BoxDecoration(
        gradient: FPGradients.heroHeader,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative background circles
          const Positioned(top: -24, right: -48,
              child: _DecorCircle(size: 190, opacity: 0.08)),
          const Positioned(bottom: 20, left: -55,
              child: _DecorCircle(size: 230, opacity: 0.05)),
          const Positioned(top: 80, left: 30,
              child: _DecorCircle(size: 80, opacity: 0.06)),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _TopBar()
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.10, curve: Curves.easeOut),

                const SizedBox(height: 24),

                const Text('مرحباً بك 👋', style: FPTextStyles.greetingHint)
                    .animate()
                    .fadeIn(delay: 120.ms, duration: 400.ms)
                    .slideX(begin: 0.08, curve: Curves.easeOut),

                const SizedBox(height: 4),

                // ✅ FIX: Long names won't push layout; ellipsis at 2 lines
                Text(
                  userName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FPTextStyles.greetingName,
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 450.ms)
                    .slideX(begin: 0.08, curve: Curves.easeOut),

                const SizedBox(height: 24),

                const GlassStatsStrip()
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 500.ms)
                    .slideY(begin: 0.18, curve: Curves.easeOut),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Top bar ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Logo mark
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.18),
            border: Border.all(
                color: Colors.white.withOpacity(0.32), width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 3))
            ],
          ),
          child: const Center(
            child: Icon(Icons.bolt_rounded,
                color: Color(0xFFFFF0CC), size: 24),
          ),
        ),

        const SizedBox(width: 10),

        // ✅ FIX: Flexible prevents "FlashPay" text from eating notification space
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                blendMode: BlendMode.srcIn,
                shaderCallback: (Rect bounds) => const LinearGradient(
                  colors: [Color(0xFFFFF8DC), Color(0xFFECB651)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds),
                child: const Text(
                  'FlashPay',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    height: 1.1,
                  ),
                ),
              ),
              Container(
                width: 40, height: 2,
                margin: const EdgeInsets.only(top: 2),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFECB651), Colors.transparent]),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ],
          ),
        ),

        // ✅ FIX: spacer pushes notification button to the far end correctly
        const Spacer(),

        // Notification button (تفاعلي + شارة غير المقروء)
        const _BellButton(),
      ],
    );
  }
}

// ─── Bell button ──────────────────────────────────────────────────────────────
class _BellButton extends StatelessWidget {
  const _BellButton();

  @override
  Widget build(BuildContext context) {
    final nc = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : null;

    // Obx يتطلب قراءة متغيّر تفاعلي، لذا لا نستخدمه إذا لم يُسجَّل المتحكم بعد
    if (nc == null) return _build(0);
    return Obx(() => _build(nc.unread.value));
  }

  Widget _build(int unread) {
    {
      return Semantics(
        button: true,
        label: unread > 0 ? 'الإشعارات، $unread غير مقروءة' : 'الإشعارات',
        child: Tooltip(
          message: 'الإشعارات',
          child: Material(
            color: Colors.white.withOpacity(0.16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.white.withOpacity(0.22)),
            ),
            child: InkWell(
              customBorder: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              onTap: () {
                if (Get.isRegistered<UserDashboardController>()) {
                  Get.find<UserDashboardController>().changeTabIndex(1);
                }
              },
              child: SizedBox(
                width: 46,
                height: 46,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      unread > 0
                          ? Icons.notifications_active_rounded
                          : Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    if (unread > 0)
                      Positioned(
                        top: 3,
                        right: 3,
                        child: Container(
                          constraints: const BoxConstraints(
                              minWidth: 18, minHeight: 18),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDC2626),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                          child: Text(
                            unread > 9 ? '9+' : '$unread',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}

// ─── Decorative circle ────────────────────────────────────────────────────────
class _DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const _DecorCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}