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

  // ✅ الرقم الكامل مع كود الدولة — يُعبّأ من IntlPhoneField
  var receiverPhoneFullNumber = RxnString();

  void setReceiverPhone(String completeNumber) {
    receiverPhoneFullNumber.value = completeNumber;
  }

  var selectedSendCurrency = RxnInt();
  var selectedReceiveCurrency = RxnInt();
  var selectedCountry = RxnInt();
  var selectedCity = RxnString();
  var selectedOffice = RxnInt();

  var currencies = <Map<String, dynamic>>[].obs;
  var countries = <Map<String, dynamic>>[].obs;
  var offices = <Map<String, dynamic>>[].obs;
  var availableCities = <String>[].obs;

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
  var appliedRateLabel = ''.obs;
  var receiveEquivalent = '0.00'.obs;
  var receiveRateLabel = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
    amountController.addListener(_recalculate);
    ever(selectedSendCurrency, (_) => _recalculate());
    ever(selectedReceiveCurrency, (_) => _recalculate());
  }

  void _recalculate() {
    if (amountController.text.isEmpty || selectedSendCurrency.value == null) {
      equivalentUsd.value = '0.00';
      appliedRateLabel.value = '';
      return;
    }
    final double? amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      equivalentUsd.value = '0.00';
      appliedRateLabel.value = '';
      return;
    }
    final currency = currencies.firstWhere(
          (c) => c['id'] == selectedSendCurrency.value,
      orElse: () => {},
    );
    if (currency.isEmpty) return;

    final result = _getEffectiveRate(currency, amount);
    final usdAmount = amount * (result['rate'] as double);
    equivalentUsd.value = usdAmount.toStringAsFixed(2);
    appliedRateLabel.value = result['label'] as String;

    if (selectedReceiveCurrency.value != null) {
      final receiveCurrency = currencies.firstWhere(
            (c) => c['id'] == selectedReceiveCurrency.value,
        orElse: () => {},
      );
      if (receiveCurrency.isNotEmpty) {
        final receiveResult = _getEffectiveRate(receiveCurrency, amount);
        receiveEquivalent.value = (usdAmount / (receiveResult['rate'] as double)).toStringAsFixed(2);
        receiveRateLabel.value = receiveCurrency['code']?.toString() ?? '';
      }
    } else {
      receiveEquivalent.value = '0.00';
      receiveRateLabel.value = '';
    }
  }

  Map<String, dynamic> _getEffectiveRate(Map<String, dynamic> currency, double amount) {
    final List rates = currency['rates'] ?? [];

    if (rates.isNotEmpty) {
      final sorted = List.from(rates)
        ..sort((a, b) =>
            (double.tryParse(a['min_amount'].toString()) ?? 0)
                .compareTo(double.tryParse(b['min_amount'].toString()) ?? 0));

      for (final tier in sorted) {
        final double min = double.tryParse(tier['min_amount'].toString()) ?? 0;
        final double max = tier['max_amount'] != null
            ? double.tryParse(tier['max_amount'].toString()) ?? double.infinity
            : double.infinity;
        final double rate = double.tryParse(tier['rate'].toString()) ?? 0;

        if (amount >= min && amount <= max) {
          final label = tier['max_amount'] != null
              ? 'شريحة ${_fmt(min)} – ${_fmt(max)}'
              : 'شريحة ${_fmt(min)}+';
          return {'rate': rate, 'label': label};
        }
      }
    }

    final double baseRate = double.tryParse(currency['price'].toString()) ?? 1.0;
    return {'rate': baseRate, 'label': 'السعر الأساسي'};
  }

  String _fmt(double v) =>
      v.truncateToDouble() == v ? v.toInt().toString() : v.toString();

  void calculateUsd() => _recalculate();

  void onCountryChanged(int? countryId) {
    selectedCountry.value = countryId;
    selectedCity.value = null;

    if (countryId != null) {
      var country = countries.firstWhere((c) => c['id'] == countryId, orElse: () => {});
      if (country.isNotEmpty) {
        String countryName = country['name'];
        availableCities.assignAll(citiesMap[countryName] ?? ['العاصمة', 'أخرى']);
      }
    } else {
      availableCities.clear();
    }
  }

  Future<void> fetchInitialData() async {
    isFetchingData.value = true;
    try {
      final results = await Future.wait([
        _apiClient.dio.get('/currencies'),
        _apiClient.dio.get('/countries'),
        _apiClient.dio.get('/offices'),
      ]);

      final currencyRes = results[0];
      final countryRes = results[1];
      final officeRes = results[2];

      if (currencyRes.statusCode == 200) {
        final raw = currencyRes.data is List
            ? currencyRes.data
            : currencyRes.data['data'];
        currencies.assignAll(List<Map<String, dynamic>>.from(raw));
      }

      if (countryRes.statusCode == 200) {
        final raw = countryRes.data is List
            ? countryRes.data
            : countryRes.data['data'];
        countries.assignAll(List<Map<String, dynamic>>.from(raw));
      }

      if (officeRes.statusCode == 200) {
        final raw = officeRes.data is List
            ? officeRes.data
            : officeRes.data['data'];
        offices.assignAll(List<Map<String, dynamic>>.from(raw));
      }
    } catch (e) {
      print("Error fetching initial data: $e");
      Get.snackbar('خطأ', 'فشل في جلب البيانات',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isFetchingData.value = false;
    }
  }

  Future<void> submitTransfer() async {
    if (amountController.text.isEmpty ||
        receiverNameController.text.isEmpty) {
      Get.snackbar('تنبيه', 'يرجى تعبئة الحقول النصية',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    // ✅ التحقق من رقم الهاتف الكامل
    if (receiverPhoneFullNumber.value == null ||
        receiverPhoneFullNumber.value!.isEmpty) {
      Get.snackbar('تنبيه', 'يرجى إدخال رقم هاتف المستلم',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    if (selectedSendCurrency.value == null ||
        selectedReceiveCurrency.value == null ||
        selectedCountry.value == null ||
        selectedCity.value == null) {
      Get.snackbar('تنبيه', 'يرجى اختيار العملات، الدولة، والمدينة',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final Map<String, dynamic> body = {
        'amount': amountController.text.trim(),
        'send_currency_id': selectedSendCurrency.value,
        'currency_id': selectedReceiveCurrency.value,
        'destination_country_id': selectedCountry.value,
        'destination_city': selectedCity.value,
        'receiver_name': receiverNameController.text.trim(),
        // ✅ الرقم الكامل مع كود الدولة
        'receiver_phone': receiverPhoneFullNumber.value!.trim(),
      };

      if (selectedOffice.value != null) {
        body['destination_office_id'] = selectedOffice.value;
      }

      final response = await _apiClient.dio.post('/transfers', data: body);

      if (response.statusCode == 201) {
        Get.snackbar(
          'نجاح ✓',
          'تم إرسال الحوالة الدولية بنجاح',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        _resetForm();
      }
    } on DioException catch (e) {
      String msg = 'فشل إرسال الحوالة';
      if (e.response?.statusCode == 422) {
        msg = e.response?.data['message'] ?? 'تحقق من صحة البيانات';
      }
      Get.snackbar('خطأ', msg,
          backgroundColor: Colors.red, colorText: Colors.white);
      print(e.response?.data);
    } finally {
      isLoading.value = false;
    }
  }

  void _resetForm() {
    amountController.clear();
    receiverNameController.clear();
    receiverPhoneController.clear();
    receiverPhoneFullNumber.value = null;
    selectedSendCurrency.value = null;
    selectedReceiveCurrency.value = null;
    selectedCountry.value = null;
    selectedCity.value = null;
    selectedOffice.value = null;
    equivalentUsd.value = '0.00';
    appliedRateLabel.value = '';
    receiveEquivalent.value = '0.00';
    receiveRateLabel.value = '';
    availableCities.clear();
  }

  @override
  void onClose() {
    amountController.dispose();
    receiverNameController.dispose();
    receiverPhoneController.dispose();
    super.onClose();
  }
}