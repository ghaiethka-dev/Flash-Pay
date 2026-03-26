import 'dart:async';
import 'package:dio/dio.dart' as dio;
import 'package:flashpay/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/local/storage_service.dart';
import '../data/network/api_client.dart';
import '../data/network/api_constants.dart';

class UserDashboardController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  final RxInt selectedIndex = 0.obs;
  final RxString userName = ''.obs;

  Timer? _blockCheckTimer;
  static const Duration _pollInterval = Duration(seconds: 30);

  @override
  void onInit() {
    super.onInit();
    userName.value = _storageService.getUserName() ?? 'ضيف';
    _startBlockPolling();
  }

  @override
  void onClose() {
    _blockCheckTimer?.cancel();
    super.onClose();
  }

  void _startBlockPolling() {
    _checkIfBlocked();
    _blockCheckTimer = Timer.periodic(_pollInterval, (_) => _checkIfBlocked());
  }

  Future<void> _checkIfBlocked() async {
    try {
      final token = _storageService.getToken();
      if (token == null || token.isEmpty) return;

      final client = ApiClient();
      final response = await client.dio.get(
        ApiConstants.meEndpoint,
        options: dio.Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final isActive = response.data['user']['is_active'];
        // الحالة المحفوظة محلياً قبل التحديث
        final wasBlocked = _storageService.getIsBlocked();

        if (isActive == false || isActive == 0) {
          // ── حالة جديدة: تم الحظر ──────────────────────────────────────
          _blockCheckTimer?.cancel();
          await _storageService.saveIsBlocked(true);
          Get.offAllNamed('/blocked');
        } else if (wasBlocked) {
          // ── تغيّرت الحالة: كان محظوراً والآن فُكّ حظره ───────────────
          // نحدّث الذاكرة المحلية أولاً
          await _storageService.saveIsBlocked(false);
          // نعيد تشغيل الـ timer لأننا ألغيناه عند الحظر
          _blockCheckTimer?.cancel();
          _blockCheckTimer = Timer.periodic(_pollInterval, (_) => _checkIfBlocked());
          // توجيه للـ dashboard مع رسالة
          Get.offAllNamed('/user_dashboard');
          Get.snackbar(
            'تم فك الحظر',
            'تم تفعيل حسابك، يمكنك الاستخدام الآن',
            backgroundColor: const Color(0xFF16a34a),
            colorText: const Color(0xFFFFFFFF),
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 4),
            margin: const EdgeInsets.all(12),
            borderRadius: 12,
            icon: const Icon(Icons.check_circle_outline, color: Color(0xFFFFFFFF)),
          );
        }
        // إذا wasBlocked == false والـ isActive == true → لا شيء، استمر طبيعياً
      }
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 401) {
        _blockCheckTimer?.cancel();
        await _storageService.clearAuthData();
        Get.offAllNamed('/login');
      }
    } catch (_) {
      // تجاهل أي استثناء غير متوقع
    }
  }

  void changeTabIndex(int index) {
    selectedIndex.value = index;
    if (index == 3) {
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().fetchProfileData();
      }
    }
  }
}