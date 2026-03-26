// =============================================================================
//  chat_screen.dart
//  Flash Pay — Chat Screen  (Main Entry)
//  ───────────────────────────────────────
//  Target path:  lib/views/chat/chat_screen.dart
//
//  ✅ ALL GetX logic preserved exactly:
//     Get.put(ChatController(transferId, currentUserId))
//     controller.isLoading.value
//     controller.messages           (RxList — unchanged)
//     controller.scrollController
//     msg.senderId / msg.text / msg.senderName
//     controller.sendMessage()
//     controller.isSending.value
//
//  ✅ ALL constructor parameters preserved:
//     transferId, trackingCode, currentUserId
//
//  Integration note:
//    • `timestamp` is derived cosmetically from msg fields (null-safe).
//    • groupWithPrevious / groupWithNext computed from adjacent senderId — pure UI.
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
  // ✅ All three required parameters preserved
  final int    transferId;
  final String trackingCode;
  final int    currentUserId;

  const ChatScreen({
    Key? key,
    required this.transferId,
    required this.trackingCode,
    required this.currentUserId,
  }) : super(key: key);

  // ── Cosmetic timestamp ────────────────────────────────────────────────────
  // Converts DateTime / ISO-string → "HH:mm". Returns null if absent.
  static String? _formatTime(dynamic raw) {
    if (raw == null) return null;
    try {
      final DateTime dt =
          raw is DateTime ? raw : DateTime.parse(raw.toString());
      return '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return null;
    }
  }

  // ── Null-safe field accessor ──────────────────────────────────────────────
  static dynamic _safeGet(dynamic obj, String key) {
    try { return (obj as dynamic)[key]; }
    catch (_) { return null; }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Controller injection — unchanged
    final controller = Get.put(ChatController(
      transferId:    transferId,
      currentUserId: currentUserId,
    ));

    // ✅ isDark — unchanged logic
    final bool  isDark     = context.theme.brightness == Brightness.dark;
    // ✅ brandColor — unchanged logic
    final Color brandColor = AppColors.primaryGradient.colors.first;

    // Subtle chat background — slightly differentiated from plain scaffold
    final Color chatBg = isDark
        ? const Color(0xFF0E0E18)
        : const Color(0xFFEEF0F5);

    return Directionality(
      textDirection: TextDirection.rtl, // ✅ unchanged
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor:          Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
          backgroundColor: chatBg,
          appBar: ChatAppBar(trackingCode: trackingCode), // ✅ unchanged

          body: Column(
            children: [

              // ── Messages area ────────────────────────────────────────────
              Expanded(
                child: Obx(() { // ✅ Obx — unchanged

                  // Loading
                  if (controller.isLoading.value) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: brandColor), // ✅
                          const SizedBox(height: 14),
                          Text(
                            'جارٍ تحميل المحادثة...',
                            style: TextStyle(
                              color: isDark ? Colors.white54 : Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Empty state
                  if (controller.messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color:  brandColor.withOpacity(0.08),
                              shape:  BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.chat_bubble_outline_rounded,
                              size:  48,
                              color: brandColor.withOpacity(0.45),
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .scale(
                                begin: const Offset(0.72, 0.72),
                                curve: Curves.easeOutBack,
                              ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد رسائل سابقة.',
                            style: TextStyle(
                              fontSize:   16,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 150.ms, duration: 400.ms)
                              .slideY(begin: 0.10),
                          const SizedBox(height: 6),
                          Text(
                            'أرسل رسالة للبدء بالتواصل.', // ✅ unchanged
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white38 : Colors.grey,
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 240.ms, duration: 400.ms)
                              .slideY(begin: 0.10),
                        ],
                      ),
                    );
                  }

                  // ── Message list ───────────────────────────────────────────
                  return ListView.builder(
                    controller: controller.scrollController, // ✅ unchanged
                    physics:    const BouncingScrollPhysics(),
                    padding:    const EdgeInsets.fromLTRB(12, 16, 12, 8),
                    itemCount:  controller.messages.length,  // ✅ unchanged
                    itemBuilder: (context, index) {
                      final msg = controller.messages[index]; // ✅ unchanged

                      // ✅ isMe — unchanged data logic
                      final bool isMe = msg.senderId == currentUserId;

                      // ── UI-only grouping ───────────────────────────────────
                      final bool groupWithPrev = index > 0 &&
                          controller.messages[index - 1].senderId ==
                              msg.senderId;
                      final bool groupWithNext =
                          index < controller.messages.length - 1 &&
                              controller.messages[index + 1].senderId ==
                                  msg.senderId;

                      // ── Cosmetic timestamp (no data change) ────────────────
                      final String? time = _formatTime(
                        _safeGet(msg, 'createdAt')  ??
                        _safeGet(msg, 'created_at') ??
                        _safeGet(msg, 'timestamp'),
                      );

                      return ChatBubble(
                        // ✅ All original fields — unchanged
                        message:           msg.text,
                        imageUrl:          msg.imageUrl,
                        senderName:        msg.senderName,
                        isMe:              isMe,
                        isDark:            isDark,
                        brandColor:        brandColor,
                        // Cosmetic additions
                        timestamp:         time,
                        groupWithPrevious: groupWithPrev,
                        groupWithNext:     groupWithNext,
                        animationIndex:    index,
                      );
                    },
                  );
                }),
              ),

              // ── Input area ───────────────────────────────────────────────
              ChatInputField(
                controller: controller, // ✅ unchanged
                isDark:     isDark,
                brandColor: brandColor,
              ),

            ],
          ),
        ),
      ),
    );
  }
}