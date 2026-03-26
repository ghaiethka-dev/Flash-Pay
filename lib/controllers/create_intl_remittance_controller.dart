import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../data/network/api_client.dart';

class CreateIntlRemittanceController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  var isLoading = false.obs;
  var isFetchingData = true.obs; 

  final amountController = TextEditingController();
  final receiverNameController = TextEditingController();
  final receiverPhoneController = TextEditingController();

  var selectedSendCurrency = RxnInt(); 
  var selectedReceiveCurrency = RxnInt(); 
  var selectedCountry = RxnInt(); 
  var selectedAgent = RxnInt(); // الوكيل المحلي (إجباري)
  var selectedCity = RxnString(); // المدينة المختارة

  var currencies = <Map<String, dynamic>>[].obs;
  var countries = <Map<String, dynamic>>[].obs; 
  var agents = <Map<String, dynamic>>[].obs; // قائمة الوكلاء
  var availableCities = <String>[].obs; // قائمة المدن التي ستتغير حسب الدولة

  // الماب الجاهز للدول ومدنها (يمكنك تعديل الأسماء لتطابق ما يرجع من السيرفر لديك)
  final Map<String, List<String>> citiesMap = {
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

  var equivalentUsd = '0.00'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
    amountController.addListener(calculateUsd);
    ever(selectedSendCurrency, (_) => calculateUsd());
  }

  void calculateUsd() {
    if (amountController.text.isEmpty || selectedSendCurrency.value == null) {
      equivalentUsd.value = '0.00';
      return;
    }
    double? amount = double.tryParse(amountController.text);
    if (amount == null) return;

    var currency = currencies.firstWhere((c) => c['id'] == selectedSendCurrency.value, orElse: () => {});
    if (currency.isNotEmpty && currency['price'] != null) {
      double price = double.parse(currency['price'].toString());
      equivalentUsd.value = (amount * price).toStringAsFixed(2);
    }
  }

  // دالة تُستدعى عند تغيير الدولة لجلب مدنها
  void onCountryChanged(int? countryId) {
    selectedCountry.value = countryId;
    selectedCity.value = null; // تصفير المدينة المختارة
    
    if (countryId != null) {
      var country = countries.firstWhere((c) => c['id'] == countryId, orElse: () => {});
      if (country.isNotEmpty) {
        String countryName = country['name'];
        // جلب المدن، وإذا لم تكن الدولة في الماب نعرض "العاصمة" كخيار افتراضي
        availableCities.assignAll(citiesMap[countryName] ?? ['العاصمة', 'أخرى']);
      }
    } else {
      availableCities.clear();
    }
  }

  Future<void> fetchInitialData() async {
    isFetchingData.value = true;
    try {
      // 1. جلب العملات
      final currencyRes = await _apiClient.dio.get('/currencies');
      if (currencyRes.statusCode == 200) {
        if (currencyRes.data is List) {
          currencies.assignAll(List<Map<String, dynamic>>.from(currencyRes.data));
        } else {
          currencies.assignAll(List<Map<String, dynamic>>.from(currencyRes.data['data']));
        }
      }

      // 2. جلب الدول
      final countryRes = await _apiClient.dio.get('/countries');
      if (countryRes.statusCode == 200) {
        if (countryRes.data is List) {
          countries.assignAll(List<Map<String, dynamic>>.from(countryRes.data));
        } else {
          countries.assignAll(List<Map<String, dynamic>>.from(countryRes.data['data']));
        }
      }

      // 3. جلب الوكلاء
      final agentRes = await _apiClient.dio.get('/agents');
      if (agentRes.statusCode == 200) {
        if (agentRes.data is List) {
          agents.assignAll(List<Map<String, dynamic>>.from(agentRes.data));
        } else {
          agents.assignAll(List<Map<String, dynamic>>.from(agentRes.data['data']));
        }
      }

    } catch (e) {
      print("Error fetching initial data: $e"); // لطباعة الخطأ في التيرمنال إن وجد
      Get.snackbar('خطأ', 'فشل في جلب البيانات', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isFetchingData.value = false;
    }
  }

  Future<void> submitTransfer() async {
    if (amountController.text.isEmpty || receiverNameController.text.isEmpty || receiverPhoneController.text.isEmpty) {
      Get.snackbar('تنبيه', 'يرجى تعبئة الحقول النصية', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (selectedSendCurrency.value == null || selectedReceiveCurrency.value == null || selectedCountry.value == null || selectedCity.value == null || selectedAgent.value == null) {
      Get.snackbar('تنبيه', 'يرجى اختيار العملات، الدولة، المدينة، والوكيل', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final response = await _apiClient.dio.post(
        '/transfers', 
        data: {
          'amount': amountController.text.trim(),
          'send_currency_id': selectedSendCurrency.value,
          'currency_id': selectedReceiveCurrency.value,
          'destination_country_id': selectedCountry.value, 
          'destination_city': selectedCity.value, // إرسال اسم المدينة
          'destination_agent_id': selectedAgent.value, // إرسال الوكيل المحلي
          'receiver_name': receiverNameController.text.trim(),
          'receiver_phone': receiverPhoneController.text.trim(),
        },
      );

      if (response.statusCode == 201) {
        Get.snackbar('نجاح', 'تم إرسال الحوالة الدولية بنجاح', backgroundColor: Colors.green, colorText: Colors.white);
        amountController.clear();
        receiverNameController.clear();
        receiverPhoneController.clear();
        selectedSendCurrency.value = null;
        selectedReceiveCurrency.value = null;
        selectedCountry.value = null;
        selectedCity.value = null;
        selectedAgent.value = null;
      }
    } on DioException catch (e) {
      Get.snackbar('خطأ', 'فشل إرسال الحوالة', backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    amountController.dispose();
    receiverNameController.dispose();
    receiverPhoneController.dispose();
    super.onClose();
  }
}