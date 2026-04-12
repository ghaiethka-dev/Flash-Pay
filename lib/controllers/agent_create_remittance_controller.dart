import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../data/network/api_client.dart';

/// كنترولر إرسال الحوالة الخاص بالوكيل
/// الفرق عن الزبون:
///   • يختار مكتب التسليم
///   • عملة الاستلام: دولار أو ليرة سورية فقط
///   • الأموال تذهب إلى super_safe
///   • نسبة من fee تُضاف تلقائياً إلى صندوق المندوب (يحسبها الباك)
class AgentCreateRemittanceController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  var isLoading = false.obs;
  var isFetchingData = true.obs;

  final amountController = TextEditingController();
  final receiverNameController = TextEditingController();
  final receiverPhoneController = TextEditingController();

  // عملة الإرسال (كل العملات)
  var selectedSendCurrency = RxnInt();

  // عملة الاستلام — ثابتة: دولار أو ليرة فقط
  // 'usd' أو 'syp'
  var selectedReceiveCurrencyCode = RxnString();

  var selectedGovernorate = RxnString();

  // مكتب التسليم
  var selectedOfficeId = RxnInt();
  var offices = <Map<String, dynamic>>[].obs;

  var currencies = <Map<String, dynamic>>[].obs;

  var equivalentUsd = '0.00'.obs;
  var appliedRateLabel = ''.obs;

  // عملتا الاستلام الثابتتان
  static const List<Map<String, String>> receiveCurrencies = [
    {'code': 'usd', 'name': 'دولار أمريكي (USD)'},
    {'code': 'syp', 'name': 'ليرة سورية (SYP)'},
  ];

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
    equivalentUsd.value = (amount * (result['rate'] as double)).toStringAsFixed(2);
    appliedRateLabel.value = result['label'] as String;
  }

  Map<String, dynamic> _getEffectiveRate(
      Map<String, dynamic> currency, double amount) {
    final List rates = currency['rates'] ?? [];

    if (rates.isNotEmpty) {
      final sorted = List.from(rates)
        ..sort((a, b) =>
            (double.tryParse(a['min_amount'].toString()) ?? 0)
                .compareTo(double.tryParse(b['min_amount'].toString()) ?? 0));

      for (final tier in sorted) {
        final double min =
            double.tryParse(tier['min_amount'].toString()) ?? 0;
        final double max = tier['max_amount'] != null
            ? double.tryParse(tier['max_amount'].toString()) ??
            double.infinity
            : double.infinity;
        final double rate =
            double.tryParse(tier['rate'].toString()) ?? 0;

        if (amount >= min && amount <= max) {
          final label = tier['max_amount'] != null
              ? 'شريحة ${_fmt(min)} – ${_fmt(max)}'
              : 'شريحة ${_fmt(min)}+';
          return {'rate': rate, 'label': label};
        }
      }
    }

    final double baseRate =
        double.tryParse(currency['price'].toString()) ?? 1.0;
    return {'rate': baseRate, 'label': 'السعر الأساسي'};
  }

  String _fmt(double v) =>
      v.truncateToDouble() == v ? v.toInt().toString() : v.toString();

  Future<void> fetchInitialData() async {
    isFetchingData.value = true;
    try {
      final results = await Future.wait([
        _apiClient.dio.get('/currencies'),
        _apiClient.dio.get('/offices'),
      ]);

      // عملات الإرسال
      final currencyRes = results[0];
      if (currencyRes.statusCode == 200) {
        final raw = currencyRes.data is List
            ? currencyRes.data
            : currencyRes.data['data'];
        currencies.assignAll(List<Map<String, dynamic>>.from(raw));
      }

      // المكاتب
      final officesRes = results[1];
      if (officesRes.statusCode == 200) {
        final raw = officesRes.data is List
            ? officesRes.data
            : officesRes.data['data'];
        offices.assignAll(List<Map<String, dynamic>>.from(raw));
      }
    } catch (e) {
      Get.snackbar('خطأ', 'فشل في جلب البيانات',
          backgroundColor: Colors.red, colorText: Colors.white);
      print('AgentCreateRemittance fetchInitialData error: $e');
    } finally {
      isFetchingData.value = false;
    }
  }

  Future<void> submitTransfer() async {
    if (amountController.text.isEmpty ||
        receiverNameController.text.isEmpty ||
        receiverPhoneController.text.isEmpty) {
      Get.snackbar('تنبيه', 'يرجى تعبئة جميع الحقول النصية',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (selectedSendCurrency.value == null) {
      Get.snackbar('تنبيه', 'يرجى اختيار عملة الإرسال',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (selectedReceiveCurrencyCode.value == null) {
      Get.snackbar('تنبيه', 'يرجى اختيار عملة الاستلام',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (selectedOfficeId.value == null) {
      Get.snackbar('تنبيه', 'يرجى اختيار مكتب التسليم',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (selectedGovernorate.value == null) {
      Get.snackbar('تنبيه', 'يرجى اختيار المحافظة',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    // تحديد currency_id لعملة الاستلام
    // نبحث في قائمة العملات عن USD أو SYP
    final receiveCode = selectedReceiveCurrencyCode.value!.toUpperCase();
    final receiveCurrency = currencies.firstWhere(
          (c) =>
          (c['code'] ?? c['name'] ?? '')
              .toString()
              .toUpperCase()
              .contains(receiveCode),
      orElse: () => {},
    );

    if (receiveCurrency.isEmpty) {
      Get.snackbar('خطأ', 'لم يتم العثور على عملة الاستلام في قاعدة البيانات',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final response = await _apiClient.dio.post(
        '/agent/transfers',
        data: {
          'amount': amountController.text.trim(),
          'send_currency_id': selectedSendCurrency.value,
          'currency_id': receiveCurrency['id'],
          'destination_office_id': selectedOfficeId.value,
          'destination_city': selectedGovernorate.value,
          'receiver_name': receiverNameController.text.trim(),
          'receiver_phone': receiverPhoneController.text.trim(),

        },
      );

      if (response.statusCode == 201) {
        Get.snackbar(
          'نجاح ✓',
          'تم إرسال الحوالة بنجاح — جاهزة للاستلام',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          snackPosition: SnackPosition.TOP,
        );
        _resetForm();
      }
    } on DioException catch (e) {
      String msg = 'فشل إرسال الحوالة';
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        if (errors != null) {
          msg = (errors as Map).values.first[0].toString();
        } else {
          msg = e.response?.data['message'] ?? msg;
        }
      }
      Get.snackbar('خطأ', msg,
          backgroundColor: Colors.red, colorText: Colors.white);
      print('AgentCreateRemittance error: ${e.response?.data}');
    } finally {
      isLoading.value = false;
    }
  }

  void _resetForm() {
    amountController.clear();
    receiverNameController.clear();
    receiverPhoneController.clear();
    selectedSendCurrency.value = null;
    selectedReceiveCurrencyCode.value = null;
    selectedOfficeId.value = null;
    selectedGovernorate.value = null;
    equivalentUsd.value = '0.00';
    appliedRateLabel.value = '';
  }

  @override
  void onClose() {
    amountController.dispose();
    receiverNameController.dispose();
    receiverPhoneController.dispose();
    super.onClose();
  }
}