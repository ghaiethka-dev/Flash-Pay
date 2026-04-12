import 'package:flutter/material.dart';
import 'package:get/get.dart'; // 👈 ضروري للثيم
import '../../dashboards/user_dashboards/widgets/fp_theme.dart';

class SettingsSectionCard extends StatelessWidget {
  final String title;
  final IconData titleIcon;
  final Color iconColor;
  final List<Widget> children;

  const SettingsSectionCard({
    Key? key,
    required this.title,
    required this.titleIcon,
    required this.iconColor,
    required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark; // 👈

    return Container(
      decoration: BoxDecoration(
        color: context.theme.cardColor, // 👈 يتغير حسب الثيم
        borderRadius: BorderRadius.circular(24),
        boxShadow: FPShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(titleIcon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : FPColors.textDark, // 👈
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: context.theme.dividerColor), // 👈
          ...children,
        ],
      ),
    );
  }
}