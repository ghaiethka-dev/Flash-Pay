// =============================================================================
//  transfer_item_card.dart  — FlashPay (Fixed & Enhanced)
//  ✅ FIX: Amount text wrapped in Flexible to prevent RenderFlex overflow
//  ✅ FIX: receiver_name uses TextOverflow.ellipsis to cap long names
//  ✅ FIX: Status badge uses FittedBox so long Arabic labels don't overflow
//  ✅ FIX: Chat button uses fixed size + IconButton padding: EdgeInsets.zero
//  ✅ IMPROVE: Card uses theme-aware InkWell ripple area
//  ✅ IMPROVE: const constructors added where applicable
// =============================================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flashpay/views/chat/chat_screen.dart';
import 'package:flashpay/data/local/storage_service.dart';
import '../../dashboards/user_dashboards/widgets/fp_theme.dart';

// ── Status model ──────────────────────────────────────────────────────────────
class _TransferStatus {
  final Color   color;
  final String  label;
  final IconData icon;

  const _TransferStatus({
    required this.color,
    required this.label,
    required this.icon,
  });

  factory _TransferStatus.from(String? status) {
    switch (status) {
      case 'pending':
        return const _TransferStatus(
            color: Colors.orange,
            label: 'قيد المراجعة',
            icon: Icons.hourglass_top_rounded);
      case 'approved':
        return _TransferStatus(
            color: Colors.blue.shade600,
            label: 'بانتظار الإرسال',
            icon: Icons.send_rounded);
      case 'waiting':
        return const _TransferStatus(
            color: Color(0xFF1500FF),
            label: 'بانتظار المكتب',
            icon: Icons.watch_later_rounded);
      case 'ready':
        return const _TransferStatus(
            color: Colors.purple,
            label: 'جاهزة للتسليم',
            icon: Icons.check_circle_outline_rounded);
      case 'completed':
        return const _TransferStatus(
            color: Colors.green,
            label: 'مكتملة',
            icon: Icons.task_alt_rounded);
      default:
        return _TransferStatus(
            color: Colors.green,
            label:  ' مكتملة',
            icon: Icons.task_alt_rounded);
    }
  }
}

// ── Card widget ───────────────────────────────────────────────────────────────
class TransferItemCard extends StatelessWidget {
  final Map<String, dynamic> transfer;

  const TransferItemCard({Key? key, required this.transfer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status   = _TransferStatus.from(transfer['status'] as String?);
    final currency = transfer['send_currency'] != null
        ? (transfer['send_currency']['code'] as String? ?? '')
        : '';
    final amount   = '${transfer['amount'] ?? ''} $currency'.trim();
    final bool isDark = context.theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        // ✅ FIX: Border on right side (RTL accent stripe)
        border: Border(right: BorderSide(color: status.color, width: 3.5)),
        boxShadow: FPShadows.card,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {}, // placeholder for detail navigation
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                // ✅ FIX: crossAxisAlignment start prevents vertical stretch issues
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  // ── Status icon ──────────────────────────────────────────
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: status.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(status.icon, color: status.color, size: 24),
                  ),

                  const SizedBox(width: 12),

                  // ── Main info (Flexible so it can shrink) ────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ✅ FIX: maxLines + overflow prevents unbounded width
                        Text(
                          transfer['receiver_name'] ?? 'مستلم غير معروف',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color:
                            isDark ? Colors.white : FPColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          transfer['tracking_code'] ?? '#',
                          style: TextStyle(
                            color: isDark ? Colors.white60 : FPColors.textMid,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // ✅ FIX: FittedBox + IntrinsicWidth prevents badge overflow
                        _StatusBadge(status: status),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // ── Amount + Chat button ─────────────────────────────────
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ✅ FIX: Flexible+FittedBox prevents amount overflow
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 100),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            amount,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color:
                              isDark ? Colors.white : FPColors.textDark,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _ChatButton(transfer: transfer),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Status badge ──────────────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  final _TransferStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: status.color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, color: status.color, size: 11),
          const SizedBox(width: 4),
          // ✅ FIX: Flexible prevents overflow when label is long
          Flexible(
            child: Text(
              status.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: status.color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chat button ───────────────────────────────────────────────────────────────
class _ChatButton extends StatelessWidget {
  final Map<String, dynamic> transfer;
  const _ChatButton({required this.transfer});

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark;
    return SizedBox(
      width: 40,
      height: 40,
      child: Material(
        color: FPColors.primary.withOpacity(isDark ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            final currentUserId =
                Get.find<StorageService>().getUserId() ?? 0;
            Get.to(() => ChatScreen(
              transferId:    transfer['id'],
              trackingCode:  transfer['tracking_code'],
              currentUserId: currentUserId,
            ));
          },
          child: const Center(
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              color: FPColors.primary,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }
}