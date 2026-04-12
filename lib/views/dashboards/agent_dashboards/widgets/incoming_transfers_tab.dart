import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:flashpay/controllers/agent_dashboard_controller.dart';
import 'package:flashpay/core/constants.dart';

import 'agent_safe_button.dart';
import 'safe_bottom_sheet.dart';
import 'transfer_card.dart';
import 'transfer_details_sheet.dart';

class IncomingTransfersTab extends StatelessWidget {
  final AgentDashboardController controller;

  const IncomingTransfersTab({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color brand = AppColors.primaryGradient.colors.first;
    final bool isDark = context.theme.brightness == Brightness.dark;

    return RefreshIndicator(
      onRefresh: () => controller.fetchAgentTransfers(),
      color: brand,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('مرحباً،', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : const Color(0xFF6B7280))),
            Obx(() => Text(
              controller.agentName.value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF1F2937), letterSpacing: 0.5),
            )),
            
            const SizedBox(height: 24),
            AgentSafeButton(onTap: () {
              controller.fetchAgentSafe();
              AgentSafeSheet.show(controller);
            }).animate().fadeIn(duration: 400.ms).slideY(begin: 0.05),
            
            const SizedBox(height: 32),
            Row(
              children: [
                Container(width: 4, height: 20, decoration: BoxDecoration(color: brand, borderRadius: BorderRadius.circular(4))),
                const SizedBox(width: 8),
                Text('طلبات الحوالات الجديدة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF1F2937))),
              ],
            ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.05),
            
            const SizedBox(height: 16),
            Expanded(
              // 🚀 أزلنا الـ Obx من هنا (لأنه استدعاء لكلاس خارجي)
              child: _IncomingList(controller: controller),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncomingList extends StatelessWidget {
  final AgentDashboardController controller;
  const _IncomingList({required this.controller});

  @override
  Widget build(BuildContext context) {
    // 🚀 وضعنا الـ Obx هنا بالداخل ليراقب المتغيرات مباشرة
    return Obx(() {
      if (controller.isLoading.value && controller.incomingTransfers.isEmpty) {
        return ListView.separated(itemCount: 5, separatorBuilder: (_, __) => const SizedBox(height: 12), itemBuilder: (_, __) => const TransferCardShimmer());
      }
      if (controller.incomingTransfers.isEmpty) {
        return const TransferEmptyState(icon: Icons.move_to_inbox_rounded, message: 'لا توجد طلبات جديدة');
      }
      return ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(), itemCount: controller.incomingTransfers.length, separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final transfer = controller.incomingTransfers[index];
          return TransferCard(
            transfer: transfer, isActionable: true, animationIndex: index,
            onTap: () => TransferDetailsSheet.showIncoming(controller, transfer),
          );
        },
      );
    });
  }
}