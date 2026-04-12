// =============================================================================
//  safe_bottom_sheet.dart  — UPDATED v2
//  ─────────────────────────────────────
//  جديد:
//    • بطاقة الرصيد تعرض الرصيد الكلي + إجمالي الأرباح + نسبة الربح
//    • لون أخضر للأرباح، مع أيقونة نسبة مئوية
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import 'package:flashpay/controllers/agent_dashboard_controller.dart';
import 'package:flashpay/core/constants.dart';

class AgentSafeSheet {
  AgentSafeSheet._();

  static void show(AgentDashboardController controller) {
    Get.bottomSheet(
      _SafeSheetBody(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _SafeSheetBody extends StatelessWidget {
  final AgentDashboardController controller;
  const _SafeSheetBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    final Color brand = AppColors.primaryGradient.colors.first;
    final bool isDark = context.theme.brightness == Brightness.dark;

    return Container(
      constraints: BoxConstraints(maxHeight: Get.height * 0.85),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: context.theme.dividerColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── بطاقة الرصيد والأرباح ──
          _BalanceCard(controller: controller)
              .animate()
              .fadeIn(duration: 450.ms)
              .slideY(begin: 0.10, curve: Curves.easeOut),

          const SizedBox(height: 24),

          // ── رأس قسم السجل ──
          // Row(
          //   children: [
          //     Container(
          //       width: 4,
          //       height: 20,
          //       decoration: BoxDecoration(
          //         color: brand,
          //         borderRadius: BorderRadius.circular(4),
          //       ),
          //     ),
          //     const SizedBox(width: 10),
          //     Text(
          //       'سجل الحوالات',
          //       style: TextStyle(
          //         fontSize: 16,
          //         fontWeight: FontWeight.w800,
          //         color: isDark ? Colors.white : const Color(0xFF1A1A2E),
          //       ),
          //     ),
          //     const Spacer(),
          //     Obx(() => Container(
          //       padding: const EdgeInsets.symmetric(
          //           horizontal: 10, vertical: 4),
          //       decoration: BoxDecoration(
          //         color: brand.withOpacity(0.10),
          //         borderRadius: BorderRadius.circular(12),
          //       ),
          //       child: Text(
          //         '${controller.safeTransfers.length}',
          //         style: TextStyle(
          //             color: brand,
          //             fontWeight: FontWeight.w800,
          //             fontSize: 13),
          //       ),
          //     )),
          //   ],
          // ),

          const SizedBox(height: 14),

          // Flexible(child: _SafeHistoryList(controller: controller)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  بطاقة الرصيد — تعرض الرصيد + الأرباح + نسبة الربح
// ─────────────────────────────────────────────────────────────────────────────
class _BalanceCard extends StatelessWidget {
  final AgentDashboardController controller;
  const _BalanceCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGradient.colors.first.withOpacity(0.36),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
              top: -20,
              right: -30,
              child: _Bubble(size: 130, opacity: 0.08)),
          Positioned(
              bottom: -25,
              left: -25,
              child: _Bubble(size: 100, opacity: 0.06)),
          Obx(() => controller.isSafeLoading.value
              ? const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: Colors.white),
            ),
          )
              : Column(
            children: [
              const Icon(Icons.account_balance_wallet_rounded,
                  color: Colors.white, size: 36),
              const SizedBox(height: 8),

              // ── الرصيد الكلي ──
              const Text(' صندوقي',
                  style:
                  TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),


              const SizedBox(height: 16),
              const Divider(color: Colors.white24, height: 1),
              const SizedBox(height: 16),

              // ── صف الأرباح + نسبة الربح ──
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // إجمالي الأرباح
                  _StatChip(
                    icon: Icons.trending_up_rounded,
                    label: 'إجمالي أرباحي',
                    value:
                    '\$${controller.agentProfitTotal.value.toStringAsFixed(2)}',
                    color: Colors.greenAccent,
                  ),
                  // فاصل عمودي
                  Container(
                      height: 40,
                      width: 1,
                      color: Colors.white24),
                  // نسبة الربح
                  _StatChip(
                    icon: Icons.percent_rounded,
                    label: 'نسبة ربحي',
                    value:
                    '${controller.agentProfitRatio.value.toStringAsFixed(1)}%',
                    color: Colors.amberAccent,
                  ),
                ],
              ),
            ],
          )),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                color: color, fontWeight: FontWeight.w800, fontSize: 16)),
      ],
    );
  }
}
//
// // ─────────────────────────────────────────────────────────────────────────────
// class _SafeHistoryList extends StatelessWidget {
//   final AgentDashboardController controller;
//   const _SafeHistoryList({required this.controller});
//
//   @override
//   Widget build(BuildContext context) {
//     final bool isDark = context.theme.brightness == Brightness.dark;
//
//     return Obx(() {
//       if (controller.isSafeLoading.value) {
//         return ListView.separated(
//           shrinkWrap: true,
//           itemCount: 5,
//           separatorBuilder: (_, __) =>
//               Divider(height: 1, color: context.theme.dividerColor),
//           itemBuilder: (_, __) => const _SafeRowShimmer(),
//         );
//       }
//
//       if (controller.safeTransfers.isEmpty) {
//         return Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Icon(Icons.receipt_long_rounded,
//                   size: 52,
//                   color: isDark ? Colors.white24 : Colors.grey.shade300),
//               const SizedBox(height: 12),
//               Text('لا توجد سجلات',
//                   style: TextStyle(
//                       color: isDark ? Colors.white54 : Colors.grey.shade500,
//                       fontSize: 14)),
//             ],
//           ),
//         );
//       }
//
//       return ListView.separated(
//         shrinkWrap: true,
//         itemCount: controller.safeTransfers.length,
//         separatorBuilder: (_, __) =>
//             Divider(height: 1, color: context.theme.dividerColor),
//         itemBuilder: (context, index) {
//           final t = controller.safeTransfers[index];
//           final String status = t['status'] ?? '';
//           final bool isReady = status == 'ready';
//           final Color rowColor = isReady ? Colors.green : Colors.orange;
//
//           return _SafeHistoryRow(t: t, rowColor: rowColor, status: status)
//               .animate()
//               .fadeIn(delay: Duration(milliseconds: 60 * index), duration: 350.ms)
//               .slideX(begin: 0.06, curve: Curves.easeOut);
//         },
//       );
//     });
//   }
// }

class _SafeHistoryRow extends StatelessWidget {
  final Map<String, dynamic> t;
  final Color rowColor;
  final String status;

  const _SafeHistoryRow({
    required this.t,
    required this.rowColor,
    required this.status,
  });

  String get _statusLabel {
    switch (status) {
      case 'ready':
        return 'جاهز';
      case 'waiting':
        return 'في الانتظار';
      case 'approved':
        return 'معتمد';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color brand = AppColors.primaryGradient.colors.first;
    final bool isDark = context.theme.brightness == Brightness.dark;
    final double amount = double.tryParse(t['amount_in_usd']?.toString() ?? '0') ?? 0.0;

    // الآن يمكنك استخدام المقارنة دون خوف من الخطأ
    final bool isPositive = amount > 0;
    final Color color = isPositive ? Colors.green : Colors.red;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: rowColor.withOpacity(0.12),
            radius: 22,
            child: Icon(Icons.send_rounded, color: rowColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t['receiver_name'] ?? '',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isDark
                          ? Colors.white
                          : const Color(0xFF1A1A2E)),
                ),
                const SizedBox(height: 2),
                Text(
                  t['tracking_code'] ?? '',
                  style: TextStyle(
                      color: isDark
                          ? Colors.white70
                          : Colors.grey.shade500,
                      fontSize: 11,
                      fontWeight: FontWeight.w500),
                ),
                // ربح الحوالة إن وُجد
                if (t['fee']  > 0) ...[
                  const SizedBox(height: 2),
                  Text(
                    'ربح: \$${double.tryParse(t['fee'].toString())?.toStringAsFixed(2) ?? '0.00'}',
                    style: const TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${amount ?? '0'} USD',
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: brand,
                    fontSize: 14),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: rowColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusLabel,
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: rowColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SafeRowShimmer extends StatelessWidget {
  const _SafeRowShimmer();

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.white10 : const Color(0xFFEEEEEE),
      highlightColor: isDark ? Colors.white24 : const Color(0xFFF5F5F5),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
                backgroundColor:
                isDark ? Colors.black : Colors.white,
                radius: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                      height: 13,
                      width: 120,
                      color: isDark ? Colors.black : Colors.white),
                  const SizedBox(height: 6),
                  Container(
                      height: 10,
                      width: 80,
                      color: isDark ? Colors.black : Colors.white),
                ],
              ),
            ),
            Container(
                height: 14,
                width: 60,
                color: isDark ? Colors.black : Colors.white),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final double size;
  final double opacity;
  const _Bubble({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Colors.white.withOpacity(opacity),
    ),
  );
}