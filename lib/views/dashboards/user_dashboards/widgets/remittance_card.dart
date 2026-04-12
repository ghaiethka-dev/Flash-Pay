// =============================================================================
//  remittance_card.dart
//  Flash Pay — Pressable Remittance Action Card
//  ─────────────────────────────────────────────
//  A tappable gradient card used for "Domestic Remittance" and "International
//  Remittance" quick actions.
//
//  Features
//  ────────
//  • Scale-bounce press animation (local StatefulWidget — zero GetX impact)
//  • Gradient background with layered decorative circles
//  • Icon container, title, subtitle, and a small status badge pill
//  • Trailing animated chevron arrow
//
//  ✅ UI-only — onTap callback is injected by the parent so routing stays
//     untouched in user_dashboard.dart.
// =============================================================================

import 'package:flutter/material.dart';
import 'fp_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Public data model (immutable, const-friendly)
// ─────────────────────────────────────────────────────────────────────────────

/// Carries all visual data needed to render one remittance card.
class RemittanceCardData {
  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;
  final Gradient gradient;
  final Color glowColor;

  const RemittanceCardData({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.gradient,
    required this.glowColor,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  Pre-defined card configurations (import these in user_dashboard.dart)
// ─────────────────────────────────────────────────────────────────────────────

/// Domestic (internal) remittance card — warm orange brand gradient.
const RemittanceCardData kDomesticCard = RemittanceCardData(
  title: 'حوالة داخلية',
  subtitle: 'لمكاتب ووكلاء محلية',
  badge: 'تحويل فوري',
  icon: Icons.send_rounded,
  gradient: FPGradients.domestic,
  glowColor: FPColors.primary,
);

/// International remittance card — rich blue gradient.
const RemittanceCardData kInternationalCard = RemittanceCardData(
  title: 'حوالة دولية',
  subtitle: 'تصل لأي دولة في العالم',
  badge: 'شبكة عالمية',
  icon: Icons.public_rounded,
  gradient: FPGradients.international,
  glowColor: FPColors.blue,
);

// ─────────────────────────────────────────────────────────────────────────────
//  Main widget
// ─────────────────────────────────────────────────────────────────────────────

class RemittanceCard extends StatefulWidget {
  final RemittanceCardData data;

  /// ✅ Routing callback injected from parent — unchanged from original.
  final VoidCallback onTap;

  const RemittanceCard({
    Key? key,
    required this.data,
    required this.onTap,
  }) : super(key: key);

  @override
  State<RemittanceCard> createState() => _RemittanceCardState();
}

class _RemittanceCardState extends State<RemittanceCard>
    with SingleTickerProviderStateMixin {
  // ── Local animation controller for scale-bounce (UI-only state) ──────────
  late final AnimationController _scaleController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
    reverseDuration: const Duration(milliseconds: 200),
    lowerBound: 0.0,
    upperBound: 0.032, // 3.2 % shrink — noticeable but not jarring
  );

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _scaleController.forward();

  void _onTapUp(TapUpDetails _) {
    _scaleController.reverse();
    widget.onTap(); // ✅ Delegates routing to parent unchanged
  }

  void _onTapCancel() => _scaleController.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleController,
        builder: (_, child) => Transform.scale(
          scale: 1.0 - _scaleController.value,
          child: child,
        ),
        child: _CardShell(data: widget.data),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Private: purely visual card shell (no gesture or state)
// ─────────────────────────────────────────────────────────────────────────────

class _CardShell extends StatelessWidget {
  final RemittanceCardData data;

  const _CardShell({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: data.gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: FPShadows.cardGlow(data.glowColor),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Decorative background bubbles
            Positioned(
              bottom: -35, left: -35,
              child: _Bubble(size: 130, opacity: 0.08),
            ),
            Positioned(
              top: -18, left: 50,
              child: _Bubble(size: 75, opacity: 0.06),
            ),

            // Card body
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.20),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(data.icon, color: Colors.white, size: 28),
                  ),

                  const SizedBox(width: 16),

                  // Text column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data.title, style: FPTextStyles.cardTitle),
                        const SizedBox(height: 4),
                        Text(data.subtitle, style: FPTextStyles.cardSubtitle),
                        const SizedBox(height: 10),
                        // Status badge pill
                        _BadgePill(label: data.badge),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Trailing chevron — arrow_forward_ios flips in RTL ✅
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Badge pill ───────────────────────────────────────────────────────────────
class _BadgePill extends StatelessWidget {
  final String label;
  const _BadgePill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.30), width: 1),
      ),
      child: Text(label, style: FPTextStyles.badge),
    );
  }
}

// ─── Decorative bubble ────────────────────────────────────────────────────────
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
