import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../data/network/api_client.dart'; 

class ProfileController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  // حالات التحميل
  var isLoading = true.obs; 
  var isSaving = false.obs;

  // متحكمات الحقول النصية (للتعديل)
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();

  // حفظ بيانات الحوالات
  var transfersHistory = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfileData();
  }

  // دالة جلب بيانات المستخدم وسجل الحوالات
  Future<void> fetchProfileData() async {
    isLoading.value = true;
    try {
      final response = await _apiClient.dio.get('/profile');
      
      if (response.statusCode == 200) {
        var data = response.data['data'];
        var user = data['profile'];
        
        // تعبئة الحقول ببيانات المستخدم الحالية
        nameController.text = user['name'] ?? '';
        emailController.text = user['email'] ?? '';
        phoneController.text = user['phone'] ?? '';
        // نترك كلمة المرور فارغة، لا داعي لعرضها
        
        // جلب سجل الحوالات
        transfersHistory.assignAll(List<Map<String, dynamic>>.from(data['transfers_history']));
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في جلب بيانات الملف الشخصي', backgroundColor: Colors.red, colorText: Colors.white);
      print("Error fetching profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // دالة حفظ التعديلات
  Future<void> updateProfile() async {
    isSaving.value = true;
    try {
      Map<String, dynamic> updateData = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneController.text.trim(),
      };

      // إرسال كلمة المرور فقط إذا قام المستخدم بكتابة شيء جديد
      if (passwordController.text.isNotEmpty) {
        if (passwordController.text.length < 8) {
          Get.snackbar('تنبيه', 'كلمة المرور يجب أن تكون 8 أحرف على الأقل', backgroundColor: Colors.orange, colorText: Colors.white);
          isSaving.value = false;
          return;
        }
        updateData['password'] = passwordController.text;
      }

      final response = await _apiClient.dio.put('/profile/update', data: updateData);

      if (response.statusCode == 200) {
        Get.snackbar('نجاح', 'تم تحديث بياناتك بنجاح', backgroundColor: Colors.green, colorText: Colors.white);
        passwordController.clear(); // تفريغ حقل الباسورد بعد النجاح
      }
    } on DioException catch (e) {
      String errorMessage = 'فشل تحديث البيانات';
      if (e.response?.statusCode == 422) {
         errorMessage = e.response?.data['message'] ?? 'البريد أو الهاتف مستخدم مسبقاً';
      }
      Get.snackbar('خطأ', errorMessage, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}