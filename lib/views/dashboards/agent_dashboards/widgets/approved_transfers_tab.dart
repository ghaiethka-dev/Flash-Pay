// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:get/get.dart';
// import 'package:flashpay/controllers/agent_dashboard_controller.dart';
// import 'package:flashpay/core/constants.dart';
//
// import 'transfer_card.dart';
// import 'transfer_details_sheet.dart';
//
// class ApprovedTransfersTab extends StatelessWidget {
//   final AgentDashboardController controller;
//
//   const ApprovedTransfersTab({Key? key, required this.controller}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final Color brand = AppColors.primaryGradient.colors.first;
//     final bool isDark = context.theme.brightness == Brightness.dark;
//
//     return RefreshIndicator(
//       onRefresh: () => controller.fetchAgentTransfers(),
//       color: brand,
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
//         child: Column(
//           crossAxisAliganment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 24),
//             Row(
//               children: [
//                 Container(width: 4, height: 20, decoration: BoxDecoration(color: const Color(0xFF10B981), borderRadius: BorderRadius.circular(4))),
//                 const SizedBox(width: 8),
//                 Text('الحوالات المعلقة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF1F2937))),
//               ],
//             ).animate().fadeIn(delay: 100.ms).slideX(begin: -0.05),
//
//             const SizedBox(height: 16),
//             Expanded(
//               // 🚀 أزلنا الـ Obx من هنا
//               child: _ApprovedList(controller: controller),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _ApprovedList extends StatelessWidget {
//   final AgentDashboardController controller;
//   const _ApprovedList({required this.controller});
//
//   @override
//   Widget build(BuildContext context) {
//     // 🚀 وضعنا الـ Obx هنا بالداخل
//     return Obx(() {
//       if (controller.isLoading.value && controller.approvedTransfers.isEmpty) {
//         return ListView.separated(itemCount: 5, separatorBuilder: (_, __) => const SizedBox(height: 12), itemBuilder: (_, __) => const TransferCardShimmer());
//       }
//       if (controller.approvedTransfers.isEmpty) {
//         return const TransferEmptyState(icon: Icons.pending_actions_rounded, message: 'لا توجد حوالات معلقة');
//       }
//       return ListView.separated(
//         physics: const AlwaysScrollableScrollPhysics(), itemCount: controller.approvedTransfers.length, separatorBuilder: (_, __) => const SizedBox(height: 12),
//         itemBuilder: (context, index) {
//           final transfer = controller.approvedTransfers[index];
//           return TransferCard(
//             transfer: transfer, isActionable: false, animationIndex: index, // False لأنها معلقة
//             onTap: () => TransferDetailsSheet.showApproved(controller, transfer),
//           );
//         },
//       );
//     });
//   }
// }