// =============================================================================
//  chat_input_field.dart  — FlashPay Premium Chat Input
//  ✅ تصميم عصري مع اعتماد اللون الأساسي 0xFF132341
//  ✅ تحسين الظلال والحواف
//  ✅ تحسين أنيميشن زر الإرسال
// =============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flashpay/controllers/chat_controller.dart';
import 'package:flashpay/core/constants.dart';
import 'package:image_picker/image_picker.dart';

class ChatInputField extends StatefulWidget {
  final ChatController controller;
  final bool  isDark;
  final Color brandColor;

  const ChatInputField({
    Key? key,
    required this.controller,
    required this.isDark,
    required this.brandColor,
  }) : super(key: key);

  @override
  State<ChatInputField> createState() => _ChatInputFieldState();
}

class _ChatInputFieldState extends State<ChatInputField>
    with SingleTickerProviderStateMixin {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  late final AnimationController _sendAc = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
    reverseDuration: const Duration(milliseconds: 200),
    lowerBound: 0.0,
    upperBound: 0.10,
  );

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _sendAc.dispose();
    super.dispose();
  }

  void _onSendDown()   => _sendAc.forward();
  void _onSendUp()     { _sendAc.reverse(); widget.controller.sendMessage(); }
  void _onSendCancel() => _sendAc.reverse();

  @override
  Widget build(BuildContext context) {
    // ✅ ألوان متناسقة مع اللون الأساسي Navy
    final Color bg = widget.isDark
        ? const Color(0xFF0D1929)   // أغمق من Navy قليلاً
        : Colors.white;

    final Color fieldBg = widget.isDark
        ? const Color(0xFF1A2B42)   // Navy فاتح
        : const Color(0xFFF0F4FA);  // أزرق رمادي فاتح جداً

    final Color hintColor = widget.isDark
        ? Colors.white30
        : const Color(0xFF132341).withOpacity(0.35);

    final Color textColor = widget.isDark
        ? Colors.white
        : const Color(0xFF132341);

    final Color iconColor = widget.isDark
        ? Colors.white38
        : const Color(0xFF132341).withOpacity(0.45);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          top: BorderSide(
            color: widget.isDark
                ? Colors.white.withOpacity(0.06)
                : const Color(0xFF132341).withOpacity(0.08),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDark ? 0.35 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ✅ معاينة الصورة المختارة
          Obx(() {
            final selectedImage = widget.controller.selectedImageFile.value;
            if (selectedImage != null) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10, left: 4, right: 4),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        height: 100,
                        width: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: widget.brandColor.withOpacity(0.30),
                            width: 2,
                          ),
                          image: DecorationImage(
                            image: FileImage(selectedImage),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: -2,
                      right: -2,
                      child: GestureDetector(
                        onTap: () => widget.controller.removeImage(),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: widget.isDark
                                ? const Color(0xFF0D1929)
                                : Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.20),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 14,
                            color: widget.isDark
                                ? Colors.white70
                                : const Color(0xFF132341),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // ── صف الإدخال ────────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [

              // زر الصورة
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: _IconBtn(
                  icon: Icons.photo_library_outlined,
                  color: iconColor,
                  onTap: () => widget.controller.pickImage(ImageSource.gallery),
                ),
              ),

              const SizedBox(width: 8),

              // ── حقل النص ───────────────────────────────────────────────────
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  decoration: BoxDecoration(
                    color: fieldBg,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: _focused
                          ? widget.brandColor.withOpacity(0.50)
                          : (widget.isDark
                              ? Colors.white.withOpacity(0.06)
                              : const Color(0xFF132341).withOpacity(0.10)),
                      width: _focused ? 1.8 : 1.0,
                    ),
                    boxShadow: _focused
                        ? [
                            BoxShadow(
                              color: widget.brandColor.withOpacity(0.12),
                              blurRadius: 12,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: TextField(
                    controller: widget.controller.messageController,
                    focusNode:  _focusNode,
                    style: TextStyle(
                      color:    textColor,
                      fontSize: 14.5,
                      height:   1.45,
                    ),
                    maxLines: 5,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText:  'اكتب رسالتك هنا...',
                      hintStyle: TextStyle(
                        color:    hintColor,
                        fontSize: 14,
                      ),
                      border:          InputBorder.none,
                      contentPadding:  const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical:   12,
                      ),
                    ),
                    onSubmitted: (_) => widget.controller.sendMessage(),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // ── زر الإرسال / دوار ─────────────────────────────────────────
              Obx(
                () => widget.controller.isSending.value
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: widget.brandColor,
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTapDown:  (_) => _onSendDown(),
                        onTapUp:    (_) => _onSendUp(),
                        onTapCancel: _onSendCancel,
                        child: AnimatedBuilder(
                          animation: _sendAc,
                          builder: (_, child) => Transform.scale(
                            scale: 1.0 - _sendAc.value,
                            child: child,
                          ),
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: AppColors.primaryGradient,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: widget.brandColor.withOpacity(0.40),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── زر أيقونة مع تأثير hover ─────────────────────────────────────────────────
class _IconBtn extends StatefulWidget {
  final IconData icon;
  final Color    color;
  final VoidCallback onTap;

  const _IconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  State<_IconBtn> createState() => _IconBtnState();
}

class _IconBtnState extends State<_IconBtn> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown:  (_) => setState(() => _pressed = true),
      onTapUp:    (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale:    _pressed ? 0.88 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Icon(widget.icon, color: widget.color, size: 26),
      ),
    );
  }
}