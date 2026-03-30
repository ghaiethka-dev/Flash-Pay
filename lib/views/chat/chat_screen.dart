// =============================================================================
//  chat_screen.dart  — FlashPay Premium Chat Screen
//  ✅ خلفية عصرية بنمط هندسي ناعم
//  ✅ اعتماد اللون الأساسي 0xFF132341
//  ✅ تحسين حالة "لا توجد رسائل" 
//  ✅ تحسين حالة التحميل
//  ✅ تحسين الفواصل الزمنية بين الرسائل
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import 'package:flashpay/controllers/chat_controller.dart';
import 'package:flashpay/core/constants.dart';

import 'widgets/chat_app_bar.dart';
import 'widgets/chat_bubble.dart';
import 'widgets/chat_input_field.dart';

class ChatScreen extends StatelessWidget {
  final int    transferId;
  final String trackingCode;
  final int    currentUserId;

  const ChatScreen({
    Key? key,
    required this.transferId,
    required this.trackingCode,
    required this.currentUserId,
  }) : super(key: key);

  static const Color _kNavy = Color(0xFF132341);

  static String? _formatTime(String createdAt) {
    if (createdAt.isEmpty) return null;
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      return '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return null;
    }
  }

  // ✅ تحويل التاريخ إلى نص عربي مختصر لفاصل اليوم
  static String _formatDateLabel(String createdAt) {
    try {
      final dt    = DateTime.parse(createdAt).toLocal();
      final today = DateTime.now();
      final diff  = today.difference(DateTime(dt.year, dt.month, dt.day)).inDays;
      if (diff == 0) return 'اليوم';
      if (diff == 1) return 'أمس';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ استخدام fenOrPut لمنع إنشاء controller جديد إذا كان موجوداً
    final controller = Get.isRegistered<ChatController>()
        ? Get.find<ChatController>()
        : Get.put(ChatController(
            transferId:    transferId,
            currentUserId: currentUserId,
          ));

    final bool  isDark     = context.theme.brightness == Brightness.dark;
    final Color brandColor = AppColors.primaryGradient.colors.first;

    // ✅ خلفية الشاشة: Navy في الـ dark، وأزرق فاتح جداً في الـ light
    final Color chatBg = isDark ? _kNavy : const Color(0xFFECF0F8);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor:          Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: chatBg,
          appBar: ChatAppBar(
            trackingCode: trackingCode,
            controller:   controller,
          ),
          body: Stack(
            children: [

              // ✅ خلفية هندسية عصرية
              Positioned.fill(
                child: _ChatBackground(isDark: isDark, brandColor: brandColor),
              ),

              // ── المحتوى الرئيسي ───────────────────────────────────────────
              Column(
                children: [
                  Expanded(
                    child: Obx(() {
                      // ── حالة التحميل ──────────────────────────────────────
                      if (controller.isLoading.value) {
                        return _LoadingState(brandColor: brandColor, isDark: isDark);
                      }

                      // ── حالة فارغة ────────────────────────────────────────
                      if (controller.messages.isEmpty) {
                        return _EmptyState(brandColor: brandColor, isDark: isDark);
                      }

                      // ── قائمة الرسائل ─────────────────────────────────────
                      return ListView.builder(
                        controller: controller.scrollController,
                        physics:    const BouncingScrollPhysics(),
                        padding:    const EdgeInsets.fromLTRB(14, 16, 14, 8),
                        itemCount:  controller.messages.length,
                        itemBuilder: (context, index) {
                          final msg = controller.messages[index];

                          final bool isMe    = msg.senderId == currentUserId;
                          final bool isAdmin = msg.isStaff;

                          final bool groupWithPrev = index > 0 &&
                              controller.messages[index - 1].senderId ==
                                  msg.senderId;
                          final bool groupWithNext =
                              index < controller.messages.length - 1 &&
                                  controller.messages[index + 1].senderId ==
                                      msg.senderId;

                          // ✅ فاصل اليوم: يظهر إذا تغير التاريخ
                          final bool showDateSeparator = index == 0 ||
                              _formatDateLabel(msg.createdAt) !=
                                  _formatDateLabel(
                                      controller.messages[index - 1].createdAt);

                          return Column(
                            children: [
                              if (showDateSeparator)
                                _DateSeparator(
                                  label: _formatDateLabel(msg.createdAt),
                                  isDark: isDark,
                                ),
                              ChatBubble(
                                message:           msg.text,
                                imageUrl:          msg.imageUrl,
                                senderName:        msg.senderName,
                                isMe:              isMe,
                                isDark:            isDark,
                                brandColor:        brandColor,
                                isAdmin:           isAdmin,
                                timestamp:         _formatTime(msg.createdAt),
                                groupWithPrevious: groupWithPrev,
                                groupWithNext:     groupWithNext,
                                animationIndex:    index,
                              ),
                            ],
                          );
                        },
                      );
                    }),
                  ),

                  // ── حقل الإدخال ───────────────────────────────────────────
                  ChatInputField(
                    controller: controller,
                    isDark:     isDark,
                    brandColor: brandColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
//  خلفية هندسية عصرية
// ============================================================
class _ChatBackground extends StatelessWidget {
  final bool  isDark;
  final Color brandColor;

  const _ChatBackground({required this.isDark, required this.brandColor});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BgPainter(isDark: isDark, brand: brandColor),
    );
  }
}

class _BgPainter extends CustomPainter {
  final bool  isDark;
  final Color brand;

  const _BgPainter({required this.isDark, required this.brand});

  @override
  void paint(Canvas canvas, Size size) {
    // دوائر هالة ناعمة في الزوايا
    final halo = Paint()..style = PaintingStyle.fill;

    // هالة علوية يمين
    halo.color = (isDark
        ? Colors.white.withOpacity(0.025)
        : brand.withOpacity(0.06));
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.08),
        size.width * 0.55, halo);

    // هالة سفلية يسار
    halo.color = (isDark
        ? Colors.white.withOpacity(0.018)
        : brand.withOpacity(0.045));
    canvas.drawCircle(Offset(size.width * 0.12, size.height * 0.88),
        size.width * 0.50, halo);

    // شبكة نقاط ناعمة
    final dot = Paint()
      ..color = (isDark
          ? Colors.white.withOpacity(0.04)
          : brand.withOpacity(0.07))
      ..style = PaintingStyle.fill;

    const spacing = 30.0;
    final cols = (size.width  / spacing).ceil() + 1;
    final rows = (size.height / spacing).ceil() + 1;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        canvas.drawCircle(
          Offset(c * spacing, r * spacing),
          1.2,
          dot,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.isDark != isDark;
}

// ============================================================
//  حالة التحميل
// ============================================================
class _LoadingState extends StatelessWidget {
  final Color brandColor;
  final bool  isDark;

  const _LoadingState({required this.brandColor, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: brandColor.withOpacity(0.10),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: brandColor.withOpacity(0.15),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: brandColor,
                strokeWidth: 2.5,
              ),
            ),
          ).animate().fadeIn(duration: 400.ms).scale(
              begin: const Offset(0.8, 0.8), curve: Curves.easeOutBack),
          const SizedBox(height: 16),
          Text(
            'جارٍ تحميل المحادثة...',
            style: TextStyle(
              color: isDark ? Colors.white54 : Colors.blueGrey.shade400,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 300.ms),
        ],
      ),
    );
  }
}

// ============================================================
//  حالة فارغة
// ============================================================
class _EmptyState extends StatelessWidget {
  final Color brandColor;
  final bool  isDark;

  const _EmptyState({required this.brandColor, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // أيقونة مع هالة متعددة الطبقات
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: brandColor.withOpacity(0.05),
                ),
              ),
              Container(
                width: 90, height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: brandColor.withOpacity(0.09),
                ),
              ),
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      brandColor.withOpacity(0.20),
                      brandColor.withOpacity(0.12),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: brandColor.withOpacity(0.18),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.chat_bubble_outline_rounded,
                  size: 28,
                  color: brandColor.withOpacity(0.70),
                ),
              ),
            ],
          )
              .animate()
              .fadeIn(duration: 500.ms)
              .scale(begin: const Offset(0.72, 0.72), curve: Curves.easeOutBack),

          const SizedBox(height: 20),

          Text(
            'لا توجد رسائل سابقة',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : const Color(0xFF132341),
            ),
          )
              .animate()
              .fadeIn(delay: 150.ms, duration: 400.ms)
              .slideY(begin: 0.10),

          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: brandColor.withOpacity(0.07),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'أرسل رسالة للبدء بالتواصل مع الدعم',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.white54 : Colors.blueGrey.shade500,
                height: 1.5,
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 250.ms, duration: 400.ms)
              .slideY(begin: 0.10),
        ],
      ),
    );
  }
}

// ============================================================
//  فاصل التاريخ بين الرسائل
// ============================================================
class _DateSeparator extends StatelessWidget {
  final String label;
  final bool   isDark;

  const _DateSeparator({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (label.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: isDark
                  ? Colors.white12
                  : const Color(0xFF132341).withOpacity(0.12),
              thickness: 1,
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.08)
                  : const Color(0xFF132341).withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize:   11,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? Colors.white54
                    : const Color(0xFF132341).withOpacity(0.55),
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Divider(
              color: isDark
                  ? Colors.white12
                  : const Color(0xFF132341).withOpacity(0.12),
              thickness: 1,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}