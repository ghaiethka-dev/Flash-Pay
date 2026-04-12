import 'package:flutter/material.dart';
import 'package:get/get.dart';
// 🚀 استيراد الشات وخدمة التخزين
import 'package:flashpay/views/chat/chat_screen.dart';
import 'package:flashpay/data/local/storage_service.dart';

import '../../dashboards/user_dashboards/widgets/fp_theme.dart';

class _TransferStatus {
  final Color color;
  final String label;
  final IconData icon;

  const _TransferStatus({required this.color, required this.label, required this.icon});

  factory _TransferStatus.from(String? status) {
    switch (status) {
      case 'pending': return const _TransferStatus(color: Colors.orange, label: 'طلب جديد / قيد المراجعة', icon: Icons.hourglass_top_rounded);
      case 'approved': return _TransferStatus(color: Colors.blue.shade600, label: 'بانتظار الإرسال للمكتب', icon: Icons.send_rounded);
      case 'waiting': return const _TransferStatus(color: Color.fromARGB(255, 21, 0, 255), label: 'بانتظار قبول المكتب', icon: Icons.watch_later_rounded);
      case 'ready': return const _TransferStatus(color: Colors.purple, label: 'جاهزة للتسليم', icon: Icons.check_circle_outline_rounded);
      case 'completed': return const _TransferStatus(color: Colors.green, label: 'مكتملة', icon: Icons.task_alt_rounded);
      default: return _TransferStatus(color: Colors.grey.shade500, label: status ?? 'غير معروف', icon: Icons.help_outline_rounded);
    }
  }
}

class TransferItemCard extends StatelessWidget {
  final Map<String, dynamic> transfer;

  const TransferItemCard({Key? key, required this.transfer}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final status = _TransferStatus.from(transfer['status'] as String?);
    final String amount = '${transfer['amount'] ?? ''} ${transfer['send_currency'] != null ? transfer['send_currency']['code'] : ''}';
    
    final bool isDark = context.theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: context.theme.cardColor, 
        borderRadius: BorderRadius.circular(20),
        border: Border(right: BorderSide(color: status.color, width: 3.5)),
        boxShadow: FPShadows.card,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(width: 52, height: 52, decoration: BoxDecoration(color: status.color.withOpacity(0.10), borderRadius: BorderRadius.circular(16)), child: Icon(status.icon, color: status.color, size: 26)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transfer['receiver_name'] ?? 'مستلم غير معروف', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: isDark ? Colors.white : FPColors.textDark)), 
                  const SizedBox(height: 4),
                  Text(transfer['tracking_code'] ?? '#', style: TextStyle(color: isDark ? Colors.white70 : FPColors.textMid, fontSize: 12, fontWeight: FontWeight.w500)), 
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: status.color.withOpacity(0.10), borderRadius: BorderRadius.circular(30)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [Icon(status.icon, color: status.color, size: 11), const SizedBox(width: 4), Text(status.label, style: TextStyle(color: status.color, fontSize: 10, fontWeight: FontWeight.w700))],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            
            // ==========================================
            // 🚀 قسم السعر وزر المحادثة الديناميكي
            // ==========================================
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(amount, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: isDark ? Colors.white : FPColors.textDark)), 
                const SizedBox(height: 12),
                
                // زر الدردشة مع الوكيل
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: FPColors.primary.withOpacity(isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: const Icon(Icons.chat_bubble_outline_rounded, color: FPColors.primary, size: 20),
                    tooltip: 'تواصل بخصوص الحوالة',
                    onPressed: () {
                      // 1. جلب رقم المستخدم الحالي بشكل ديناميكي
                      final currentUserId = Get.find<StorageService>().getUserId() ?? 0;
                      
                      // 2. الانتقال للشات مع تمرير رقم وكود هذه الحوالة بالتحديد
                      Get.to(() => ChatScreen(
                        transferId: transfer['id'], 
                        trackingCode: transfer['tracking_code'],
                        currentUserId: currentUserId,
                      ));
                    },
                  ),
                ),
              ],
            ),
            // ==========================================
            
          ],
        ),
      ),
    );
  }
}