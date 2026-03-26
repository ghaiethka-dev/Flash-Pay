import 'package:flashpay/repos/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../data/local/storage_service.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final StorageService _storageService = Get.find<StorageService>();

  var isLoading = false.obs;
  var isLoadingCountries = false.obs;

  // === قوائم الدول والمدن من الـ API ===
  var countries = <Map<String, dynamic>>[].obs;  // [{id, name, code}, ...]
  var cities    = <Map<String, dynamic>>[].obs;   // [{id, name, country_id}, ...]

  // ID المختار (للإرسال للـ API)
  var selectedCountryId   = RxnInt();
  var selectedCountryName = RxnString();
  var selectedCityId      = RxnInt();
  var selectedCityName    = RxnString();

  // قائمة المدن المفلترة حسب الدولة
  List<Map<String, dynamic>> get availableCities {
    if (selectedCountryId.value == null) return [];
    return cities.where((c) => c['country_id'] == selectedCountryId.value).toList();
  }

  // تغيير الدولة وإعادة تعيين المدينة
  void changeCountry(int? id, String? name) {
    selectedCountryId.value   = id;
    selectedCountryName.value = name;
    selectedCityId.value      = null;
    selectedCityName.value    = null;
  }

  void changeCity(int? id, String? name) {
    selectedCityId.value   = id;
    selectedCityName.value = name;
  }

  // جلب الدول والمدن من الـ API عند فتح صفحة التسجيل
  Future<void> fetchCountriesAndCities() async {
    isLoadingCountries.value = true;
    try {
      final results = await Future.wait([
        _authRepository.getCountries(),
        _authRepository.getCities(),
      ]);

      final countriesResp = results[0];
      final citiesResp    = results[1];

      if (countriesResp.statusCode == 200) {
        countries.value = List<Map<String, dynamic>>.from(
          countriesResp.data['data'],
        );
      }
      if (citiesResp.statusCode == 200) {
        cities.value = List<Map<String, dynamic>>.from(
          citiesResp.data['data'],
        );
      }
    } catch (e) {
      debugPrint('Error fetching countries/cities: $e');
    } finally {
      isLoadingCountries.value = false;
    }
  }

  // === حقول تسجيل الدخول ===
  final loginEmailController    = TextEditingController();
  final loginPasswordController = TextEditingController();
  var isLoginPasswordHidden     = true.obs;

  // === حقول إنشاء الحساب ===
  final fullNameController                = TextEditingController();
  final registerEmailController           = TextEditingController();
  final registerPhoneController           = TextEditingController();
  final registerPasswordController        = TextEditingController();
  final confirmRegisterPasswordController = TextEditingController();
  var isRegisterPasswordHidden            = true.obs;
  var isConfirmRegisterPasswordHidden     = true.obs;

  // صورة الهوية
  Rx<File?> idCardImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  Future<void> pickIdCardImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (picked != null) {
      idCardImage.value = File(picked.path);
    }
  }

  void toggleLoginPassword() =>
      isLoginPasswordHidden.value = !isLoginPasswordHidden.value;
  void toggleRegisterPassword() =>
      isRegisterPasswordHidden.value = !isRegisterPasswordHidden.value;
  void toggleConfirmRegisterPassword() =>
      isConfirmRegisterPasswordHidden.value = !isConfirmRegisterPasswordHidden.value;

  // دالة تسجيل الدخول
  Future<void> login() async {
    if (loginEmailController.text.isEmpty || loginPasswordController.text.isEmpty) {
      Get.snackbar('تنبيه', 'يرجى إدخال البريد الإلكتروني وكلمة المرور',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final response = await _authRepository.loginUser(
        loginEmailController.text.trim(),
        loginPasswordController.text,
      );

      if (response.statusCode == 200) {
        final data  = response.data;
        final token = data['access_token'];
        final role  = data['user']['role'];
        final name  = data['user']['name'];

        await _storageService.saveToken(token);
        await _storageService.saveUserRole(role);
        await _storageService.saveUserName(name);

        final isActive = data['user']['is_active'];
        if (isActive == false || isActive == 0) {
          await _storageService.saveIsBlocked(true);
          Get.offAllNamed('/blocked');
          return;
        }
        await _storageService.saveIsBlocked(false);

        if (role == 'customer') {
          Get.offAllNamed('/user_dashboard');
        } else if (role == 'agent') {
          Get.offAllNamed('/agent_dashboard');
        } else {
          Get.offAllNamed('/user_dashboard');
        }
      }
    } on dio.DioException catch (e) {
      if (e.response?.statusCode == 403) {
        await _storageService.saveIsBlocked(true);
        Get.offAllNamed('/blocked');
        return;
      }
      String errorMessage = 'حدث خطأ غير متوقع';
      if (e.response?.statusCode == 401) {
        errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      }
      Get.snackbar('خطأ', errorMessage,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // دالة إنشاء الحساب
  Future<void> register() async {
    if (registerPasswordController.text != confirmRegisterPasswordController.text) {
      Get.snackbar('خطأ', 'كلمتا المرور غير متطابقتين!',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (selectedCountryId.value == null || selectedCityId.value == null) {
      Get.snackbar('تنبيه', 'يرجى اختيار البلد والمدينة',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    if (idCardImage.value == null) {
      Get.snackbar('تنبيه', 'يرجى رفع صورة الهوية',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      // ✅ نرسل country_id و city_id مباشرة (أرقام صحيحة من الـ API)
      final formData = dio.FormData.fromMap({
        'name':       fullNameController.text.trim(),
        'email':      registerEmailController.text.trim(),
        'phone':      registerPhoneController.text.trim(),
        'password':   registerPasswordController.text,
        'role':       'customer',
        'country_id': selectedCountryId.value,
        'city_id':    selectedCityId.value,
        'id_card_image': await dio.MultipartFile.fromFile(
          idCardImage.value!.path,
          filename: 'id_card.jpg',
        ),
      });

      final response = await _authRepository.registerUser(formData);

      if (response.statusCode == 201) {
        Get.snackbar('نجاح', 'تم إنشاء الحساب بنجاح، يمكنك الآن تسجيل الدخول',
            backgroundColor: Colors.green, colorText: Colors.white);
        Get.offNamed('/login');
      }
    } on dio.DioException catch (e) {
      String errorMessage = 'فشل إنشاء الحساب';
      debugPrint('Laravel Error: $e');
      if (e.response?.statusCode == 422) {
        // ✅ استخراج أول خطأ من الـ validation errors إن وجد
        final errors = e.response?.data['errors'];
        if (errors != null && errors is Map) {
          errorMessage = (errors.values.first as List).first.toString();
        } else {
          errorMessage = e.response?.data['message'] ?? 'البيانات المدخلة غير صحيحة';
        }
      }
      Get.snackbar('خطأ', errorMessage,
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // دالة تسجيل الخروج
  Future<void> logout() async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    try {
      await _authRepository.logoutUser();
    } catch (e) {
      debugPrint('Logout API Error: $e');
    } finally {
      await _storageService.clearAuthData();
      Get.offAllNamed('/login');
    }
  }

  @override
  void onClose() {
    loginEmailController.dispose();
    loginPasswordController.dispose();
    fullNameController.dispose();
    registerEmailController.dispose();
    registerPhoneController.dispose();
    registerPasswordController.dispose();
    confirmRegisterPasswordController.dispose();
    super.onClose();
  }
}