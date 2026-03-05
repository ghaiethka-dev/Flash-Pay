import 'package:flashpay/repos/auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
// تأكد من مسارات الاستيراد الخاصة بك (مثلاً AuthRepository و StorageService)
import '../data/local/storage_service.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final StorageService _storageService = Get.find<StorageService>();

  var isLoading = false.obs;

  // === بيانات الدول والمدن المأخوذة من الـ Seeders ===
  final Map<String, List<String>> countriesAndCities = {
    'سوريا': ['دمشق', 'حلب', 'حمص', 'حماة', 'اللاذقية', 'طرطوس', 'دير الزور', 'الحسكة', 'القامشلي', 'إدلب', 'السويداء', 'درعا', 'ريف دمشق', 'منبج', 'البوكمال'],
    'تركيا': ['إسطنبول', 'أنقرة', 'غازي عنتاب', 'مرسين', 'أنطاليا', 'أضنة', 'اورفا', 'بورصة'],
    'لبنان': ['بيروت', 'طرابلس', 'صيدا'],
    'الأردن': ['عمان', 'إربد', 'الزرقاء'],
    'العراق': ['بغداد', 'أربيل', 'البصرة'],
    'مصر': ['القاهرة', 'الإسكندرية'],
    'المملكة العربية السعودية': ['الرياض', 'جدة', 'الدمام', 'مكة المكرمة'],
    'الإمارات العربية المتحدة': ['دبي', 'أبو ظبي', 'الشارقة', 'عجمان'],
    'الكويت': ['الكويت العاصمة', 'الجهراء'],
    'قطر': ['الدوحة', 'الريان'],
    'سلطنة عمان': ['مسقط', 'صلالة'],
    'ألمانيا': ['برلين', 'هامبورغ', 'ميونخ', 'إيسن', 'دورتموند'],
    'السويد': ['ستوكهولم', 'غوتنبرغ'],
    'هولندا': ['أمستردام', 'روتردام'],
    'النمسا': ['فيينا', 'سالزبورغ'],
    'فرنسا': ['باريس', 'ليون'],
    'اليونان': ['أثينا', 'تيسالونيكي'],
    'الولايات المتحدة الأمريكية': ['نيويورك', 'لوس أنجلوس', 'شيكاغو'],
    'كندا': ['تورونتو', 'مونتريال', 'فانكوفر'],
    'البرازيل': ['ساو باولو', 'ريو دي جانيرو'],
  };

  // === حقول تسجيل الدخول ===
  final loginEmailController = TextEditingController();
  final loginPasswordController = TextEditingController();
  var isLoginPasswordHidden = true.obs;

  // === حقول إنشاء الحساب ===
  final fullNameController = TextEditingController();
  final registerEmailController = TextEditingController(); 
  final registerPhoneController = TextEditingController(); 
  
  // متغيرات القوائم المنسدلة للبلد والمدينة
  var selectedCountry = RxnString();
  var selectedCity = RxnString();

  final registerPasswordController = TextEditingController();
  final confirmRegisterPasswordController = TextEditingController();
  var isRegisterPasswordHidden = true.obs;
  var isConfirmRegisterPasswordHidden = true.obs;

  // جلب قائمة المدن بناءً على الدولة المختارة
  List<String> get availableCities =>
      selectedCountry.value != null ? countriesAndCities[selectedCountry.value]! : [];

  // دالة لتغيير الدولة وتصفير المدينة تلقائياً
  void changeCountry(String? country) {
    selectedCountry.value = country;
    selectedCity.value = null; // إعادة تعيين المدينة عند تغيير البلد
  }

  void toggleLoginPassword() => isLoginPasswordHidden.value = !isLoginPasswordHidden.value;
  void toggleRegisterPassword() => isRegisterPasswordHidden.value = !isRegisterPasswordHidden.value;
  void toggleConfirmRegisterPassword() => isConfirmRegisterPasswordHidden.value = !isConfirmRegisterPasswordHidden.value;

  // دالة تسجيل الدخول (نفسها بدون تغيير)
  Future<void> login() async {
    if (loginEmailController.text.isEmpty || loginPasswordController.text.isEmpty) {
      Get.snackbar('تنبيه', 'يرجى إدخال البريد الإلكتروني وكلمة المرور', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final response = await _authRepository.loginUser(
        loginEmailController.text.trim(),
        loginPasswordController.text,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final token = data['access_token'];
        final role = data['user']['role'];
        final name = data['user']['name']; // جلب الاسم من الـ API

        await _storageService.saveToken(token);
        await _storageService.saveUserRole(role);
        await _storageService.saveUserName(name); // حفظ اسم المستخدم

        if (role == 'customer') {
          Get.offAllNamed('/user_dashboard');
        } else if (role == 'agent') {
          Get.offAllNamed('/agent_dashboard');
        } else {
          Get.offAllNamed('/user_dashboard');
        }
      }
    } on DioException catch (e) {
      String errorMessage = 'حدث خطأ غير متوقع';
      if (e.response?.statusCode == 401) {
        errorMessage = 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      }
      Get.snackbar('خطأ', errorMessage, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  // دالة إنشاء حساب 
  Future<void> register() async {
    if (registerPasswordController.text != confirmRegisterPasswordController.text) {
      Get.snackbar('خطأ', 'كلمتا المرور غير متطابقتين!', backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (selectedCountry.value == null || selectedCity.value == null) {
      Get.snackbar('تنبيه', 'يرجى اختيار البلد والمدينة', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final response = await _authRepository.registerUser({
        'name': fullNameController.text.trim(),
        'email': registerEmailController.text.trim(),
        'phone': registerPhoneController.text.trim(),
        'password': registerPasswordController.text,
        'role': 'customer',
        // إرسال أسماء الدولة والمدينة للباك اند ليقوم بتحويلها إلى ID وحفظها للزبون
        'country_name': selectedCountry.value,
        'city_name': selectedCity.value,
      });

      if (response.statusCode == 201) {
        Get.snackbar('نجاح', 'تم إنشاء الحساب بنجاح، يمكنك الآن تسجيل الدخول', backgroundColor: Colors.green, colorText: Colors.white);
        Get.offNamed('/login');
      }
    } on DioException catch (e) {
// ... باقي الكود يبقى كما هو (الـ catch والـ finally)
      String errorMessage = 'فشل إنشاء الحساب';
      print("Laravel Error: ${e.response?.data}");
      if (e.response?.statusCode == 422) {
        errorMessage = e.response?.data['message'] ?? 'البيانات المدخلة غير صحيحة أو مكررة';
      }
      Get.snackbar('خطأ', errorMessage, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }
  // دالة تسجيل الخروج
  Future<void> logout() async {
    // إظهار مؤشر تحميل (اختياري)
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

    try {
      // 1. الاتصال بالسيرفر لحذف التوكن (إبطال الجلسة)
      await _authRepository.logoutUser();
    } catch (e) {
      print("Logout API Error: $e"); // حتى لو فشل الاتصال سنكمل عملية الخروج محلياً
    } finally {
      // 2. حذف التوكن والبيانات من الذاكرة المحلية للتطبيق
      await _storageService.clearAuthData();
      
      // 3. إغلاق كل الشاشات المفتوحة والتوجه لصفحة تسجيل الدخول
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