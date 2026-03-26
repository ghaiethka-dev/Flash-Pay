// =============================================================================
//  chat_bubble.dart
//  Flash Pay — WhatsApp-Style Premium Chat Bubble
//  ───────────────────────────────────────────────
//
//  POSITIONING (WhatsApp convention — data logic untouched):
//    isMe == true   → RIGHT  (my messages)
//    isMe == false  → LEFT   (other person's messages)
//
//  COLOR PALETTE:
//    Sender   (RIGHT) → brand gradient  +  white text
//    Receiver (LEFT)  → neutral gray    +  dark/light text by mode
//
//  ASYMMETRIC TAIL RADIUS:
//    Sender   (RIGHT) → sharp bottom-RIGHT corner  (tail ▶ points right)
//    Receiver (LEFT)  → sharp bottom-LEFT  corner  (tail ◀ points left)
//    Mid-group bubbles → tail suppressed, tight inner corners used instead
//
//  FEATURES:
//    • Timestamp + double-tick icon inside the bubble (bottom-right)
//    • Sender name on first receiver bubble of a group
//    • Staggered fade + slide-up entry (flutter_animate)
//    • Glow shadow on sender  /  neutral lift shadow on receiver (light only)
//    • Full light / dark mode
//
//  ✅ All original field names preserved — NO data or state changes.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Design tokens  (change visual constants here without touching logic)
// ─────────────────────────────────────────────────────────────────────────────
abstract final class _R {
  static const double full = 20.0; // fully-rounded corner
  static const double tail = 4.0;  // sharp tail corner (last in group)
  static const double mid  = 6.0;  // inner corner when bubble is in a group

  // ── Sender (RIGHT) ────────────────────────────────────────────────────────
  /// Solo or last in group — tail visible bottom-right
  static const BorderRadius sSolo = BorderRadius.only(
    topLeft:     Radius.circular(full),
    topRight:    Radius.circular(full),
    bottomLeft:  Radius.circular(full),
    bottomRight: Radius.circular(tail), // ← TAIL
  );
  /// First of a multi-bubble group — no tail yet
  static const BorderRadius sFirst = BorderRadius.only(
    topLeft:     Radius.circular(full),
    topRight:    Radius.circular(full),
    bottomLeft:  Radius.circular(full),
    bottomRight: Radius.circular(mid),
  );
  /// Middle of a group
  static const BorderRadius sMid = BorderRadius.only(
    topLeft:     Radius.circular(full),
    topRight:    Radius.circular(mid),
    bottomLeft:  Radius.circular(full),
    bottomRight: Radius.circular(mid),
  );
  /// Last of a multi-bubble group — tail appears
  static const BorderRadius sLast = BorderRadius.only(
    topLeft:     Radius.circular(full),
    topRight:    Radius.circular(mid),
    bottomLeft:  Radius.circular(full),
    bottomRight: Radius.circular(tail), // ← TAIL
  );

  // ── Receiver (LEFT) ───────────────────────────────────────────────────────
  /// Solo or last in group — tail visible bottom-left
  static const BorderRadius rSolo = BorderRadius.only(
    topLeft:     Radius.circular(full),
    topRight:    Radius.circular(full),
    bottomLeft:  Radius.circular(tail), // ← TAIL
    bottomRight: Radius.circular(full),
  );
  /// First of a group
  static const BorderRadius rFirst = BorderRadius.only(
    topLeft:     Radius.circular(full),
    topRight:    Radius.circular(full),
    bottomLeft:  Radius.circular(mid),
    bottomRight: Radius.circular(full),
  );
  /// Middle of a group
  static const BorderRadius rMid = BorderRadius.only(
    topLeft:     Radius.circular(mid),
    topRight:    Radius.circular(full),
    bottomLeft:  Radius.circular(mid),
    bottomRight: Radius.circular(full),
  );
  /// Last of a group — tail appears
  static const BorderRadius rLast = BorderRadius.only(
    topLeft:     Radius.circular(mid),
    topRight:    Radius.circular(full),
    bottomLeft:  Radius.circular(tail), // ← TAIL
    bottomRight: Radius.circular(full),
  );

  // Receiver background
  static const Color rxBgLight    = Color(0xFFEBECF1); // warm light gray
  static const Color rxBgDark     = Color(0xFF2C2D3F); // deep slate
  static const Color rxTextLight  = Color(0xFF1A1A2E);
  static const Color rxTextDark   = Color(0xFFE2E3EF);

  // Timestamp opacity
  static const double tsAlpha = 0.55;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Widget
// ─────────────────────────────────────────────────────────────────────────────
class ChatBubble extends StatelessWidget {
  // ✅ All original fields — unchanged names
  final String message;
  final String? imageUrl;
  final String senderName;
  final bool   isMe;
  final bool   isDark;
  final Color  brandColor;

  /// Optional "HH:mm" string displayed at the bubble foot.
  /// Pass null to hide the timestamp row.
  final String? timestamp;

  /// UI-only grouping — no data change
  final bool groupWithPrevious;
  final bool groupWithNext;

  /// Drives stagger animation delay (index in list)
  final int animationIndex;

  const ChatBubble({
    Key? key,
    required this.message,
    this.imageUrl,
    required this.senderName,
    required this.isMe,
    required this.isDark,
    required this.brandColor,
    this.timestamp,
    this.groupWithPrevious = false,
    this.groupWithNext     = false,
    this.animationIndex    = 0,
  }) : super(key: key);

  // ── Resolve the correct BorderRadius for this bubble's group position ─────
  BorderRadius _resolveRadius() {
    final bool first = !groupWithPrevious;
    final bool last  = !groupWithNext;

    if (isMe) {
      if (first && last) return _R.sSolo;
      if (first)         return _R.sFirst;
      if (last)          return _R.sLast;
      return _R.sMid;
    } else {
      if (first && last) return _R.rSolo;
      if (first)         return _R.rFirst;
      if (last)          return _R.rLast;
      return _R.rMid;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ── Colours ───────────────────────────────────────────────────────────
    final Color textColor = isMe
        ? Colors.white
        : (isDark ? _R.rxTextDark : _R.rxTextLight);

    final Color rxBg = isDark ? _R.rxBgDark : _R.rxBgLight;

    // ── Drop shadows (suppressed in dark mode) ────────────────────────────
    final List<BoxShadow> shadow = isDark
        ? []
        : [
            BoxShadow(
              color: isMe
                  ? brandColor.withOpacity(0.28) // warm glow on sender
                  : Colors.black.withOpacity(0.06),
              blurRadius:   isMe ? 18 : 10,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ];

    // ── Stagger delay (cap at 400 ms) ─────────────────────────────────────
    final int delayMs = (animationIndex * 35).clamp(0, 400);

    // ── Vertical spacing ──────────────────────────────────────────────────
    final double bottomGap = groupWithNext ? 3.0 : 10.0;
    final double topGap    = groupWithPrevious ? 0.0 : 2.0;

    return Align(
      // ✅ WHATSAPP CONVENTION (UI only — data untouched):
      //   isMe == true  → RIGHT (my messages)
      //   isMe == false → LEFT  (other person)
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top:    topGap,
          bottom: bottomGap,
          left:   isMe ? 52.0 : 0.0,  // push sender away from left edge
          right:  isMe ? 0.0  : 52.0, // push receiver away from right edge
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          // Sender  → 3-stop brand gradient for identity + depth
          // Receiver → flat neutral for maximum readability
          gradient: isMe
              ? LinearGradient(
                  colors: [
                    Color.lerp(brandColor, Colors.white, 0.10)!,
                    brandColor,
                    Color.lerp(brandColor, Colors.black, 0.14)!,
                  ],
                  begin: Alignment.topLeft,
                  end:   Alignment.bottomRight,
                )
              : null,
          color:        isMe ? null : rxBg,
          borderRadius: _resolveRadius(),
          boxShadow:    shadow,
        ),

        // ── Bubble content ────────────────────────────────────────────────
        child: Padding(
          padding: const EdgeInsets.fromLTRB(13, 9, 13, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [

              // ── Sender name (receiver only, first in group) ─────────────
              if (!isMe && !groupWithPrevious) ...[
                Text(
                  senderName,
                  style: TextStyle(
                    fontSize:      11,
                    fontWeight:    FontWeight.w700,
                    letterSpacing: 0.3,
                    color: textColor.withOpacity(0.58),
                  ),
                ),
                const SizedBox(height: 3),
              ],
              // ✅ ── عرض الصورة إن وجدت ──
              if (imageUrl != null && imageUrl!.isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl!, // تأكد أن الـ Backend يرسل الرابط كاملاً (Full URL) أو قم بإضافة الـ Base URL هنا
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        height: 150,
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    },
                    errorBuilder: (_, __, ___) => const SizedBox(
                      height: 150,
                      child: Center(child: Icon(Icons.broken_image_rounded, color: Colors.grey)),
                    ),
                  ),
                ),
                if (message.isNotEmpty) const SizedBox(height: 6), // مسافة إذا كان هناك صورة ونص معاً
              ],

              // ── Message text (الكود الأصلي) ─────────────
              if (message.isNotEmpty)
              Text(
                message,
                style: TextStyle(
                  fontSize:   14.5,
                  height:     1.50,
                  color:      textColor,
                  fontWeight: FontWeight.w400,
                ),
              ),

              // ── Timestamp + tick icon ───────────────────────────────────
              if (timestamp != null) ...[
                const SizedBox(height: 4),
                Row(
                  mainAxisSize:      MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Double-tick only on sender (me) bubbles
                    if (isMe) ...[
                      Icon(
                        Icons.done_all_rounded,
                        size:  13,
                        color: Colors.white.withOpacity(0.60),
                      ),
                      const SizedBox(width: 3),
                    ],
                    Text(
                      timestamp!,
                      style: TextStyle(
                        fontSize:      10,
                        fontWeight:    FontWeight.w500,
                        letterSpacing: 0.2,
                        color: textColor.withOpacity(_R.tsAlpha),
                      ),
                    ),
                  ],
                ),
              ],

            ],
          ),
        ),
      ),
    )
    // ── Staggered fade + slide-up entry animation ──────────────────────────
    .animate()
    .fadeIn(
      delay:    Duration(milliseconds: delayMs),
      duration: const Duration(milliseconds: 300),
      curve:    Curves.easeOut,
    )
    .slideY(
      begin:    0.10,
      delay:    Duration(milliseconds: delayMs),
      duration: const Duration(milliseconds: 300),
      curve:    Curves.easeOut,
    );
  }
}