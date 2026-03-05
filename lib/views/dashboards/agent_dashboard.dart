import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../controllers/agent_dashboard_controller.dart';
import '../../core/constants.dart';
import '../settings_view.dart';
import '../profile_view.dart';

class AgentDashboard extends StatelessWidget {
  const AgentDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AgentDashboardController controller = Get.put(AgentDashboardController());

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: _buildAppBar(),
        body: Obx(() => _buildBody(controller)),
        bottomNavigationBar: _buildBottomNavigationBar(controller),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryGradient.colors.first,
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.admin_panel_settings, color: Color(0xFFFFD166), size: 28),
          SizedBox(width: 8),
          Text('لوحة الوكيل', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        ],
      ),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
    );
  }

  Widget _buildBody(AgentDashboardController controller) {
    if (controller.isLoading.value && controller.incomingTransfers.isEmpty && controller.approvedTransfers.isEmpty) {
      return Center(child: CircularProgressIndicator(color: AppColors.primaryGradient.colors.first));
    }

    switch (controller.selectedIndex.value) {
      case 0:
        return _buildIncomingTransfersTab(controller);
      case 1:
        return _buildApprovedTransfersTab(controller);
      case 2:
        return const SettingsView();
      case 3:
        return const ProfileView();
      default:
        return _buildIncomingTransfersTab(controller);
    }
  }

  // ================= 1. صفحة الواردات (Pending) =================
  Widget _buildIncomingTransfersTab(AgentDashboardController controller) {
    return RefreshIndicator(
      onRefresh: () => controller.fetchAgentTransfers(),
      color: AppColors.primaryGradient.colors.first,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('مرحباً بك،', style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w600)),
            Text(controller.agentName.value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryGradient.colors.first)),
            const SizedBox(height: 24),
            const Text('طلبات الحوالات الجديدة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 16),
            
            Expanded(
              child: controller.incomingTransfers.isEmpty
                  ? _buildEmptyState(Icons.move_to_inbox, "لا توجد طلبات جديدة")
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: controller.incomingTransfers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        var transfer = controller.incomingTransfers[index];
                        return _buildTransferCard(
                          transfer: transfer,
                          isActionable: true,
                          onTap: () => _showIncomingTransferDetailsSheet(context, controller, transfer),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= 2. صفحة الحوالات المعلقة (Approved) =================
  Widget _buildApprovedTransfersTab(AgentDashboardController controller) {
    return RefreshIndicator(
      onRefresh: () => controller.fetchAgentTransfers(),
      color: AppColors.primaryGradient.colors.first,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('الحوالات المعلقة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
            Text('الحوالات الجاهزة للإرسال إلى المكتب', style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
            const SizedBox(height: 24),
            
            Expanded(
              child: controller.approvedTransfers.isEmpty
                  ? _buildEmptyState(Icons.pending_actions, "لا توجد حوالات معلقة")
                  : ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: controller.approvedTransfers.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                         var transfer = controller.approvedTransfers[index];
                        return _buildTransferCard(
                          transfer: transfer,
                          isActionable: true, // جعلناها قابلة للضغط
                          onTap: () => _showApprovedTransferDetailsSheet(context, controller, transfer),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= واجهات النوافذ المنبثقة =================

  // نافذة الحوالات الواردة (موافقة / رفض)
  void _showIncomingTransferDetailsSheet(BuildContext context, AgentDashboardController controller, Map<String, dynamic> transfer) {
    _buildBaseBottomSheet(
      transfer: transfer,
      actions: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => controller.updateTransferStatus(transfer['id'], 'rejected'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade50, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text("رفض", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => controller.updateTransferStatus(transfer['id'], 'approved'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text("موافقة", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ]
    );
  }

  // نافذة الحوالات المعلقة (إرسال للمكتب / إلغاء)
  void _showApprovedTransferDetailsSheet(BuildContext context, AgentDashboardController controller, Map<String, dynamic> transfer) {
    _buildBaseBottomSheet(
      transfer: transfer,
      actions: [
        Expanded(
          child: ElevatedButton(
            onPressed: () => Get.back(), // زر الإلغاء يغلق النافذة فقط
            style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text("إلغاء", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () => controller.updateTransferStatus(transfer['id'], 'waiting'), // تحويلها للمكتب
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGradient.colors.first, padding: const EdgeInsets.symmetric(vertical: 14)),
            child: const Text("إرسال إلى المكتب", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ]
    );
  }

  // دالة مساعدة لبناء هيكل النافذة لتجنب تكرار الكود
  void _buildBaseBottomSheet({required Map<String, dynamic> transfer, required List<Widget> actions}) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            const Text("تفاصيل الحوالة", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            _buildDetailRow("رقم التتبع:", transfer['tracking_code']),
            _buildDetailRow("المرسل:", transfer['sender'] != null ? transfer['sender']['name'] : 'غير معروف'),
            _buildDetailRow("هاتف المرسل:", transfer['sender'] != null ? transfer['sender']['phone'] : 'غير معروف'),
            const Divider(),
            _buildDetailRow("المستلم:", transfer['receiver_name']),
            _buildDetailRow("هاتف المستلم:", transfer['receiver_phone']),
            const Divider(),
            _buildDetailRow("المبلغ والعملة:", "${transfer['amount']} ${transfer['currency'] != null ? transfer['currency']['code'] : ''}", isHighlight: true),
            const SizedBox(height: 24),
            Row(children: actions)
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(String title, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isHighlight ? 18 : 14, color: isHighlight ? AppColors.primaryGradient.colors.first : Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildTransferCard({required Map<String, dynamic> transfer, required bool isActionable, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isActionable ? Colors.orange.shade100 : Colors.grey.shade100),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: isActionable ? Colors.orange.withOpacity(0.1) : Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(isActionable ? Icons.pending_actions : Icons.check_circle, color: isActionable ? Colors.orange : Colors.green, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("من: ${transfer['sender'] != null ? transfer['sender']['name'] : 'غير معروف'}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(transfer['tracking_code'] ?? '#', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text("${transfer['amount']} ${transfer['currency'] != null ? transfer['currency']['code'] : ''}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                if (isActionable)
                  const Padding(padding: EdgeInsets.only(top: 4.0), child: Text("اضغط للتفاصيل", style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(AgentDashboardController controller) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: const BorderRadius.vertical(top: Radius.circular(30)), boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.05), offset: const Offset(0, -5))]),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12),
          child: Obx(
            () => GNav(
              rippleColor: Colors.grey[300]!, hoverColor: Colors.grey[100]!, gap: 6, activeColor: AppColors.primaryGradient.colors.first, iconSize: 24, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), duration: const Duration(milliseconds: 400), tabBackgroundColor: AppColors.primaryGradient.colors.first.withOpacity(0.08), color: Colors.grey[500],
              tabs: const [
                GButton(icon: Icons.move_to_inbox_rounded, text: 'الواردة'),
                GButton(icon: Icons.pending_actions, text: 'المعلقة'), // تم التعديل هنا
                GButton(icon: Icons.settings_rounded, text: 'الإعدادات'),
                GButton(icon: Icons.person_rounded, text: 'الحساب'),
              ],
              selectedIndex: controller.selectedIndex.value,
              onTabChange: controller.changeTabIndex,
            ),
          ),
        ),
      ),
    );
  }
}