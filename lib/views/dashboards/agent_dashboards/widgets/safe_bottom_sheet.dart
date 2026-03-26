// =============================================================================
//  safe_bottom_sheet.dart
//  Flash Pay — Agent Safe Bottom Sheet  ✅ FIXED
//  ──────────────────────────────────────────────
//  FIX: Removed the outer Obx() wrapper from Get.bottomSheet().
//       Each Rx variable is now wrapped in its own granular Obx() exactly
//       where it is read, which is the only pattern GetX accepts inside
//       bottom sheets / dialogs.
//
//  Reactive variables and where they are observed:
//    controller.isSafeLoading.value     → Obx in _BalanceCard + _SafeHistoryList
//    controller.agentSafeBalance.value  → Obx in _BalanceCard
//    controller.safeTransfers           → Obx in _SafeHistoryList (count + list)
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import 'package:flashpay/controllers/agent_dashboard_controller.dart';
import 'package:flashpay/core/constants.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Public entry-point
// ─────────────────────────────────────────────────────────────────────────────

class AgentSafeSheet {
  AgentSafeSheet._();

  static void show(AgentDashboardController controller) {
    Get.bottomSheet(
      // ✅ FIX: No Obx here. _SafeSheetBody manages its own reactive sections.
      _SafeSheetBody(controller: controller),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Sheet body — purely structural, no Rx reads at this level
// ─────────────────────────────────────────────────────────────────────────────

class _SafeSheetBody extends StatelessWidget {
  final AgentDashboardController controller;
  const _SafeSheetBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    final Color brand = AppColors.primaryGradient.colors.first;
    final bool isDark = context.theme.brightness == Brightness.dark; // 👈 معرفة الثيم

    return Container(
      constraints: BoxConstraints(maxHeight: Get.height * 0.80),
      decoration: BoxDecoration(
        color: context.theme.cardColor, // 👈 خلفية النافذة تتجاوب مع الثيم
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle bar ──────────────────────────────────────────────────
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: context.theme.dividerColor, // 👈 مقبض السحب
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ── Balance card — has its own internal Obx ─────────────────────
          _BalanceCard(controller: controller)
              .animate()
              .fadeIn(duration: 450.ms)
              .slideY(begin: 0.10, curve: Curves.easeOut),

          const SizedBox(height: 24),

          // ── Section header ──────────────────────────────────────────────
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: brand,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'سجل الحوالات في الصندوق',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF1A1A2E), // 👈
                ),
              ),
              const Spacer(),
              // ✅ Obx wraps only the Text that reads safeTransfers.length
              Obx(
                () => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: brand.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${controller.safeTransfers.length}',
                    style: TextStyle(
                      color: brand,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── History list — has its own internal Obx ─────────────────────
          Flexible(child: _SafeHistoryList(controller: controller)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Balance card — Obx wraps only the reactive content inside
// ─────────────────────────────────────────────────────────────────────────────

class _BalanceCard extends StatelessWidget {
  final AgentDashboardController controller;
  const _BalanceCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient, // يبقى كما هو (نصوص بيضاء)
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
          // Decorative circles
          Positioned(
            top: -20, right: -30,
            child: _Bubble(size: 130, opacity: 0.08),
          ),
          Positioned(
            bottom: -25, left: -25,
            child: _Bubble(size: 100, opacity: 0.06),
          ),

          // ✅ Obx wraps only isSafeLoading + agentSafeBalance — the two Rx reads
          Obx(
            () => controller.isSafeLoading.value
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  )
                : Column(
                    children: [
                      const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'رصيد صندوقي',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 6),
                      // ✅ agentSafeBalance.value read inside Obx
                      Text(
                        '${controller.agentSafeBalance.value.toStringAsFixed(2)} USD',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  History list — Obx wraps the entire switch (loading / empty / list)
// ─────────────────────────────────────────────────────────────────────────────

class _SafeHistoryList extends StatelessWidget {
  final AgentDashboardController controller;
  const _SafeHistoryList({required this.controller});

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark; // 👈

    // ✅ Single Obx reads isSafeLoading AND safeTransfers — both are Rx
    return Obx(() {
      // Loading shimmer
      if (controller.isSafeLoading.value) {
        return ListView.separated(
          shrinkWrap: true,
          itemCount: 5,
          separatorBuilder: (_, __) => Divider(height: 1, color: context.theme.dividerColor), // 👈
          itemBuilder: (_, __) => const _SafeRowShimmer(),
        );
      }

      // Empty state
      if (controller.safeTransfers.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 52,
                color: isDark ? Colors.white24 : Colors.grey.shade300, // 👈
              ),
              const SizedBox(height: 12),
              Text(
                'لا توجد سجلات',
                style: TextStyle(
                  color: isDark ? Colors.white54 : Colors.grey.shade500, // 👈
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }

      // Real list
      return ListView.separated(
        shrinkWrap: true,
        itemCount: controller.safeTransfers.length,
        separatorBuilder: (_, __) => Divider(
          height: 1,
          color: context.theme.dividerColor, // 👈
        ),
        itemBuilder: (context, index) {
          final t = controller.safeTransfers[index];
          final bool isApproved = t['status'] == 'approved';
          final Color rowColor = isApproved ? Colors.orange : Colors.blue;

          return _SafeHistoryRow(
            t: t,
            isApproved: isApproved,
            rowColor: rowColor,
          )
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: 60 * index),
                duration: 350.ms,
              )
              .slideX(begin: 0.06, curve: Curves.easeOut);
        },
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Single history row — fully static, no Rx reads
// ─────────────────────────────────────────────────────────────────────────────

class _SafeHistoryRow extends StatelessWidget {
  final Map<String, dynamic> t;
  final bool isApproved;
  final Color rowColor;

  const _SafeHistoryRow({
    required this.t,
    required this.isApproved,
    required this.rowColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color brand = AppColors.primaryGradient.colors.first;
    final bool isDark = context.theme.brightness == Brightness.dark; // 👈

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: rowColor.withOpacity(0.12),
            radius: 22,
            child: Icon(
              isApproved
                  ? Icons.pending_actions_rounded
                  : Icons.send_rounded,
              color: rowColor,
              size: 20,
            ),
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
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E), // 👈
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  t['tracking_code'] ?? '',
                  style: TextStyle(
                    color: isDark ? Colors.white70 : Colors.grey.shade500, // 👈
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${t['amount_in_usd'] ?? '0'} USD',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: brand,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: rowColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isApproved ? 'معلقة' : 'في الطريق',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: rowColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shimmer row placeholder
// ─────────────────────────────────────────────────────────────────────────────

class _SafeRowShimmer extends StatelessWidget {
  const _SafeRowShimmer();

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark; // 👈

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.white10 : const Color(0xFFEEEEEE), // 👈
      highlightColor: isDark ? Colors.white24 : const Color(0xFFF5F5F5), // 👈
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: isDark ? Colors.black : Colors.white, // 👈
              radius: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 13, width: 120, color: isDark ? Colors.black : Colors.white), // 👈
                  const SizedBox(height: 6),
                  Container(height: 10, width: 80, color: isDark ? Colors.black : Colors.white), // 👈
                ],
              ),
            ),
            Container(height: 14, width: 60, color: isDark ? Colors.black : Colors.white), // 👈
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Decorative bubble
// ─────────────────────────────────────────────────────────────────────────────

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