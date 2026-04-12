// agent_app_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flashpay/core/constants.dart';

class AgentAppBar extends StatefulWidget implements PreferredSizeWidget {
  // إضافة callback للضغط على زر الصندوق
  final VoidCallback onSafeTap;

  const AgentAppBar({Key? key, required this.onSafeTap}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<AgentAppBar> createState() => _AgentAppBarState();
}

class _AgentAppBarState extends State<AgentAppBar> with SingleTickerProviderStateMixin {
  late final AnimationController _pulseAc = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulseAc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(gradient: AppColors.primaryGradient),
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false, // نغيرها لـ false لترك مساحة للأيقونات
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.admin_panel_settings_rounded, color: Color(0xFFFFD166), size: 22),
          const SizedBox(width: 8),
          const Text(
            'لوحة الوكيل',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18),
          ),
        ],
      ),
      actions: [
        // زر الصندوق الجديد داخل الـ AppBar
        IconButton(
          icon: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white),
          onPressed: widget.onSafeTap,
          tooltip: 'صندوقي',
        ),
        // مؤشر متصل
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              AnimatedBuilder(
                animation: _pulseAc,
                builder: (_, __) => Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF34D399),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF34D399).withOpacity(0.4 + _pulseAc.value * 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Text('متصل', style: TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}