// =============================================================================
//  chat_input_field.dart
//  Flash Pay — Chat Input Area (Modified for Image Preview)
//  ────────────────────────────
//  Target path: lib/views/chat/widgets/chat_input_field.dart
//
//  A floating-style, premium bottom input container with:
//    • Soft shadow that lifts the bar off the background
//    • [MODIFIED] Column layout supporting reactive image preview above input row. ✅
//    • Rounded text field with dynamic border tint on focus
//    • Send button with scale-bounce micro-interaction (local StatefulWidget)
//    • Sending spinner (CircularProgressIndicator) while isSending == true ✅
//    • Full dark/light mode support ✅
//
//  ✅ Controller references preserved (Gallery binding updated to workflow in turn 11):
//     controller.messageController     ← TextEditingController
//     controller.sendMessage()         ← send callback
//     controller.isSending.value       ← Obx reactive bool
//     controller.pickImage()           ← [MODIFIED] New function to pick, not pickAndSend ✅
//     controller.selectedImageFile.value ← [ADDED binding] Reactively shows picked image preview ✅
//     controller.removeImage()         ← [ADDED binding] Deletes picked image before sending ✅
// =============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flashpay/controllers/chat_controller.dart';
import 'package:flashpay/core/constants.dart';
import 'package:image_picker/image_picker.dart';
// تذكر إضافة 'package:image_picker/image_picker.dart'; للـ controller إذا لم يكن موجوداً

class ChatInputField extends StatefulWidget {
  final ChatController controller; // ✅ ChatController reference preserved
  final bool isDark;
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
  // ── Local focus tracking for animated border ───────────────────────────
  final FocusNode _focusNode = FocusNode();
  bool _focused = false;

  // ── Send button scale controller (local UI only) ───────────────────────
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

  void _onSendDown() => _sendAc.forward();
  void _onSendUp() {
    _sendAc.reverse();
    // ✅ Calling original sendMessage (now updated in controller to handle caption + image)
    widget.controller.sendMessage(); 
  }
  void _onSendCancel() => _sendAc.reverse();

  @override
  Widget build(BuildContext context) {
    final Color bg = widget.isDark
        ? const Color(0xFF1E1E2E)
        : Colors.white;

    final Color fieldBg = widget.isDark
        ? const Color(0xFF2A2A3A)
        : const Color(0xFFF3F4F6);

    final Color hintColor = widget.isDark
        ? Colors.white38
        : Colors.grey.shade500;

    final Color textColor = widget.isDark ? Colors.white : Colors.black87;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.isDark ? 0.30 : 0.07),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        // Respect the system bottom inset (home-bar / nav bar)
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      // [MODIFIED] Wrapped with Column to support Preview Box above Input Row ✅
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // ✅ [ADDED] Reactive Image Preview Box Added
          // This section reactively displays the picked image if selectedImageFile is not null
          Obx(() {
            final selectedImage = widget.controller.selectedImageFile.value;
            if (selectedImage != null) {
              return Stack(
                children: [
                  Container(
                    margin: const EdgeInsets.only(bottom: 12, left: 8, right: 8),
                    height: 100, // Fixed size preview
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.08)), // Subtle border
                      image: DecorationImage(
                        image: FileImage(selectedImage),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Delete button (X)
                  Positioned(
                    top: -4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => widget.controller.removeImage(), // ✅ Calling removeImage
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 16, color: Colors.white),
                      ),
                    ),
                  )
                ],
              );
            }
            // Return empty shrink if no image selected
            return const SizedBox.shrink();
          }),

          // [ORIGINAL ROW CONTENT] ✅
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: IconButton(
                  icon: Icon(
                    Icons.photo_library_outlined,
                    color: hintColor, // استخدام نفس لون الـ hint الموجود في ملفك
                    size: 26,
                  ),
                  // [MODIFIED] gallery binding changed ✅
                  // CHANGE: Replaced controller.pickAndSendImage() with controller.pickImage()
                  // This implements the new workflow defined in turn 11 (pick -> preview -> send later).
                  onPressed: () => widget.controller.pickImage(ImageSource.gallery), 
                  splashRadius: 24,
                ),
              ),
              const SizedBox(width: 4),
              // ── Text field (Original unchanged) ──
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: fieldBg,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: _focused
                          ? widget.brandColor.withOpacity(0.60)
                          : Colors.transparent,
                      width: 1.5,
                    ),
                    boxShadow: _focused
                        ? [
                            BoxShadow(
                              color: widget.brandColor.withOpacity(0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: TextField(
                    // ✅ controller.messageController — unchanged
                    controller: widget.controller.messageController,
                    focusNode: _focusNode,
                    style: TextStyle(color: textColor, fontSize: 14.5),
                    maxLines: 5,
                    minLines: 1,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: 'اكتب رسالتك هنا...', // ✅ unchanged text and style
                      hintStyle: TextStyle(color: hintColor, fontSize: 14),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                    ),
                    // ✅ onSubmitted calls sendMessage — unchanged
                    onSubmitted: (_) => widget.controller.sendMessage(),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // ── Send button / spinner (Original unchanged) ──
              Obx( // ✅ Obx for isSending — unchanged reactive binding
                () => widget.controller.isSending.value
                    ? Padding(
                        padding: const EdgeInsets.all(12),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: widget.brandColor, // ✅ brand color preserved
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTapDown: (_) => _onSendDown(),
                        onTapUp: (_) => _onSendUp(), // ✅ unmodified send callback
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
                              gradient: AppColors.primaryGradient, // ✅ original brand gradient preserved
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: widget.brandColor.withOpacity(0.35),
                                  blurRadius: 12,
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