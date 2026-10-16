// =============================================================================
//  chat_input_field.dart — FlashPay Premium Chat Input
//  ✅ زر الإرسال يتفعّل فقط عند وجود نص/صورة (وتظهر حالة معطّلة واضحة)
//  ✅ أهداف لمس 44–48px + Semantics
//  ✅ اختيار الصورة من المعرض أو الكاميرا (Bottom Sheet)
//  ✅ النزول لآخر رسالة عند فتح لوحة المفاتيح
// =============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flashpay/controllers/chat_controller.dart';
import 'package:flashpay/core/constants.dart';
import 'package:image_picker/image_picker.dart';

const Color _kNavy = Color(0xFF132341);

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

class _ChatInputFieldState extends State<ChatInputField> {
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
      if (_focusNode.hasFocus) {
        // بعد ظهور لوحة المفاتيح
        Future.delayed(
          const Duration(milliseconds: 320),
          widget.controller.scrollToBottom,
        );
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _openAttachSheet() {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
      context: context,
      backgroundColor: widget.isDark ? const Color(0xFF14233A) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: (widget.isDark ? Colors.white : _kNavy)
                        .withOpacity(0.18),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                _SheetTile(
                  icon: Icons.photo_library_rounded,
                  label: 'اختيار من المعرض',
                  isDark: widget.isDark,
                  onTap: () {
                    Navigator.pop(ctx);
                    widget.controller.pickImage(ImageSource.gallery);
                  },
                ),
                _SheetTile(
                  icon: Icons.photo_camera_rounded,
                  label: 'التقاط صورة',
                  isDark: widget.isDark,
                  onTap: () {
                    Navigator.pop(ctx);
                    widget.controller.pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool dark = widget.isDark;

    final Color bg        = dark ? const Color(0xFF0D1929) : Colors.white;
    final Color fieldBg   = dark ? const Color(0xFF1A2B42) : const Color(0xFFF0F4FA);
    final Color hintColor = dark ? Colors.white54 : _kNavy.withOpacity(0.50);
    final Color textColor = dark ? Colors.white : _kNavy;
    final Color iconColor = dark ? Colors.white70 : _kNavy.withOpacity(0.62);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        border: Border(
          top: BorderSide(
            color: dark
                ? Colors.white.withOpacity(0.06)
                : _kNavy.withOpacity(0.08),
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.35 : 0.07),
            blurRadius: 22,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── معاينة الصورة المختارة ───────────────────────────────────
            Obx(() {
              final file = widget.controller.selectedImageFile.value;
              return AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: file == null
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                  padding: const EdgeInsets.fromLTRB(6, 6, 6, 10),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: widget.brandColor.withOpacity(0.35),
                            width: 2,
                          ),
                          image: DecorationImage(
                            image: FileImage(file),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      PositionedDirectional(
                        top: -8,
                        end: -8,
                        child: Semantics(
                          button: true,
                          label: 'إزالة الصورة',
                          child: InkResponse(
                            onTap: widget.controller.removeImage,
                            radius: 22,
                            child: Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: dark
                                    ? const Color(0xFF243650)
                                    : Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.22),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: dark ? Colors.white : _kNavy,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            // ── صف الإدخال ────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // زر الإرفاق
                Semantics(
                  button: true,
                  label: 'إرفاق صورة',
                  child: InkResponse(
                    onTap: _openAttachSheet,
                    radius: 26,
                    child: SizedBox(
                      width: 46,
                      height: 48,
                      child: Icon(Icons.add_photo_alternate_rounded,
                          color: iconColor, size: 27),
                    ),
                  ),
                ),

                // حقل النص
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: fieldBg,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(
                        color: _focused
                            ? widget.brandColor.withOpacity(0.55)
                            : (dark
                            ? Colors.white.withOpacity(0.07)
                            : _kNavy.withOpacity(0.10)),
                        width: _focused ? 1.8 : 1.0,
                      ),
                    ),
                    child: TextField(
                      controller: widget.controller.messageController,
                      focusNode: _focusNode,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        height: 1.45,
                      ),
                      maxLines: 5,
                      minLines: 1,
                      keyboardType: TextInputType.multiline,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.send,
                      cursorColor: widget.brandColor,
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالتك هنا...',
                        hintStyle: TextStyle(color: hintColor, fontSize: 14.5),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 13),
                      ),
                      onSubmitted: (_) => widget.controller.sendMessage(),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // زر الإرسال: يتفعّل عند وجود نص أو صورة
                Obx(() {
                  final sending = widget.controller.isSending.value;
                  final hasImage =
                      widget.controller.selectedImageFile.value != null;
                  return ValueListenableBuilder<TextEditingValue>(
                    valueListenable: widget.controller.messageController,
                    builder: (_, value, __) {
                      final enabled =
                          (value.text.trim().isNotEmpty || hasImage) && !sending;
                      return _SendButton(
                        enabled: enabled,
                        sending: sending,
                        isDark: dark,
                        brandColor: widget.brandColor,
                        onTap: widget.controller.sendMessage,
                      );
                    },
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── زر الإرسال ───────────────────────────────────────────────────────────────
class _SendButton extends StatelessWidget {
  final bool enabled;
  final bool sending;
  final bool isDark;
  final Color brandColor;
  final VoidCallback onTap;

  const _SendButton({
    required this.enabled,
    required this.sending,
    required this.isDark,
    required this.brandColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool active = enabled || sending;

    return Semantics(
      button: true,
      enabled: enabled,
      label: 'إرسال الرسالة',
      child: AnimatedScale(
        scale: enabled ? 1.0 : 0.94,
        duration: const Duration(milliseconds: 160),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: active ? AppColors.primaryGradient : null,
            color: active
                ? null
                : (isDark
                ? Colors.white.withOpacity(0.10)
                : _kNavy.withOpacity(0.10)),
            shape: BoxShape.circle,
            boxShadow: enabled
                ? [
              BoxShadow(
                color: brandColor.withOpacity(0.40),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ]
                : const [],
          ),
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: enabled ? onTap : null,
              child: Center(
                child: sending
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
                    : Icon(
                  Icons.send_rounded, // يتعكس تلقائياً في RTL
                  size: 21,
                  color: enabled
                      ? Colors.white
                      : (isDark ? Colors.white38 : _kNavy.withOpacity(0.35)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── عنصر في قائمة الإرفاق ────────────────────────────────────────────────────
class _SheetTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _SheetTile({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFC75D05).withOpacity(0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: const Color(0xFFC75D05), size: 22),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: isDark ? Colors.white : _kNavy,
        ),
      ),
    );
  }
}