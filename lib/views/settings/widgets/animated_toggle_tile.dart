import 'package:flutter/material.dart';
import 'package:get/get.dart'; // 👈
import '../../dashboards/user_dashboards/widgets/fp_theme.dart';

class AnimatedToggleTile extends StatefulWidget {
  final IconData icon; final Color iconColor; final String title; final String? subtitle; final bool initialValue; final ValueChanged<bool>? onChanged; final bool showDivider;
  const AnimatedToggleTile({Key? key, required this.icon, required this.iconColor, required this.title, this.subtitle, this.initialValue = false, this.onChanged, this.showDivider = true}) : super(key: key);
  @override
  State<AnimatedToggleTile> createState() => _AnimatedToggleTileState();
}

class _AnimatedToggleTileState extends State<AnimatedToggleTile> with SingleTickerProviderStateMixin {
  late bool _isOn;
  late final AnimationController _thumbAc = AnimationController(vsync: this, duration: const Duration(milliseconds: 260), value: widget.initialValue ? 1.0 : 0.0);
  late final Animation<double> _thumbSlide = CurvedAnimation(parent: _thumbAc, curve: Curves.easeInOutCubic);

  @override
  void initState() { super.initState(); _isOn = widget.initialValue; }
  @override
  void dispose() { _thumbAc.dispose(); super.dispose(); }
  void _toggle() { setState(() => _isOn = !_isOn); _isOn ? _thumbAc.forward() : _thumbAc.reverse(); widget.onChanged?.call(_isOn); }

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark; // 👈

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(color: widget.iconColor.withOpacity(0.11), borderRadius: BorderRadius.circular(13)),
                child: Icon(widget.icon, color: widget.iconColor, size: 21),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white : FPColors.textDark)), // 👈
                    if (widget.subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(widget.subtitle!, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : FPColors.textMid, fontWeight: FontWeight.w500)), // 👈
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: _toggle,
                child: AnimatedBuilder(
                  animation: _thumbSlide,
                  builder: (_, __) {
                    final double t = _thumbSlide.value;
                    // 👈 خلفية الزر تتجاوب مع الدارك مود
                    final Color trackColor = Color.lerp(isDark ? Colors.grey.shade700 : Colors.grey.shade300, FPColors.primary, t)!;
                    return Container(
                      width: 50, height: 28, padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: trackColor, borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: _isOn ? FPColors.primary.withOpacity(0.28) : Colors.transparent, blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: Align(
                        alignment: Alignment.lerp(Alignment.centerLeft, Alignment.centerRight, t)!,
                        child: Container(
                          width: 22, height: 22,
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        if (widget.showDivider) Divider(height: 1, indent: 76, endIndent: 18, color: context.theme.dividerColor), // 👈
      ],
    );
  }
}