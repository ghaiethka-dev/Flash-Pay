import 'package:flutter/material.dart';
import 'package:get/get.dart'; // 👈 ضروري
import 'fp_theme.dart';

class SectionTitle extends StatelessWidget {
  final String label;

  const SectionTitle({Key? key, required this.label}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark; // 👈

    return Text(
      label, 
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: isDark ? Colors.white : FPColors.textDark, // 👈
        letterSpacing: 0.2,
      ),
    );
  }
}