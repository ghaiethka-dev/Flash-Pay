import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import 'package:get/get.dart'; // 👈 ضروري
import 'package:flashpay/core/constants.dart';

class TransferCard extends StatefulWidget {
  final Map<String, dynamic> transfer;
  final bool isActionable;
  final VoidCallback onTap;
  final int animationIndex;

  const TransferCard({Key? key, required this.transfer, required this.isActionable, required this.onTap, this.animationIndex = 0}) : super(key: key);

  @override
  State<TransferCard> createState() => _TransferCardState();
}

class _TransferCardState extends State<TransferCard> with SingleTickerProviderStateMixin {
  // ... (احتفظ بأكواد الأنيميشن كما هي)
  late final AnimationController _scaleAc = AnimationController(vsync: this, duration: const Duration(milliseconds: 100), reverseDuration: const Duration(milliseconds: 180), lowerBound: 0.0, upperBound: 0.025);
  @override void dispose() { _scaleAc.dispose(); super.dispose(); }
  void _onTapDown(_) => _scaleAc.forward();
  void _onTapUp(_) { _scaleAc.reverse(); widget.onTap(); }
  void _onTapCancel() => _scaleAc.reverse();

  @override
  Widget build(BuildContext context) {
    final Color stripeColor = widget.isActionable ? const Color(0xFFF59E0B) : const Color(0xFF10B981);
    final IconData iconData = widget.isActionable ? Icons.call_received_rounded : Icons.check_circle_outline_rounded;
    final int delayMs = 50 + (widget.animationIndex * 60);
    
    final bool isDark = context.theme.brightness == Brightness.dark; // 👈

    return GestureDetector(
      onTapDown: _onTapDown, onTapUp: _onTapUp, onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAc, builder: (_, child) => Transform.scale(scale: 1.0 - _scaleAc.value, child: child),
        child: Container(
          decoration: BoxDecoration(
            color: context.theme.cardColor, // 👈
            borderRadius: BorderRadius.circular(20),
            border: Border(right: BorderSide(color: stripeColor, width: 4)),
            boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 4))], // 👈
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(width: 48, height: 48, decoration: BoxDecoration(color: stripeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(14)), child: Icon(iconData, color: stripeColor, size: 24)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.transfer['sender']['name'] ?? 'مرسل غير معروف', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: isDark ? Colors.white : const Color(0xFF1F2937))), // 👈
                      const SizedBox(height: 4),
                      Text(widget.transfer['tracking_code'] ?? '#', style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF6B7280), fontSize: 13, fontWeight: FontWeight.w500, letterSpacing: 0.5)), // 👈
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(widget.transfer['amount'].toString(), style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: isDark ? Colors.white : const Color(0xFF1F2937))), // 👈
                    const SizedBox(height: 2),
                    Text(widget.transfer['send_currency'] != null ? widget.transfer['send_currency']['code'] : '', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: stripeColor)),
                  ],
                ),
              ],
            ),
          ),
        ).animate().fadeIn(delay: Duration(milliseconds: delayMs), duration: 400.ms).slideY(begin: 0.1, curve: Curves.easeOut),
      ),
    );
  }
}

class TransferEmptyState extends StatelessWidget {
  final IconData icon; final String message;
  const TransferEmptyState({Key? key, required this.icon, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark; // 👈

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: isDark ? Colors.white10 : Colors.grey.shade100, shape: BoxShape.circle), // 👈
            child: Icon(icon, size: 52, color: isDark ? Colors.white24 : Colors.grey.shade300), // 👈
          ),
          const SizedBox(height: 18),
          Text(message, style: TextStyle(color: isDark ? Colors.white54 : Colors.grey.shade500, fontSize: 15, fontWeight: FontWeight.w600)), // 👈
        ],
      ),
    );
  }
}

// ... (احتفظ بكلاس TransferCardShimmer كما هو)
// ─────────────────────────────────────────────────────────────────────────────
//  Shimmer placeholder (shown while isLoading == true)
// ─────────────────────────────────────────────────────────────────────────────

class TransferCardShimmer extends StatelessWidget {
  const TransferCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark; // 👈 معرفة الثيم

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.white10 : const Color(0xFFEEEEEE), // 👈 يتجاوب مع الظلام
      highlightColor: isDark ? Colors.white24 : const Color(0xFFF5F5F5), // 👈
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: context.theme.cardColor, // 👈 خلفية الكرت الوهمي
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon placeholder
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isDark ? Colors.black26 : Colors.white, // 👈
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              const SizedBox(width: 14),
              // Text placeholders
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        width: double.infinity,
                        height: 14,
                        color: isDark ? Colors.black26 : Colors.white), // 👈
                    const SizedBox(height: 8),
                    Container(width: 100, height: 10, color: isDark ? Colors.black26 : Colors.white), // 👈
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(width: 60, height: 16, color: isDark ? Colors.black26 : Colors.white), // 👈
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Empty state (shared across tabs)
// ─────────────────────────────────────────────────────────────────────────────

