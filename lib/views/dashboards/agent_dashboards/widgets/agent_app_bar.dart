// =============================================================================
//  agent_app_bar.dart
//  Flash Pay — Agent Dashboard App Bar
//  ─────────────────────────────────────
//  Premium gradient AppBar with:
//    • Gold agent shield icon
//    • "لوحة الوكيل" title
//    • Animated "Online" status dot
//    • Bleed-safe top padding via PreferredSize
//
//  ✅ UI-only — zero controller dependency.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flashpay/core/constants.dart';

class AgentAppBar extends StatefulWidget implements PreferredSizeWidget {
  const AgentAppBar({Key? key}) : super(key: key);

  // Standard toolbar height — identical to original AppBar height
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<AgentAppBar> createState() => _AgentAppBarState();
}

class _AgentAppBarState extends State<AgentAppBar>
    with SingleTickerProviderStateMixin {
  // ── Pulsing green "online" dot (local UI state) ───────────────────────────
  late final AnimationController _pulseAc = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulseAc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Transparent status bar so gradient bleeds in
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    return AppBar(
      // ✅ Brand gradient — AppColors.primaryGradient unchanged
      flexibleSpace: Container(
        decoration: BoxDecoration(gradient: AppColors.primaryGradient),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gold shield icon — unchanged from original
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              color: Color(0xFFFFD166), // gold — unchanged
              size: 22,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'لوحة الوكيل', // ✅ unchanged
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 20,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
      actions: [
        // Animated online indicator
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAc,
                builder: (_, __) => Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF34D399),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF34D399)
                            .withOpacity(0.4 + _pulseAc.value * 0.4),
                        blurRadius: 6 + _pulseAc.value * 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'متصل',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
