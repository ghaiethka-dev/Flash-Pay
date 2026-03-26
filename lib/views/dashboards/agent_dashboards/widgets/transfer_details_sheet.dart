// =============================================================================
//  transfer_details_sheet.dart
//  Flash Pay — Transfer Detail Bottom Sheet
//  ──────────────────────────────────────────
//  Renders the full transfer detail sheet used by BOTH:
//    • Incoming transfers  (رفض / موافقة)
//    • Approved transfers  (إلغاء / إرسال إلى المكتب)
// =============================================================================

import 'package:flashpay/data/local/storage_service.dart';
import 'package:flashpay/views/chat/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import 'package:flashpay/controllers/agent_dashboard_controller.dart';
import 'package:flashpay/core/constants.dart';
// 🚀 استيراد شاشة الدردشة

// ─────────────────────────────────────────────────────────────────────────────
//  Public entry-point
// ─────────────────────────────────────────────────────────────────────────────

class TransferDetailsSheet {
  TransferDetailsSheet._();

  /// ✅ Mirrors _showIncomingTransferDetailsSheet — actions: رفض / موافقة
  static void showIncoming(
    AgentDashboardController controller,
    Map<String, dynamic> transfer,
  ) {
    final bool isDark = Get.isDarkMode;

    _show(
      controller: controller, // 👈 تمرير المتحكم ضروري هنا
      transfer: transfer,
      actions: [
        // Reject
        _ActionButton(
          label: 'رفض',
          textColor: isDark ? Colors.redAccent : Colors.red,
          backgroundColor: isDark ? Colors.red.withOpacity(0.15) : Colors.red.shade50, 
          onTap: () => controller.updateTransferStatus(
              transfer['id'], 'rejected'),
        ),
        const SizedBox(width: 14),
        // Approve
        _ActionButton(
          label: 'موافقة',
          textColor: Colors.white,
          backgroundColor: isDark ? Colors.green.shade600 : Colors.green,
          onTap: () => controller.updateTransferStatus(
              transfer['id'], 'approved'),
        ),
      ],
    );
  }

  /// ✅ Mirrors _showApprovedTransferDetailsSheet — actions: إلغاء / إرسال
  static void showApproved(
    AgentDashboardController controller,
    Map<String, dynamic> transfer,
  ) {
    final bool isDark = Get.isDarkMode;

    _show(
      controller: controller, // 👈 تمرير المتحكم ضروري هنا
      transfer: transfer,
      actions: [
        // Cancel
        _ActionButton(
          label: 'إلغاء',
          textColor: isDark ? Colors.white : Colors.black87, 
          backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200, 
          onTap: () => Get.back(), 
        ),
        const SizedBox(width: 14),
        // Send to office
        _ActionButton(
          label: 'إرسال إلى المكتب',
          textColor: Colors.white,
          backgroundColor: AppColors.primaryGradient.colors.first,
          onTap: () => controller.updateTransferStatus(
              transfer['id'], 'waiting'),
        ),
      ],
    );
  }

  // ── Internal sheet builder ─────────────────────────────────────────────────
  static void _show({
    required AgentDashboardController controller, // 👈 أضفنا المتحكم
    required Map<String, dynamic> transfer,
    required List<Widget> actions,
  }) {
    Get.bottomSheet(
      _DetailsSheetBody(
        controller: controller, // 👈 تمريره للبودي
        transfer: transfer, 
        actions: actions
      ),
      isScrollControlled: true, 
      backgroundColor: Colors.transparent,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Sheet body
// ─────────────────────────────────────────────────────────────────────────────

class _DetailsSheetBody extends StatelessWidget {
  final AgentDashboardController controller; // 👈 استلام المتحكم لمعرفة الـ User ID
  final Map<String, dynamic> transfer;
  final List<Widget> actions;

  const _DetailsSheetBody({
    required this.controller,
    required this.transfer,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final Color brand = AppColors.primaryGradient.colors.first;
    final bool isDark = context.theme.brightness == Brightness.dark; 

    // ─── Pre-compute all displayed values 
    final String trackingCode = transfer['tracking_code'] ?? '#';
    final String senderName = transfer['sender'] != null
        ? transfer['sender']['name'] ?? 'غير معروف'
        : 'غير معروف';
    final String senderPhone = transfer['sender'] != null
        ? transfer['sender']['phone'] ?? 'غير معروف'
        : 'غير معروف';
    final String receiverName = transfer['receiver_name'] ?? 'غير معروف';
    final String receiverPhone = transfer['receiver_phone'] ?? 'غير معروف';

    final String amountSend =
        '${transfer['amount']} ${transfer['send_currency'] != null ? transfer['send_currency']['code'] : 'eur'}';
    final String amountUsd =
        '${transfer['amount_in_usd'] ?? '0.00'} USD';
    final String amountReceive = (() {
      if (transfer['amount_in_usd'] != null &&
          transfer['currency'] != null &&
          transfer['currency']['price'] != null) {
        final double usd = double.parse(
            transfer['amount_in_usd'].toString());
        final double price = double.parse(
            transfer['currency']['price'].toString());
        final String code =
            transfer['currency']['code']?.toString() ?? '';
        return '${(usd * price).toStringAsFixed(2)} $code';
      }
      return '0.00';
    })();

    return Container(
      decoration: BoxDecoration(
        color: context.theme.cardColor, 
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // مقبض السحب العلوي
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

          // 🚀 Sheet title + زر الشات
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: brand.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.swap_horiz_rounded, color: brand, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded( // 👈 Expanded لكي يأخذ الزر أقصى اليسار
                child: Text(
                  'تفاصيل الحوالة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF1A1A2E), 
                  ),
                ),
              ),
              // ==========================================
              // 🚀 زر فتح المحادثة للوكيل
              // ==========================================
              Container(
                decoration: BoxDecoration(
                  color: brand.withOpacity(isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(Icons.chat_bubble_outline_rounded, color: brand),
                  tooltip: 'تواصل مع المُرسل',
                  onPressed: () {
                    // نجلب الـ currentUserId من خدمة التخزين (StorageService)
                    // افترضنا هنا وجود الدالة getUserId() في خدمة التخزين الخاصة بك
                    final currentUserId = Get.find<StorageService>().getUserId() ?? 0; // 👈 ديناميكي
                    
                    Get.to(() => ChatScreen(
                      transferId: transfer['id'], // 👈 ديناميكي من بيانات الحوالة
                      trackingCode: trackingCode, // 👈 ديناميكي
                      currentUserId: currentUserId, 
                    ));
                  },
                ),
              ),
              // ==========================================
            ],
          )
              .animate()
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.06, curve: Curves.easeOut),

          const SizedBox(height: 20),

          // ── Section: Sender ──────────────────────────────────────────────
          const _SectionHeader(label: 'بيانات المرسل', icon: Icons.person_outline_rounded),
          const SizedBox(height: 10),
          _DetailRow(title: 'رقم التتبع:', value: trackingCode),     
          _DetailRow(title: 'المرسل:', value: senderName),           
          _DetailRow(title: 'هاتف المرسل:', value: senderPhone),     

          const SizedBox(height: 16),
          Divider(color: context.theme.dividerColor), 
          const SizedBox(height: 12),

          // ── Section: Receiver ────────────────────────────────────────────
          const _SectionHeader(label: 'بيانات المستلم', icon: Icons.person_pin_outlined),
          const SizedBox(height: 10),
          _DetailRow(title: 'المستلم:', value: receiverName),       
          _DetailRow(title: 'هاتف المستلم:', value: receiverPhone), 

          const SizedBox(height: 16),
          Divider(color: context.theme.dividerColor), 
          const SizedBox(height: 12),

          // ── Section: Amounts (3 highlighted rows) ────────────────────────
          const _SectionHeader(
              label: 'تفاصيل المبالغ',
              icon: Icons.monetization_on_outlined),
          const SizedBox(height: 10),
          _AmountCard(
              label: 'المبلغ بعملة الإرسال:',
              value: amountSend,
              color: brand),                         
          const SizedBox(height: 10),
          _AmountCard(
              label: 'المبلغ بالدولار:',
              value: amountUsd,
              color: Colors.green),                  
          const SizedBox(height: 10),
          _AmountCard(
              label: 'المبلغ بعملة الاستلام:',
              value: amountReceive,
              color: Colors.blue),                   

          const SizedBox(height: 28),

          // ── Action buttons ────────────────────────────────────────────────
          Row(children: actions)
              .animate()
              .fadeIn(delay: 200.ms, duration: 350.ms)
              .slideY(begin: 0.08, curve: Curves.easeOut),
        ],
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String label;
  final IconData icon;
  const _SectionHeader({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark; 

    return Row(
      children: [
        Icon(icon, size: 16, color: isDark ? Colors.white54 : const Color(0xFF6B7280)), 
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white54 : const Color(0xFF6B7280), 
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

// ─── Regular detail row ───────────────────────────────────────────────────────
class _DetailRow extends StatelessWidget {
  final String title;
  final String value;

  const _DetailRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark; 

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey.shade600, 
              fontSize: 14,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87, 
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Highlighted amount card ──────────────────────────────────────────────────
class _AmountCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _AmountCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark; 

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.06), 
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(isDark ? 0.30 : 0.18), width: 1), 
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white70 : Colors.grey.shade600, 
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18, 
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Scale-bounce action button ───────────────────────────────────────────────
class _ActionButton extends StatefulWidget {
  final String label;
  final Color textColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.textColor,
    required this.backgroundColor,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
    reverseDuration: const Duration(milliseconds: 180),
    lowerBound: 0.0,
    upperBound: 0.030,
  );

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => _ac.forward(),
        onTapUp: (_) {
          _ac.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ac.reverse(),
        child: AnimatedBuilder(
          animation: _ac,
          builder: (_, child) =>
              Transform.scale(scale: 1.0 - _ac.value, child: child),
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: widget.backgroundColor.withOpacity(0.20),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ]
            ),
            alignment: Alignment.center,
            child: Text(
              widget.label,
              style: TextStyle(
                color: widget.textColor,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}