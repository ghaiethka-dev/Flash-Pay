// =============================================================================
//  dashboard_header.dart
//  Flash Pay — Gradient Hero Header
//  ──────────────────────────────────
//  Replaces the old flat AppBar with a full-bleed gradient header that:
//    • bleeds into the system status bar
//    • shows the brand name + notification icon row
//    • greets the signed-in user (name read from GetX controller via callback)
//    • embeds the GlassStatsStrip at the bottom
//    • has layered decorative circles for depth
//
//  ✅ UI-only — accepts userName as a plain String so the widget itself
//     carries zero state-management dependency.  The parent Obx() wrapper
//     in user_dashboard.dart drives rebuilds.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'fp_theme.dart';
import 'glass_stats_strip.dart';

class DashboardHeader extends StatelessWidget {
  /// The user's display name, injected from the parent Obx() wrapper.
  final String userName;

  const DashboardHeader({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Respect the device's status-bar height so content is never clipped
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Container(
      // Push content below the status bar
      padding: EdgeInsets.only(top: statusBarHeight),
      decoration: const BoxDecoration(
        gradient: FPGradients.heroHeader,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
      ),
      child: Stack(
        children: [
          // ── Decorative translucent circles for depth ────────────────────
          const Positioned(top: -24, right: -48, child: _DecorCircle(size: 190, opacity: 0.08)),
          const Positioned(bottom: 20, left: -55, child: _DecorCircle(size: 230, opacity: 0.05)),
          const Positioned(top: 80, left: 30,    child: _DecorCircle(size: 80,  opacity: 0.06)),

          // ── Main content ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: brand title + bell icon
                _TopBar()
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.10, curve: Curves.easeOut),

                const SizedBox(height: 28),

                // Greeting sub-label
                const Text('مرحباً بك 👋', style: FPTextStyles.greetingHint)
                    .animate()
                    .fadeIn(delay: 120.ms, duration: 400.ms)
                    .slideX(begin: 0.08, curve: Curves.easeOut),

                const SizedBox(height: 4),

                // User name — rebuilt by parent Obx()
                Text(userName, style: FPTextStyles.greetingName)
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 450.ms)
                    .slideX(begin: 0.08, curve: Curves.easeOut),

                const SizedBox(height: 28),

                // Glassmorphism stats strip
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

// ─────────────────────────────────────────────────────────────────────────────
//  Private: top bar row
// ─────────────────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Brand name
        const Text('Flash Pay', style: FPTextStyles.brandTitle),

        // Notification bell button (purely decorative; tab switch is handled
        // by the bottom nav bar so the business logic stays untouched)
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.16),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.22), width: 1),
          ),
          child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Private: decorative background circle
// ─────────────────────────────────────────────────────────────────────────────
class _DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;

  const _DecorCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}
