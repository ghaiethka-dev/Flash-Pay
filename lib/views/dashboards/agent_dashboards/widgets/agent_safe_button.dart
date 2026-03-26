// =============================================================================
//  agent_safe_button.dart
//  Flash Pay — Agent Safe (Wallet) Button
//  ────────────────────────────────────────
//  A premium, full-width gradient card the agent taps to open the safe sheet.
//
//  Features
//  ────────
//  • Scale-bounce micro-interaction (local StatefulWidget, no GetX impact)
//  • Gradient from AppColors.primaryGradient ✅ (unchanged)
//  • Decorative inner circles for depth
//  • Coloured glow shadow
//
//  ✅ onTap calls controller.fetchAgentSafe() then shows the sheet —
//     both are injected from the parent, never stored here.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flashpay/core/constants.dart';

class AgentSafeButton extends StatefulWidget {
  /// ✅ Calls controller.fetchAgentSafe() + shows safe sheet
  final VoidCallback onTap;

  const AgentSafeButton({Key? key, required this.onTap}) : super(key: key);

  @override
  State<AgentSafeButton> createState() => _AgentSafeButtonState();
}

class _AgentSafeButtonState extends State<AgentSafeButton>
    with SingleTickerProviderStateMixin {
  // ── Local scale-bounce (UI only) ─────────────────────────────────────────
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 110),
    reverseDuration: const Duration(milliseconds: 220),
    lowerBound: 0.0,
    upperBound: 0.030,
  );

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  void _onDown(_) => _ac.forward();
  void _onUp(_) {
    _ac.reverse();
    widget.onTap(); // ✅ delegates to parent
  }
  void _onCancel() => _ac.reverse();

  @override
  Widget build(BuildContext context) {
    final Color brandColor = AppColors.primaryGradient.colors.first;

    return GestureDetector(
      onTapDown: _onDown,
      onTapUp: _onUp,
      onTapCancel: _onCancel,
      child: AnimatedBuilder(
        animation: _ac,
        builder: (_, child) =>
            Transform.scale(scale: 1.0 - _ac.value, child: child),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient, // ✅ unchanged
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: brandColor.withOpacity(0.38),
                blurRadius: 22,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                // Decorative circles for depth
                Positioned(
                  bottom: -24, left: -24,
                  child: _Bubble(size: 110, opacity: 0.08),
                ),
                Positioned(
                  top: -12, left: 60,
                  child: _Bubble(size: 60, opacity: 0.06),
                ),

                // Content row
                Row(
                  children: [
                    // Wallet icon container
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.20),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Text column
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'صندوقي', // ✅ unchanged label
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                              letterSpacing: 0.2,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'اضغط لعرض الرصيد والسجلات', // ✅ unchanged
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Trailing chevron pill
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded, // auto-flips in RTL ✅
                        color: Colors.white70,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small decorative translucent circle
class _Bubble extends StatelessWidget {
  final double size;
  final double opacity;
  const _Bubble({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}
