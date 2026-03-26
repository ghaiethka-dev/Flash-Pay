import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../dashboards/user_dashboards/widgets/fp_theme.dart';
import 'transfer_item_card.dart';

class TransferHistorySection extends StatelessWidget {
  final List<Map<String, dynamic>> transfers;

  const TransferHistorySection({Key? key, required this.transfers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 4, height: 22, decoration: BoxDecoration(color: FPColors.primary, borderRadius: BorderRadius.circular(4))),
            const SizedBox(width: 10),
            Text(
              'سجل الحوالات',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: isDark ? Colors.white : FPColors.textDark, letterSpacing: 0.2), // 👈 تغيير هنا
            ),
          ],
        ),
        const SizedBox(height: 16),
        transfers.isEmpty ? _EmptyTransfersState() : _TransferList(transfers: transfers),
      ],
    );
  }
}

class _EmptyTransfersState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: FPColors.primary.withOpacity(0.07), shape: BoxShape.circle),
              child: const Icon(Icons.history_rounded, size: 52, color: FPColors.primary),
            ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.7, 0.7), curve: Curves.easeOutBack),
            const SizedBox(height: 18),
            Text(
              'لا يوجد سجل حوالات حتى الآن',
              style: TextStyle(color: isDark ? Colors.white70 : FPColors.textMid, fontSize: 15, fontWeight: FontWeight.w600), // 👈 تغيير هنا
            ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(begin: 0.10),
            const SizedBox(height: 8),
            Text(
              'ستظهر هنا حوالاتك بعد أول تحويل',
              style: TextStyle(color: isDark ? Colors.white38 : FPColors.textLight, fontSize: 13), // 👈 تغيير هنا
            ).animate().fadeIn(delay: 240.ms, duration: 400.ms).slideY(begin: 0.10),
          ],
        ),
      ),
    );
  }
}

class _TransferList extends StatelessWidget {
  final List<Map<String, dynamic>> transfers;
  const _TransferList({required this.transfers});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transfers.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final int delayMs = 80 + (index * 70);
        return TransferItemCard(transfer: transfers[index]).animate().fadeIn(delay: Duration(milliseconds: delayMs), duration: 450.ms).slideY(begin: 0.12, curve: Curves.easeOut);
      },
    );
  }
}