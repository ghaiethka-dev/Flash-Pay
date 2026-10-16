// =============================================================================
//  chat_app_bar.dart — FlashPay Premium App Bar
//  ✅ حالة الاتصال حقيقية (متصل / تحديث… / غير متصل) بدل نص ثابت
//  ✅ التحديث تلقائي؛ زر التحديث اليدوي يبقى كخيار ويُظهر مؤشراً أثناء المزامنة
//  ✅ العنوان لا يفيض (ellipsis) وأهداف اللمس 48px
// =============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 4);

  @override
  State<ChatAppBar> createState() => _ChatAppBarState();
}

class _ChatAppBarState extends State<ChatAppBar>
    with SingleTickerProviderStateMixin {
  static const Color _green = Color(0xFF34D399);
  static const Color _amber = Color(0xFFFBBF24);
  static const Color _red   = Color(0xFFF87171);

  late final AnimationController _pulseAc = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulseAc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF132341), Color(0xFF1A3258), Color(0xFF0E1D35)],
            begin: Alignment.topLeft,
            end:   Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            const Spacer(),
            // خط برتقالي رفيع يربط الشاشة بهوية التطبيق
            Container(
              height: 3,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    const Color(0xFFC75D05).withOpacity(0.85),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // ── زر الرجوع ───────────────────────────────────────────────────────
      leading: IconButton(
        tooltip: 'رجوع',
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 20,
        ),
        onPressed: () => Get.back(),
      ),

      // ── العنوان ─────────────────────────────────────────────────────────
      title: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withOpacity(0.22),
                  Colors.white.withOpacity(0.08),
                ],
                begin: Alignment.topLeft,
                end:   Alignment.bottomRight,
              ),
              border: Border.all(
                color: Colors.white.withOpacity(0.30),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Colors.white,
              size: 22,
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize:   15.5,
                    fontWeight: FontWeight.w800,
                    color:      Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.20),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.tag_rounded,
                                size: 11,
                                color: Colors.white.withOpacity(0.75)),
                            const SizedBox(width: 3),
                            Flexible(
                              child: Text(
                                widget.trackingCode,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize:      11.5,
                                  color:         Colors.white,
                                  fontWeight:    FontWeight.w600,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),

      // ── الأفعال ─────────────────────────────────────────────────────────
      actions: [
        // حالة الاتصال الحقيقية
        Obx(() {
          final online  = widget.controller.isOnline.value;
          final syncing = widget.controller.isSyncing.value;
          final Color color =
          !online ? _red : (syncing ? _amber : _green);
          final String label =
          !online ? 'غير متصل' : (syncing ? 'تحديث…' : 'متصل');

          return Semantics(
            label: 'حالة الاتصال: $label',
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _pulseAc,
                  builder: (_, __) => Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color.withOpacity(
                              online ? 0.15 + _pulseAc.value * 0.25 : 0.20),
                        ),
                      ),
                      Container(
                        width: 8,
                        height: 8,
                        decoration:
                        BoxDecoration(shape: BoxShape.circle, color: color),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }),

        // تحديث يدوي (اختياري — التحديث تلقائي)
        Obx(() {
          final syncing = widget.controller.isSyncing.value;
          return IconButton(
            tooltip: 'تحديث الآن',
            onPressed: syncing
                ? null
                : () => widget.controller.fetchMessages(silent: true),
            icon: syncing
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white70,
              ),
            )
                : const Icon(Icons.refresh_rounded,
                color: Colors.white, size: 22),
          );
        }),
        const SizedBox(width: 4),
      ],
    );
  }
}