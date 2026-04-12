import 'package:flutter/material.dart';
import 'package:get/get.dart' hide FormData;
import 'package:dio/dio.dart';
import '../data/local/storage_service.dart';
import '../data/network/api_client.dart';
import 'profile_controller.dart';

class AgentDashboardController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();
  final ApiClient _apiClient = ApiClient();

  final RxInt selectedIndex = 0.obs;
  final RxString agentName = ''.obs;

  var isLoading = false.obs;

  // الحوالات الواردة (pending)
  var incomingTransfers = <Map<String, dynamic>>[].obs;

  // ── صندوق المندوب ──────────────────────────────────────────────────────
  var agentSafeBalance = 0.0.obs;       // الرصيد الكلي في الصندوق
  var agentProfitTotal = 0.0.obs;       // إجمالي الأرباح المتراكمة
  var agentProfitRatio = 0.0.obs;       // نسبة الربح المحددة من السوبر أدمن
  var safeTransfers = <Map<String, dynamic>>[].obs;
  var isSafeLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    agentName.value = _storageService.getUserName() ?? 'وكيل';
    fetchAgentTransfers();
    fetchAgentSafe();
  }

  // ── جلب بيانات صندوق المندوب (رصيد + أرباح + سجل) ──
  Future<void> fetchAgentSafe() async {
    isSafeLoading.value = true;
    try {
      final safeResponse = await _apiClient.dio.get('/agent/safe');
      final data = safeResponse.data['data'];

      agentSafeBalance.value =
          double.tryParse(data['balance'].toString()) ?? 0.0;
      agentProfitTotal.value =
          double.tryParse(data['agent_profit'].toString()) ?? 0.0;
      agentProfitRatio.value =
          double.tryParse(data['agent_profit_ratio'].toString()) ?? 0.0;

      // سجل الحوالات من نفس الـ endpoint
      final transfersList = data['transfers'] as List? ?? [];
      safeTransfers.assignAll(
        transfersList
            .where((t) =>
        t['status'] == 'approved' ||
            t['status'] == 'waiting' ||
            t['status'] == 'ready')
            .cast<Map<String, dynamic>>()
            .toList(),
      );
    } catch (e) {
      print('Error fetching agent safe: $e');
    } finally {
      isSafeLoading.value = false;
    }
  }

  void changeTabIndex(int index) {
    selectedIndex.value = index;
    if (index == 0) fetchAgentTransfers();
    if (index == 3 && Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().fetchProfileData();
    }
  }

  Future<void> fetchAgentTransfers() async {
    isLoading.value = true;
    try {
      final response = await _apiClient.dio.get('/transfers');
      if (response.statusCode == 200) {
        final List<dynamic> allTransfers = response.data['data'];
        incomingTransfers.assignAll(
          allTransfers
              .where((t) => t['status'] == 'pending')
              .cast<Map<String, dynamic>>()
              .toList(),
        );
      }
    } catch (e) {
      print('Error fetching agent transfers: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTransferStatus(int transferId, String newStatus) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final response = await _apiClient.dio.post(
        '/transfers/$transferId/update-status',
        data: FormData.fromMap({
          'status': newStatus,
          '_method': 'PATCH',
        }),
      );

      if (response.statusCode == 200) {
        Get.back();
        Get.back();

        String message = '';
        if (newStatus == 'approved') {
          message = 'تمت الموافقة على الحوالة';
        } else if (newStatus == 'rejected') {
          message = 'تم رفض الحوالة';
        } else if (newStatus == 'waiting') {
          message = 'تم إرسال الحوالة إلى المكتب بنجاح';
        }

        Get.snackbar(
          'نجاح',
          message,
          backgroundColor:
          newStatus == 'rejected' ? Colors.red : Colors.green,
          colorText: Colors.white,
        );

        fetchAgentTransfers();
        fetchAgentSafe(); // تحديث صندوق بعد أي تغيير
      }
    } on DioException catch (e) {
      Get.back();
      Get.snackbar('خطأ', 'فشل تحديث حالة الحوالة',
          backgroundColor: Colors.red, colorText: Colors.white);
      print(e.response?.data);
    }
  }
}