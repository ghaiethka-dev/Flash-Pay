// =============================================================================
//  glass_stats_strip.dart
//  Flash Pay — Glassmorphism Stats Strip
//  ──────────────────────────────────────
//  Three key trust-indicator stats displayed on a frosted-glass card that
//  sits inside the hero header.  Fully stateless and const-constructible.
//
//  ✅ UI-only — no controller or state management dependency.
// =============================================================================

import 'package:flutter/material.dart';
import 'fp_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Public widget
// ─────────────────────────────────────────────────────────────────────────────
class GlassStatsStrip extends StatelessWidget {
  const GlassStatsStrip({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        // Frosted-glass effect via semi-transparent white layer
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withOpacity(0.26),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: const [
          _StatItem(
            icon: Icons.check_circle_outline_rounded,
            value: '100%',
            label: 'خدمة موثوقة',
          ),
          _VerticalDivider(),
          _StatItem(
            icon: Icons.access_time_rounded,
            value: '24/7',
            label: 'متاح دائماً',
          ),
          _VerticalDivider(),
          _StatItem(
            icon: Icons.public_rounded,
            value: '+50',
            label: 'دول مخدومة',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Private sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

/// Single stat column: icon → value → label.
class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 21),
        const SizedBox(height: 6),
        Text(value, style: FPTextStyles.statValue),
        const SizedBox(height: 2),
        Text(label, style: FPTextStyles.statLabel),
      ],
    );
  }
}

/// Thin vertical separator between stat items.
class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      width: 1,
      color: Colors.white.withOpacity(0.25),
    );
  }
}
