import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../data/network/api_client.dart';

class BankTransferController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  var isLoading = false.obs;

  // حقول النموذج
  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final fullNameController = TextEditingController();
  final recipientNameController = TextEditingController(); // ✅ الحقل الجديد
  final phoneController = TextEditingController();
  final notesController = TextEditingController();
  final amountController = TextEditingController();

  // حقول الوجهة
  var selectedCountry = ''.obs;
  var selectedCity = ''.obs;
  final List<String> countries = [
    'سوريا', 'لبنان', 'الأردن', 'العراق', 'تركيا',
    'مصر', 'السعودية', 'الإمارات', 'ألمانيا', 'السويد',
    'فرنسا', 'هولندا', 'النمسا', 'كندا', 'أمريكا', 'أخرى',
  ];
  final Map<String, List<String>> citiesByCountry = {
    'سوريا':   ['دمشق', 'حلب', 'حمص', 'اللاذقية', 'طرطوس', 'السويداء', 'درعا', 'دير الزور', 'الحسكة', 'أخرى'],
    'لبنان':   ['بيروت', 'طرابلس', 'صيدا', 'صور', 'أخرى'],
    'الأردن':  ['عمان', 'إربد', 'الزرقاء', 'العقبة', 'أخرى'],
    'العراق':  ['بغداد', 'البصرة', 'الموصل', 'أربيل', 'أخرى'],
    'تركيا':   ['إسطنبول', 'أنقرة', 'إزمير', 'أنطاكيا', 'أخرى'],
    'مصر':     ['القاهرة', 'الإسكندرية', 'الجيزة', 'أخرى'],
    'السعودية':['الرياض', 'جدة', 'مكة', 'المدينة', 'أخرى'],
    'الإمارات':['دبي', 'أبوظبي', 'الشارقة', 'أخرى'],
    'ألمانيا': ['برلين', 'ميونخ', 'هامبورغ', 'فرانكفورت', 'أخرى'],
    'السويد':  ['ستوكهولم', 'غوتنبرغ', 'مالمو', 'أخرى'],
    'فرنسا':   ['باريس', 'ليون', 'مرسيليا', 'أخرى'],
    'هولندا':  ['أمستردام', 'روتردام', 'لاهاي', 'أخرى'],
    'النمسا':  ['فيينا', 'غراتس', 'أخرى'],
    'كندا':    ['تورنتو', 'مونتريال', 'فانكوفر', 'أخرى'],
    'أمريكا':  ['نيويورك', 'لوس أنجلوس', 'شيكاغو', 'ديترويت', 'أخرى'],
    'أخرى':    ['أخرى'],
  };

  // ── حساب العملة ──
  var currencies = <Map<String, dynamic>>[].obs;
  var selectedCurrencyId = RxnInt();
  var equivalentUsd = '0.00'.obs;
  var appliedRateLabel = ''.obs;

  var bankTransfers = <Map<String, dynamic>>[].obs;
  var isFetchingTransfers = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBankTransfers();
    fetchCurrencies();
    amountController.addListener(_recalculate);
    ever(selectedCurrencyId, (_) => _recalculate());
  }

  Future<void> fetchCurrencies() async {
    try {
      final res = await _apiClient.dio.get('/currencies');
      if (res.statusCode == 200) {
        final raw = res.data is List ? res.data : res.data['data'];
        currencies.assignAll(List<Map<String, dynamic>>.from(raw));
      }
    } catch (e) {
      print('fetchCurrencies error: $e');
    }
  }

  void _recalculate() {
    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0 || selectedCurrencyId.value == null) {
      equivalentUsd.value = '0.00';
      appliedRateLabel.value = '';
      return;
    }
    final currency = currencies.firstWhere(
          (c) => c['id'] == selectedCurrencyId.value,
      orElse: () => {},
    );
    if (currency.isEmpty) return;
    final result = _getEffectiveRate(currency, amount);
    equivalentUsd.value = (amount * (result['rate'] as double)).toStringAsFixed(2);
    appliedRateLabel.value = result['label'] as String;
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

  Future<void> fetchBankTransfers() async {
    isFetchingTransfers.value = true;
    try {
      final response = await _apiClient.dio.get('/bank-transfer');
      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        bankTransfers.assignAll(data.cast<Map<String, dynamic>>());
      }
    } catch (e) {
      print('Error fetching bank transfers: $e');
    } finally {
      isFetchingTransfers.value = false;
    }
  }

  Future<void> submitBankTransfer() async {
    // التحقق من الحقول
    if (bankNameController.text.trim().isEmpty ||
        accountNumberController.text.trim().isEmpty ||
        fullNameController.text.trim().isEmpty ||
        recipientNameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        amountController.text.trim().isEmpty ||
        selectedCountry.value.isEmpty){
      Get.snackbar(
        'تنبيه',
        'يرجى تعبئة جميع الحقول الإلزامية',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      print("#######");
      return;
    }

    final double? amount = double.tryParse(amountController.text.trim());
    if (amount == null || amount <= 0) {
      Get.snackbar('تنبيه', 'يرجى إدخال مبلغ صحيح', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final response = await _apiClient.dio.post(
        '/bank-transfer',
        data: {
          'bank_name': bankNameController.text.trim(),
          'account_number': accountNumberController.text.trim(),
          'full_name': fullNameController.text.trim(),
          'recipient_name': recipientNameController.text.trim(), // ✅ إرسال الحقل للسيرفر
          'phone': phoneController.text.trim(),
          'amount': amountController.text.trim(),
          'notes': notesController.text.trim(),
          'destination_country': selectedCountry.value,
          'destination_city': selectedCity.value,
          if (selectedCurrencyId.value != null) 'currency_id': selectedCurrencyId.value,
        },
      );

      if (response.statusCode == 201) {
        Get.snackbar('تم الإرسال ✓', 'تم إرسال طلب التحويل البنكي بنجاح', backgroundColor: Colors.green, colorText: Colors.white);
        _resetForm();
        fetchBankTransfers();
      }
    } on DioException catch (e) {
      String msg = 'فشل إرسال الطلب';
      if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'];
        msg = errors != null ? (errors as Map).values.first[0].toString() : e.response?.data['message'] ?? msg;
      }
      Get.snackbar('خطأ', msg, backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void _resetForm() {
    bankNameController.clear();
    accountNumberController.clear();
    fullNameController.clear();
    recipientNameController.clear(); // ✅
    phoneController.clear();
    notesController.clear();
    amountController.clear();
    selectedCountry.value = '';
    selectedCity.value = '';
    selectedCurrencyId.value = null;
    equivalentUsd.value = '0.00';
    appliedRateLabel.value = '';
  }

  String statusLabel(String status) {
    switch (status) {
      case 'pending': return 'بانتظار الموافقة';
      case 'approved': return 'موافق عليه';
      case 'admin_approved': return 'بانتظار التسليم'; // ✅ إضافة الحالة الجديدة
      case 'completed': return 'مكتمل';
      case 'rejected': return 'مرفوض';
      default: return status;
    }
  }

  Color statusColor(String status) {
    switch (status) {
      case 'pending': return Colors.orange;
      case 'admin_approved': return Colors.blue;
      case 'approved': return Colors.green;
      case 'completed': return Colors.green.shade800;
      case 'rejected': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  void onClose() {
    bankNameController.dispose();
    accountNumberController.dispose();
    fullNameController.dispose();
    recipientNameController.dispose(); // ✅
    phoneController.dispose();
    notesController.dispose();
    amountController.dispose();
    super.onClose();
  }
}