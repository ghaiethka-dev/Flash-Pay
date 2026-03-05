import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  
  // قوائم الحوالات المفصولة
  var incomingTransfers = <Map<String, dynamic>>[].obs;
  var approvedTransfers = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    agentName.value = _storageService.getUserName() ?? 'وكيل';
    fetchAgentTransfers(); 
  }

  void changeTabIndex(int index) {
    selectedIndex.value = index;
    if (index == 0 || index == 1) {
      fetchAgentTransfers(); 
    }
    if (index == 3 && Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().fetchProfileData();
    }
  }

  Future<void> fetchAgentTransfers() async {
    isLoading.value = true;
    try {
      final response = await _apiClient.dio.get('/transfers');
      if (response.statusCode == 200) {
        List<dynamic> allTransfers = response.data['data'];
        
        // الواردة الجديدة (pending)
        incomingTransfers.assignAll(
          allTransfers.where((t) => t['status'] == 'pending').cast<Map<String, dynamic>>().toList()
        );
        
        // الحوالات المعلقة (approved) فقط
        approvedTransfers.assignAll(
          allTransfers.where((t) => t['status'] == 'approved').cast<Map<String, dynamic>>().toList()
        );
      }
    } catch (e) {
      print("Error fetching agent transfers: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateTransferStatus(int transferId, String newStatus) async {
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    try {
      final response = await _apiClient.dio.patch(
        '/transfers/$transferId/update-status',
        data: {'status': newStatus},
      );

      if (response.statusCode == 200) {
        Get.back(); // إغلاق مؤشر التحميل
        Get.back(); // إغلاق نافذة التفاصيل
        
        String message = '';
        if (newStatus == 'approved') message = 'تمت الموافقة على الحوالة وهي الآن معلقة لديك';
        else if (newStatus == 'rejected') message = 'تم رفض الحوالة';
        else if (newStatus == 'waiting') message = 'تم إرسال الحوالة إلى المكتب بنجاح';

        Get.snackbar(
          'نجاح', 
          message, 
          backgroundColor: newStatus == 'rejected' ? Colors.red : Colors.green, 
          colorText: Colors.white
        );
        
        fetchAgentTransfers(); 
      }
    } on DioException catch (e) {
      Get.back(); 
      Get.snackbar('خطأ', 'فشل تحديث حالة الحوالة', backgroundColor: Colors.red, colorText: Colors.white);
      print(e.response?.data);
    }
  }
}