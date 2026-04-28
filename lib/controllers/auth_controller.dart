import 'package:flashpay/repos/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../data/local/storage_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flashpay/data/network/api_client.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final StorageService _storageService = Get.find<StorageService>();

  var isLoading = false.obs;
  var isLoadingCountries = false.obs;

  // === قوائم الدول والمدن من الـ API ===
  var countries = <Map<String, dynamic>>[].obs;
  var cities    = <Map<String, dynamic>>[].obs;

  var selectedCountryId   = RxnInt();
  var selectedCountryName = RxnString();
  var selectedCityId      = RxnInt();
  var selectedCityName    = RxnString();

  List<Map<String, dynamic>> get availableCities {
    if (selectedCountryId.value == null) return [];
    return cities.where((c) => c['country_id'] == selectedCountryId.value).toList();
  }

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

  // ── رقم الهاتف الكامل مع كود الدولة (يُعبّأ من IntlPhoneField) ──
  var registerPhoneFullNumber = RxnString(); // مثال: "+963912345678"

  void setRegisterPhone(String completeNumber) {
    registerPhoneFullNumber.value = completeNumber;
  }

  // ── صور الهوية الثلاث ──
  // 0: مع الهوية (selfie)  |  1: وجه الهوية  |  2: ظهر الهوية
  var idCardImages = <File?>[null, null, null].obs;
  final ImagePicker _picker = ImagePicker();

  static const List<String> _imageLabels = [
    'صورة شخصية مع الهوية',
    'وجه الهوية',
    'ظهر الهوية',
  ];

  static const List<IconData> _imageIcons = [
    Icons.person_outlined,
    Icons.credit_card,
    Icons.credit_card_off_outlined,
  ];

  String imageLabel(int index) => _imageLabels[index];
  IconData imageIcon(int index) => _imageIcons[index];

  Future<void> pickIdCardImage(int index) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (picked != null) {
      final updated = List<File?>.from(idCardImages);
      updated[index] = File(picked.path);
      idCardImages.value = updated;
    }
  }

  void removeIdCardImage(int index) {
    final updated = List<File?>.from(idCardImages);
    updated[index] = null;
    idCardImages.value = updated;
  }

  // ── التحقق: هل رُفعت جميع الصور ──
  bool get allImagesUploaded => idCardImages.every((img) => img != null);

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
        try {
          String? fcmToken = await FirebaseMessaging.instance.getToken();
          if (fcmToken != null) {
            await ApiClient().dio.post('/update-fcm-token', data: {'fcm_token': fcmToken});
          }
        } catch (e) {
          debugPrint('Failed to update FCM token on login: $e');
        }

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

    // التحقق من رقم الهاتف
    if (registerPhoneFullNumber.value == null ||
        registerPhoneFullNumber.value!.isEmpty) {
      Get.snackbar('تنبيه', 'يرجى إدخال رقم الهاتف',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    // التحقق من جميع صور الهوية
    if (!allImagesUploaded) {
      Get.snackbar(
        'تنبيه',
        'يرجى رفع جميع صور الهوية الثلاث (صورة شخصية مع الهوية، وجه الهوية، ظهر الهوية)',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    isLoading.value = true;
    try {
      String? fcmToken = await FirebaseMessaging.instance.getToken();

      final formData = dio.FormData.fromMap({
        'name':       fullNameController.text.trim(),
        'email':      registerEmailController.text.trim(),
        // ✅ نرسل الرقم الكامل مع كود الدولة
        'phone':      registerPhoneFullNumber.value!.trim(),
        'password':   registerPasswordController.text,
        'role':       'customer',
        'country_id': selectedCountryId.value,
        'city_id':    selectedCityId.value,
        'fcm_token':  fcmToken ?? '',
        // ✅ ثلاث صور منفصلة
        'selfie_with_id': await dio.MultipartFile.fromFile(
          idCardImages[0]!.path,
          filename: 'selfie_with_id.jpg',
        ),
        'id_card_front': await dio.MultipartFile.fromFile(
          idCardImages[1]!.path,
          filename: 'id_card_front.jpg',
        ),
        'id_card_back': await dio.MultipartFile.fromFile(
          idCardImages[2]!.path,
          filename: 'id_card_back.jpg',
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