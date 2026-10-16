import 'package:flashpay/controllers/notification_controller.dart';
import 'package:flashpay/repos/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../data/local/storage_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flashpay/data/network/api_client.dart';
import 'package:flashpay/core/api_error.dart';
import 'package:flashpay/core/fp_feedback.dart';
import 'package:flashpay/core/validators.dart';

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
    if (isLoading.value) return;

    final loginInputError = FPValidators.email(loginEmailController.text) ??
        FPValidators.loginPassword(loginPasswordController.text);
    if (loginInputError != null) {
      FPFeedback.error(loginInputError, title: 'تحقق من البيانات');
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
      FPFeedback.error(
        ApiError.message(e, statusMessages: const {
          401: 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
        }),
        title: 'تعذّر تسجيل الدخول',
      );
    } catch (e) {
      debugPrint('Login unexpected error: $e');
      FPFeedback.error('حدث خطأ غير متوقع أثناء تسجيل الدخول، حاول مرة أخرى');
    } finally {
      isLoading.value = false;
    }
  }

  /// أول خطأ في بيانات التسجيل، أو null إذا كانت كلها صحيحة
  /// (احتياط خلف التحقق الموجود في الشاشة).
  String? _registerInputError() {
    final missingImages = <String>[
      for (int i = 0; i < idCardImages.length; i++)
        if (idCardImages[i] == null) imageLabel(i),
    ];
    return FPValidators.fullName(fullNameController.text) ??
        FPValidators.email(registerEmailController.text) ??
        ((registerPhoneFullNumber.value ?? '').trim().isEmpty
            ? 'أدخل رقم الهاتف'
            : null) ??
        (selectedCountryId.value == null ? 'اختر البلد' : null) ??
        (selectedCityId.value == null
            ? 'اختر المدينة'
            : null) ??
        FPValidators.newPassword(registerPasswordController.text) ??
        (registerPasswordController.text !=
            confirmRegisterPasswordController.text
            ? 'كلمتا المرور غير متطابقتين'
            : null) ??
        (missingImages.isNotEmpty
            ? 'ارفع الصور الناقصة: ${missingImages.join('، ')}'
            : null);
  }

  // دالة إنشاء الحساب
  Future<void> register() async {
    if (isLoading.value) return;

    final registerError = _registerInputError();
    if (registerError != null) {
      FPFeedback.error(registerError, title: 'تحقق من البيانات');
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
        FPFeedback.success('تم إنشاء الحساب بنجاح، يمكنك الآن تسجيل الدخول');
        Get.offNamed('/login');
      }
    } on dio.DioException catch (e) {
      debugPrint('Laravel Error: $e');
      FPFeedback.error(
        ApiError.message(e, fallback: 'فشل إنشاء الحساب'),
        title: 'تعذّر إنشاء الحساب',
      );
    } catch (e) {
      debugPrint('Register unexpected error: $e');
      FPFeedback.error('حدث خطأ غير متوقع أثناء إنشاء الحساب، حاول مرة أخرى');
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
      // ✅ امسح الإشعارات المحفوظة محلياً حتى لا يراها المستخدم التالي على الجهاز
      try {
        if (Get.isRegistered<NotificationController>()) {
          await Get.find<NotificationController>().clearAll();
        }
      } catch (e) {
        debugPrint('Clear notifications error: $e');
      }

      // ✅ ألغِ توكن FCM الحالي: يمنع وصول إشعارات هذا الحساب إلى الجهاز بعد الخروج
      //    (يُولَّد توكن جديد تلقائياً ويُرفع عند تسجيل الدخول التالي)
      try {
        await FirebaseMessaging.instance.deleteToken();
      } catch (e) {
        debugPrint('Delete FCM token error: $e');
      }

      await _storageService.clearAuthData();
      Get.offAllNamed('/login');
    }
  }

  // ===========================================================================
  //  ✅ استعادة كلمة المرور
  // ===========================================================================

  final resetEmailController = TextEditingController();
  final resetCodeController  = TextEditingController();
  final resetPassController  = TextEditingController();
  final resetConfirmPassController = TextEditingController();

  // 0: إدخال البريد | 1: إدخال الرمز + كلمة المرور الجديدة
  var resetStep = 0.obs;

  Future<void> sendResetCode() async {
    if (isLoading.value) return;

    final email = resetEmailController.text.trim();
    final emailError = FPValidators.email(email);
    if (emailError != null) {
      FPFeedback.error(emailError, title: 'تحقق من البيانات');
      return;
    }

    isLoading.value = true;
    try {
      await _authRepository.forgotPassword(email);
      resetStep.value = 1;
      FPFeedback.success(
          'إذا كان البريد مسجلًا فستصلك رسالة تحتوي على رمز التحقق',
          title: 'تم الإرسال');
    } on dio.DioException catch (e) {
      FPFeedback.error(
        ApiError.message(e, fallback: 'تعذر الإرسال، حاول لاحقًا'),
        title: 'تعذّر إرسال الرمز',
      );
    } catch (e) {
      debugPrint('sendResetCode unexpected error: $e');
      FPFeedback.error('حدث خطأ غير متوقع، حاول مرة أخرى');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> submitNewPassword() async {
    if (isLoading.value) return;

    final code = resetCodeController.text.trim();
    final pass = resetPassController.text;
    final confirm = resetConfirmPassController.text;

    final inputError = FPValidators.otpCode(code) ??
        FPValidators.newPassword(pass) ??
        (pass != confirm ? 'كلمتا المرور غير متطابقتين' : null);
    if (inputError != null) {
      FPFeedback.error(inputError, title: 'تحقق من البيانات');
      return;
    }

    isLoading.value = true;
    try {
      await _authRepository.resetPassword(
        email: resetEmailController.text.trim(),
        code: code,
        password: pass,
      );
      FPFeedback.success('تم تغيير كلمة المرور، يمكنك تسجيل الدخول الآن');

      // تفريغ الحقول والعودة لتسجيل الدخول
      resetStep.value = 0;
      resetEmailController.clear();
      resetCodeController.clear();
      resetPassController.clear();
      resetConfirmPassController.clear();
      Get.offAllNamed('/login');
    } on dio.DioException catch (e) {
      FPFeedback.error(
        ApiError.message(e, statusMessages: const {
          422: 'رمز التحقق غير صحيح أو منتهي الصلاحية، اطلب رمزًا جديدًا',
        }),
        title: 'تعذّر تغيير كلمة المرور',
      );
    } catch (e) {
      debugPrint('submitNewPassword unexpected error: $e');
      FPFeedback.error('حدث خطأ غير متوقع، حاول مرة أخرى');
    } finally {
      isLoading.value = false;
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
    resetEmailController.dispose();
    resetCodeController.dispose();
    resetPassController.dispose();
    resetConfirmPassController.dispose();
    super.onClose();
  }
}