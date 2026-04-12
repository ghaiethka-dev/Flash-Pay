import 'package:flutter/material.dart';
import 'package:get/get.dart'; // 👈 ضروري
import 'fp_theme.dart';

class FeaturePillsRow extends StatelessWidget {
  const FeaturePillsRow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: _FeaturePill(icon: Icons.verified_user_rounded, label: 'آمن 100%', color: FPColors.green)),
        SizedBox(width: 12),
        Expanded(child: _FeaturePill(icon: Icons.bolt_rounded, label: 'تحويل فوري', color: FPColors.primary)),
        SizedBox(width: 12),
        Expanded(child: _FeaturePill(icon: Icons.headset_mic_rounded, label: 'دعم 24/7', color: FPColors.purple)),
      ],
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _FeaturePill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark; // 👈

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: context.theme.cardColor, // 👈
        borderRadius: BorderRadius.circular(20),
        boxShadow: isDark ? [] : FPShadows.card, // 👈
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(color: color.withOpacity(0.10), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : FPColors.textDark, // 👈
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}