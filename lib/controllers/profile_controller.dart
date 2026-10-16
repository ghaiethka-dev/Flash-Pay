import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../data/network/api_client.dart';
import 'package:flashpay/core/api_error.dart';
import 'package:flashpay/core/fp_feedback.dart';
import 'package:flashpay/core/validators.dart';

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
      FPFeedback.error(
        ApiError.message(e, fallback: 'فشل في جلب بيانات الملف الشخصي'),
        title: 'تعذّر تحميل البيانات',
      );
      print("Error fetching profile: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// أول خطأ في بيانات الملف الشخصي، أو null إذا كانت صحيحة.
  String? _profileError() {
    if (nameController.text.trim().isEmpty) {
      return 'الاسم لا يمكن أن يكون فارغًا';
    }
    final emailError = FPValidators.email(emailController.text);
    if (emailError != null) return emailError;

    final phone = phoneController.text.trim();
    if (phone.isNotEmpty) {
      final digits = FPValidators.normalizeDigits(
          phone.replaceAll(RegExp(r'[\s\-\(\)\+]'), ''));
      if (!RegExp(r'^\d{7,15}$').hasMatch(digits)) {
        return 'رقم الهاتف غير صالح، أدخل من 7 إلى 15 رقمًا';
      }
    }

    if (passwordController.text.isNotEmpty) {
      return FPValidators.newPassword(passwordController.text);
    }
    return null;
  }

  // دالة حفظ التعديلات
  Future<void> updateProfile() async {
    if (isSaving.value) return;

    final inputError = _profileError();
    if (inputError != null) {
      FPFeedback.error(inputError, title: 'تحقق من البيانات');
      return;
    }

    isSaving.value = true;
    try {
      Map<String, dynamic> updateData = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': FPValidators.normalizeDigits(phoneController.text.trim()),
      };

      // إرسال كلمة المرور فقط إذا قام المستخدم بكتابة شيء جديد
      if (passwordController.text.isNotEmpty) {
        updateData['password'] = passwordController.text;
      }

      final response = await _apiClient.dio.put('/profile/update', data: updateData);

      if (response.statusCode == 200) {
        FPFeedback.success('تم تحديث بياناتك بنجاح');
        passwordController.clear(); // تفريغ حقل الباسورد بعد النجاح
      }
    } on DioException catch (e) {
      FPFeedback.error(
        ApiError.message(e,
            fallback: 'فشل تحديث البيانات',
            statusMessages: const {
              422: 'البريد الإلكتروني أو رقم الهاتف مستخدم مسبقًا',
            }),
        title: 'تعذّر حفظ التعديلات',
      );
    } catch (e) {
      print('updateProfile unexpected error: $e');
      FPFeedback.error('حدث خطأ غير متوقع أثناء الحفظ، حاول مرة أخرى');
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