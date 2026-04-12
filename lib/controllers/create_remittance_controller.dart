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
  final receiverPhoneController = TextEditingController();

  var selectedSendCurrency = RxnInt();
  var selectedReceiveCurrency = RxnInt();
  var selectedOffice = RxnInt();
  var selectedGovernorate = RxnString(); // المحافظة السورية

  var currencies = <Map<String, dynamic>>[].obs;
  var offices = <Map<String, dynamic>>[].obs;

  var equivalentUsd = '0.00'.obs;
  var appliedRateLabel = ''.obs; // الشريحة المطبّقة للعرض

  // ── قائمة المحافظات السورية ──
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

  // ── حساب الدولار مع مراعاة الشرائح ──
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

  /// يجد الشريحة المناسبة للمبلغ ويُرجع { rate, label }
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

    // fallback: السعر الأساسي
    final double baseRate = double.tryParse(currency['price'].toString()) ?? 1.0;
    return {'rate': baseRate, 'label': 'السعر الأساسي'};
  }

  String _fmt(double v) =>
      v.truncateToDouble() == v ? v.toInt().toString() : v.toString();

  // ── جلب البيانات الأولية ──
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

  // ── إرسال الحوالة ──
  Future<void> submitTransfer() async {
    if (amountController.text.isEmpty ||
        receiverNameController.text.isEmpty ||
        receiverPhoneController.text.isEmpty) {
      Get.snackbar('تنبيه', 'يرجى تعبئة جميع الحقول النصية',
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
          'receiver_phone': receiverPhoneController.text.trim(),
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
    selectedSendCurrency.value = null;
    selectedReceiveCurrency.value = null;
    selectedOffice.value = null;
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