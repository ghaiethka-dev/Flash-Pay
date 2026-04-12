import 'package:flutter/material.dart';
import 'package:get/get.dart'; // 👈
import '../../dashboards/user_dashboards/widgets/fp_theme.dart';

class CustomSettingsTile extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool showDivider;
  final bool isDestructive;

  const CustomSettingsTile({
    Key? key, required this.icon, required this.iconColor, required this.title,
    this.subtitle, required this.onTap, this.showDivider = true, this.isDestructive = false,
  }) : super(key: key);

  @override
  State<CustomSettingsTile> createState() => _CustomSettingsTileState();
}

class _CustomSettingsTileState extends State<CustomSettingsTile> with SingleTickerProviderStateMixin {
  late final AnimationController _scaleAc = AnimationController(vsync: this, duration: const Duration(milliseconds: 100), reverseDuration: const Duration(milliseconds: 180), lowerBound: 0.0, upperBound: 0.025);

  @override
  void dispose() { _scaleAc.dispose(); super.dispose(); }
  void _onTapDown(_) => _scaleAc.forward();
  void _onTapUp(_) { _scaleAc.reverse(); widget.onTap(); }
  void _onTapCancel() => _scaleAc.reverse();

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark; // 👈
    final Color titleColor = widget.isDestructive ? Colors.red : (isDark ? Colors.white : FPColors.textDark); // 👈

    return Column(
      children: [
        GestureDetector(
          onTapDown: _onTapDown, onTapUp: _onTapUp, onTapCancel: _onTapCancel,
          child: AnimatedBuilder(
            animation: _scaleAc,
            builder: (_, child) => Transform.scale(scale: 1.0 - _scaleAc.value, child: child),
            child: Padding(
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
                        Text(widget.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: titleColor)),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 3),
                          Text(widget.subtitle!, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : FPColors.textMid, fontWeight: FontWeight.w500)), // 👈
                        ],
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 15, color: widget.isDestructive ? Colors.red.withOpacity(0.50) : (isDark ? Colors.white38 : FPColors.textLight)), // 👈
                ],
              ),
            ),
          ),
        ),
        if (widget.showDivider) Divider(height: 1, indent: 76, endIndent: 18, color: context.theme.dividerColor), // 👈
      ],
    );
  }
}