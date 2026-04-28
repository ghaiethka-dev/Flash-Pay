import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../data/network/api_client.dart';

class CreateRemittanceController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  var isLoading = false.obs;
  var isFetchingData = true.obs;

  final amountController = TextEditingController();
  final receiverNameController = TextEditingController();
  // ✅ لا يزال موجوداً للتحكم في الـ IntlPhoneField داخلياً إن احتجنا
  final receiverPhoneController = TextEditingController();

  // ✅ الرقم الكامل مع كود الدولة — يُعبّأ من IntlPhoneField
  var receiverPhoneFullNumber = RxnString(); // مثال: "+963912345678"

  void setReceiverPhone(String completeNumber) {
    receiverPhoneFullNumber.value = completeNumber;
  }

  var selectedSendCurrency = RxnInt();
  var selectedReceiveCurrency = RxnInt();
  var selectedOffice = RxnInt();
  var selectedGovernorate = RxnString();

  var currencies = <Map<String, dynamic>>[].obs;
  var offices = <Map<String, dynamic>>[].obs;

  var equivalentUsd = '0.00'.obs;
  var appliedRateLabel = ''.obs;
  var receiveEquivalent = '0.00'.obs;
  var receiveRateLabel = ''.obs;

  static const List<String> syrianGovernorates = [
    'دمشق',
    'ريف دمشق',
    'حلب',
    'حمص',
    'حماة',
    'اللاذقية',
    'طرطوس',
    'إدلب',
    'دير الزور',
    'الحسكة',
    'القامشلي',
    'الرقة',
    'درعا',
    'السويداء',
    'القنيطرة',
  ];

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

  Future<void> fetchInitialData() async {
    isFetchingData.value = true;
    try {
      final currencyRes = await _apiClient.dio.get('/currencies');
      if (currencyRes.statusCode == 200) {
        final raw = currencyRes.data is List
            ? currencyRes.data
            : currencyRes.data['data'];
        currencies.assignAll(List<Map<String, dynamic>>.from(raw));
      }

      final officeRes = await _apiClient.dio.get('/offices');
      if (officeRes.statusCode == 200) {
        final raw = officeRes.data is List
            ? officeRes.data
            : officeRes.data['data'];
        offices.assignAll(List<Map<String, dynamic>>.from(raw));
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في جلب البيانات من الخادم',
          backgroundColor: Colors.red, colorText: Colors.white);
      print("fetchInitialData error: $e");
    } finally {
      isFetchingData.value = false;
    }
  }

  Future<void> submitTransfer() async {
    if (amountController.text.isEmpty ||
        receiverNameController.text.isEmpty) {
      Get.snackbar('تنبيه', 'يرجى تعبئة جميع الحقول النصية',
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
        selectedOffice.value == null ||
        selectedGovernorate.value == null) {
      Get.snackbar('تنبيه', 'يرجى اختيار العملات والمكتب والمحافظة',
          backgroundColor: Colors.orange, colorText: Colors.white);
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
          'destination_office_id': selectedOffice.value,
          'destination_city': selectedGovernorate.value,
          'receiver_name': receiverNameController.text.trim(),
          // ✅ الرقم الكامل مع كود الدولة
          'receiver_phone': receiverPhoneFullNumber.value!.trim(),
        },
      );

      if (response.statusCode == 201) {
        Get.snackbar(
          'نجاح ✓',
          'تم إرسال الحوالة بنجاح وهي الآن قيد المراجعة',
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
      Get.snackbar('خطأ', msg, backgroundColor: Colors.red, colorText: Colors.white);
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
    selectedOffice.value = null;
    selectedGovernorate.value = null;
    equivalentUsd.value = '0.00';
    appliedRateLabel.value = '';
    receiveEquivalent.value = '0.00';
    receiveRateLabel.value = '';
  }

  @override
  void onClose() {
    amountController.dispose();
    receiverNameController.dispose();
    receiverPhoneController.dispose();
    super.onClose();
  }
}