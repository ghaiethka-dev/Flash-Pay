// =============================================================================
//  chat_app_bar.dart  — FlashPay Premium App Bar
//  ✅ تحسينات بصرية: تأثير blur، حواف أجمل، تدرج أعمق
//  ✅ اعتماد اللون الأساسي 0xFF132341
// =============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flashpay/core/constants.dart';
import 'package:flashpay/controllers/chat_controller.dart';

class ChatAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String trackingCode;
  final ChatController controller;

  const ChatAppBar({
    Key? key,
    required this.trackingCode,
    required this.controller,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<ChatAppBar> createState() => _ChatAppBarState();
}

class _ChatAppBarState extends State<ChatAppBar>
    with TickerProviderStateMixin {

  late final AnimationController _pulseAc = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  late final AnimationController _refreshAc = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  bool _isRefreshing = false;

  @override
  void dispose() {
    _pulseAc.dispose();
    _refreshAc.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    _refreshAc.repeat();
    await widget.controller.fetchMessages();
    await Future.delayed(const Duration(milliseconds: 300));
    _refreshAc.stop();
    _refreshAc.reset();
    if (mounted) setState(() => _isRefreshing = false);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          // ✅ تدرج أعمق يبدأ من 0xFF132341
          gradient: LinearGradient(
            colors: [
              Color(0xFF132341),
              Color(0xFF1A3258),
              Color(0xFF0E1D35),
            ],
            begin: Alignment.topLeft,
            end:   Alignment.bottomRight,
          ),
        ),
        // ✅ خط سفلي ناعم كفاصل
        child: Column(
          children: [
            const Spacer(),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Colors.white.withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,

      // ── زر الرجوع ─────────────────────────────────────────────────────────
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => Get.back(),
        splashRadius: 22,
      ),

      // ── العنوان ───────────────────────────────────────────────────────────
      title: Row(
        children: [
          // أيقونة الدعم مع هالة
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.22),
                  Colors.white.withOpacity(0.10),
                ],
                begin: Alignment.topLeft,
                end:   Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.30),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 21,
            ),
          ),
          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'محادثة الحوالة',
                  style: TextStyle(
                    fontSize:      15,
                    fontWeight:    FontWeight.w800,
                    color:         Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 3),
                // ✅ شارة كود التتبع
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.20),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.tag_rounded,
                        size:  9,
                        color: Colors.white.withOpacity(0.70),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        widget.trackingCode,
                        style: const TextStyle(
                          fontSize:   11,
                          color:      Colors.white,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      // ── الأفعال ───────────────────────────────────────────────────────────
      actions: [
        // زر التحديث
        AnimatedBuilder(
          animation: _refreshAc,
          builder: (_, child) => Transform.rotate(
            angle: _refreshAc.value * 2 * 3.14159,
            child: child,
          ),
          child: IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: _isRefreshing ? Colors.white38 : Colors.white,
              size: 22,
            ),
            onPressed: _onRefresh,
            splashRadius: 22,
            tooltip: 'تحديث المحادثة',
          ),
        ),

        // ✅ مؤشر الاتصال مع نبضة
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulseAc,
                builder: (_, __) => Stack(
                  alignment: Alignment.center,
                  children: [
                    // هالة خارجية
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF34D399)
                            .withOpacity(0.15 + _pulseAc.value * 0.25),
                      ),
                    ),
                    // النقطة الداخلية
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF34D399),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              const Text(
                'متصل',
                style: TextStyle(
                  color:      Colors.white70,
                  fontSize:   12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 2),
            ],
          ),
        ),
      ],
    );
  }
}