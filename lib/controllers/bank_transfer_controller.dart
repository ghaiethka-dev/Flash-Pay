import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../data/network/api_client.dart';

class BankTransferController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  var isLoading = false.obs;

  // حقول النموذج
  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final notesController = TextEditingController();
  final amountController = TextEditingController();

  // قائمة حوالات البنك الخاصة بالوكيل
  var bankTransfers = <Map<String, dynamic>>[].obs;
  var isFetchingTransfers = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBankTransfers();
  }

  Future<void> fetchBankTransfers() async {
    isFetchingTransfers.value = true;
    try {
      final response = await _apiClient.dio.get('/bank-transfers');
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        bankTransfers.assignAll(data.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      print('Error fetching bank transfers: $e');
    } finally {
      isFetchingTransfers.value = false;
    }
  }

  Future<void> submitBankTransfer() async {
    // التحقق من الحقول
    if (bankNameController.text.trim().isEmpty ||
        accountNumberController.text.trim().isEmpty ||
        fullNameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        amountController.text.trim().isEmpty) {
      Get.snackbar(
        'تنبيه',
        'يرجى تعبئة جميع الحقول الإلزامية',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final double? amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      Get.snackbar(
        'تنبيه',
        'يرجى إدخال مبلغ صحيح',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;
    try {
      final response = await _apiClient.dio.post(
        '/bank-transfers',
        data: {
          'bank_name': bankNameController.text.trim(),
          'account_number': accountNumberController.text.trim(),
          'full_name': fullNameController.text.trim(),
          'phone': phoneController.text.trim(),
          'amount': amountController.text.trim(),
          'notes': notesController.text.trim(),
        },
      );

      if (response.statusCode == 201) {
        Get.snackbar(
          'تم الإرسال ✓',
          'تم إرسال طلب التحويل البنكي بنجاح وهو الآن بانتظار موافقة المشرف',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          snackPosition: SnackPosition.TOP,
        );
        _resetForm();
        fetchBankTransfers(); // تحديث القائمة
      }
    } on DioException catch (e) {
      String msg = 'فشل إرسال الطلب';
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        if (errors != null) {
          msg = (errors as Map).values.first[0].toString();
        } else {
          msg = e.response?.data['message'] ?? msg;
        }
      } else if (e.response?.statusCode == 403) {
        msg = 'غير مصرح لك بهذه العملية';
      }
      Get.snackbar('خطأ', msg, backgroundColor: Colors.red, colorText: Colors.white);
      print('BankTransfer error: ${e.response?.data}');
    } finally {
      isLoading.value = false;
    }
  }

  void _resetForm() {
    bankNameController.clear();
    accountNumberController.clear();
    fullNameController.clear();
    phoneController.clear();
    notesController.clear();
    amountController.clear();
  }

  String statusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'بانتظار الموافقة';
      case 'approved':
        return 'موافق عليه';
      case 'rejected':
        return 'مرفوض';
      default:
        return status;
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void onClose() {
    bankNameController.dispose();
    accountNumberController.dispose();
    fullNameController.dispose();
    phoneController.dispose();
    notesController.dispose();
    amountController.dispose();
    super.onClose();
  }
}
