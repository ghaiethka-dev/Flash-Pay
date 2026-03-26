// =============================================================================
//  chat_app_bar.dart
//  Flash Pay — Chat Screen App Bar
//  ─────────────────────────────────
//  Premium gradient AppBar with:
//    • Chat icon + "محادثة الحوالة" title
//    • Tracking code pill badge below title
//    • Animated online/support indicator dot
//    • Back button using Get.back() ✅ unchanged
//
//  ✅ UI-only — trackingCode injected as plain String from parent.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flashpay/core/constants.dart';

class ChatAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String trackingCode; // ✅ preserved parameter

  const ChatAppBar({Key? key, required this.trackingCode}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<ChatAppBar> createState() => _ChatAppBarState();
}

class _ChatAppBarState extends State<ChatAppBar>
    with SingleTickerProviderStateMixin {
  // ── Pulsing support-online dot (local UI state only) ──────────────────────
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
    final Color brand = AppColors.primaryGradient.colors.first;

    return AppBar(
      // Gradient fills the entire bar
      flexibleSpace: Container(
        decoration: BoxDecoration(gradient: AppColors.primaryGradient),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,

      // ✅ Back button — Get.back() unchanged
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: Colors.white, size: 20),
        onPressed: () => Get.back(),
        splashRadius: 22,
      ),

      title: Row(
        children: [
          // Support avatar circle
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.20),
              shape: BoxShape.circle,
              border: Border.all(
                  color: Colors.white.withOpacity(0.40), width: 1.5),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(width: 10),

          // Title column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'محادثة الحوالة', // ✅ unchanged
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                // Tracking code pill
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.20),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.trackingCode, // ✅ unchanged
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      actions: [
        // Animated online dot
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
                        color: const Color(0xFF34D399).withOpacity(
                            0.4 + _pulseAc.value * 0.4),
                        blurRadius: 5 + _pulseAc.value * 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                'متصل',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ],
    );
  }
}
