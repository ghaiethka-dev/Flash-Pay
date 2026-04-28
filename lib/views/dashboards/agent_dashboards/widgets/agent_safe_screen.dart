// =============================================================================
//  agent_safe_screen.dart  — شاشة صندوق المندوب المحدثة
//  ─────────────────────────────────────────────────────
//  تعرض:
//    • بطاقة رئيسية: الرصيد الأساسي + إجمالي الأرباح + نسبة الربح
//    • تبويبان: "سجل الحوالات" و "ملخص الأرباح"
//    • أنيميشن سلس، Shimmer Loading، و Pull-to-refresh
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import 'package:flashpay/controllers/agent_dashboard_controller.dart';
import 'package:flashpay/core/constants.dart';

class AgentSafeScreen extends StatefulWidget {
  const AgentSafeScreen({Key? key}) : super(key: key);

  @override
  State<AgentSafeScreen> createState() => _AgentSafeScreenState();
}

class _AgentSafeScreenState extends State<AgentSafeScreen>
    with SingleTickerProviderStateMixin {
  late final AgentDashboardController _c;
  late final TabController _tab;

  @override
  void initState() {
    super.initState();
    // استخدام Get.find لجلب الكنترولر الموجود مسبقاً في الذاكرة
    _c = Get.find<AgentDashboardController>();
    _tab = TabController(length: 2, vsync: this);

    // جلب البيانات عند فتح الشاشة باستخدام الدالة الصحيحة من الكنترولر
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _c.fetchAgentSafe();
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color brand = AppColors.primaryGradient.colors.first;
    final bool isDark = context.theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        body: RefreshIndicator(
          color: brand,
          // استخدام fetchAgentSafe بدلاً من loadAgentSafe
          onRefresh: () async => await _c.fetchAgentSafe(),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              // ── شريط علوي (AppBar) مع تدرج لوني ──────────────────────────────
              SliverAppBar(
                expandedHeight: 0,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: Container(
                  decoration: BoxDecoration(gradient: AppColors.primaryGradient),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () => Get.back(),
                ),
                title: const Text(
                  'صندوقي المالي',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                  ),
                ),
                centerTitle: true,
                actions: [
                  Obx(() => _c.isSafeLoading.value
                      ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    ),
                  )
                      : IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                    onPressed: () => _c.fetchAgentSafe(),
                  )),
                ],
              ),

              // ── بطاقة الأرقام الرئيسية (الرصيد، الأرباح، النسبة) ─────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: _MainBalanceCard(c: _c),
                ),
              ),

              // ── شريط التبويبات (Tabs) ────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: TabBar(
                      controller: _tab,
                      indicatorColor: brand,
                      labelColor: brand,
                      unselectedLabelColor: isDark ? Colors.white54 : Colors.grey,
                      indicatorWeight: 3,
                      labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      tabs: const [
                        Tab(
                          icon: Icon(Icons.receipt_long_rounded, size: 18),
                          text: 'سجل الحوالات',
                        ),
                        Tab(
                          icon: Icon(Icons.bar_chart_rounded, size: 18),
                          text: 'ملخص الأرباح',
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── محتوى التبويبات (TabBarView) ─────────────────────────────────
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tab,
                  children: [
                    _TransfersTab(c: _c, isDark: isDark, brand: brand),
                    _ProfitSummaryTab(c: _c, isDark: isDark, brand: brand),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  بطاقة الأرقام الرئيسية
// ─────────────────────────────────────────────────────────────────────────────
class _MainBalanceCard extends StatelessWidget {
  final AgentDashboardController c;
  const _MainBalanceCard({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGradient.colors.first.withOpacity(0.35),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // زخارف دائرية في الخلفية
          Positioned(
            top: -30, right: -40,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.07)),
            ),
          ),
          Positioned(
            bottom: -40, left: -20,
            child: Container(
              width: 130, height: 130,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.05)),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Obx(() {
              if (c.isSafeLoading.value) {
                return const SizedBox(
                  height: 160,
                  child: Center(child: CircularProgressIndicator(color: Colors.white)),
                );
              }

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'الرصيد الكلي في الصندوق',
                    style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${c.agentSafeBalance.value.toStringAsFixed(2)} USD',
                    style: const TextStyle(
                      color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 20),

                  // صف الإحصائيات للأرباح ونسبة الربح فقط
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(
                        icon: Icons.trending_up_rounded,
                        label: 'إجمالي الأرباح',
                        value: '\$${c.agentProfitTotal.value.toStringAsFixed(2)}',
                        color: const Color(0xFF34D399),
                      ),
                      Container(width: 1, height: 50, color: Colors.white24),
                      _StatItem(
                        icon: Icons.percent_rounded,
                        label: 'نسبة الربح',
                        value: '${c.agentProfitRatio.value.toStringAsFixed(1)}%',
                        color: const Color(0xFFFFD166),
                      ),
                    ],
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08);
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 3),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 16)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  تبويب السجل (سجل الحوالات)
// ─────────────────────────────────────────────────────────────────────────────
class _TransfersTab extends StatelessWidget {
  final AgentDashboardController c;
  final bool isDark;
  final Color brand;

  const _TransfersTab({required this.c, required this.isDark, required this.brand});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Obx(() {
        if (c.isSafeLoading.value) {
          return ListView.separated(
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, __) => _TransferShimmer(isDark: isDark),
          );
        }

        if (c.safeTransfers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_rounded, size: 64, color: isDark ? Colors.white24 : Colors.grey.shade300),
                const SizedBox(height: 14),
                Text(
                  'لا توجد حوالات في السجل حتى الآن',
                  style: TextStyle(
                      color: isDark ? Colors.white38 : Colors.grey.shade500,
                      fontSize: 15,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          physics: const BouncingScrollPhysics(),
          itemCount: c.safeTransfers.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (ctx, i) {
            final t = c.safeTransfers[i];
            return _TransferCard(t: t, isDark: isDark, brand: brand)
                .animate()
                .fadeIn(delay: Duration(milliseconds: 50 * i), duration: 350.ms)
                .slideX(begin: 0.05, curve: Curves.easeOut);
          },
        );
      }),
    );
  }
}

class _TransferCard extends StatelessWidget {
  final Map<String, dynamic> t;
  final bool isDark;
  final Color brand;

  const _TransferCard({required this.t, required this.isDark, required this.brand});

  Color get _statusColor {
    switch (t['status'] ?? '') {
      case 'ready': return const Color(0xFF10B981);
      case 'waiting': return const Color(0xFFF59E0B);
      case 'approved': return const Color(0xFF3B82F6);
      default: return Colors.grey;
    }
  }

  String get _statusLabel {
    switch (t['status'] ?? '') {
      case 'ready': return 'جاهز للتسليم';
      case 'waiting': return 'قيد الانتظار';
      case 'approved': return 'تم الاعتماد';
      default: return t['status'] ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double amountUsd =
        double.tryParse(t['amount_in_usd']?.toString() ?? '0') ?? 0;

    // ✅ اقرأ agent_profit بدل fee
    final double agentProfit =
        double.tryParse(t['agent_profit']?.toString() ?? '0') ?? 0;

    final String tracking = t['tracking_code'] ?? '#${t['id']}';
    final String receiver = t['receiver_name'] ?? '—';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.send_rounded, color: _statusColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  receiver,
                  style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tracking,
                  style: TextStyle(color: isDark ? Colors.white54 : Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500),
                ),
                if (agentProfit > 0) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.attach_money_rounded,
                          color: Color(0xFF10B981), size: 13),
                      Text(
                        'ربحي: \$${agentProfit.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('\$${amountUsd.toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w800, color: brand, fontSize: 15)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: _statusColor.withOpacity(0.10), borderRadius: BorderRadius.circular(8)),
                child: Text(_statusLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _statusColor)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TransferShimmer extends StatelessWidget {
  final bool isDark;
  const _TransferShimmer({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.white10 : const Color(0xFFEEEEEE),
      highlightColor: isDark ? Colors.white : const Color(0xFFF5F5F5),
      child: Container(height: 80, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16))),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  تبويب ملخص الأرباح
// ─────────────────────────────────────────────────────────────────────────────
class _ProfitSummaryTab extends StatelessWidget {
  final AgentDashboardController c;
  final bool isDark;
  final Color brand;

  const _ProfitSummaryTab({required this.c, required this.isDark, required this.brand});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Obx(() {
        if (c.isSafeLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final double profit = c.agentProfitTotal.value;
        final double ratio = c.agentProfitRatio.value;

        return ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            _ProfitStatCard(
              isDark: isDark,
              icon: Icons.percent_rounded,
              iconBg: const Color(0xFFFEF3C7),
              iconColor: const Color(0xFFF59E0B),
              title: 'نسبة الربح المحددة',
              value: '${ratio.toStringAsFixed(1)}%',
              subtitle: 'نسبة الأرباح المحتسبة لك من الحوالات',
            ).animate().fadeIn(duration: 350.ms).slideX(begin: 0.06),

            const SizedBox(height: 12),

            _ProfitStatCard(
              isDark: isDark,
              icon: Icons.trending_up_rounded,
              iconBg: const Color(0xFFD1FAE5),
              iconColor: const Color(0xFF10B981),
              title: 'إجمالي الأرباح',
              value: '\$${profit.toStringAsFixed(2)}',
              subtitle: 'مجموع أرباحك المتراكمة حتى الآن',
            ).animate().fadeIn(delay: 80.ms, duration: 350.ms).slideX(begin: 0.06),

            const SizedBox(height: 20),

            // تنويه لتوضيح طريقة الحساب
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: brand.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: brand.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: brand, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'يتم احتساب ربحك تلقائياً بنسبة ${ratio.toStringAsFixed(1)}% من قيمة كل حوالة مرسلة ومُعتمدة.',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : const Color(0xFF374151),
                        fontSize: 13, fontWeight: FontWeight.w500, height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 160.ms, duration: 350.ms),
          ],
        );
      }),
    );
  }
}

class _ProfitStatCard extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;

  const _ProfitStatCard({
    required this.isDark, required this.icon, required this.iconBg,
    required this.iconColor, required this.title, required this.value, required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(isDark ? 0.2 : 0.05), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: isDark ? Colors.white54 : Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                Text(value, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1A1A2E), fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: isDark ? Colors.white38 : Colors.grey.shade400, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}