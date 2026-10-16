import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../data/network/api_client.dart';
import 'package:flashpay/core/api_error.dart';
import 'package:flashpay/core/fp_feedback.dart';
import 'package:flashpay/core/validators.dart';

class AgentCreateRemittanceController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  var isLoading = false.obs;
  var isFetchingData = true.obs;

  /// يزيد بعد كل إرسال ناجح؛ الشاشة تستمع له لتصفير حالة التحقق في النموذج
  var resetTick = 0.obs;

  final amountController = TextEditingController();
  final receiverNameController = TextEditingController();
  final receiverPhoneController = TextEditingController();

  var receiverPhoneFullNumber = RxnString();

  void setReceiverPhone(String completeNumber) {
    receiverPhoneFullNumber.value = completeNumber;
  }

  var selectedSendCurrency = RxnInt();
  var selectedReceiveCurrencyCode = RxnString();
  var selectedGovernorate = RxnString();
  var selectedOfficeId = RxnInt();
  var offices = <Map<String, dynamic>>[].obs;
  var currencies = <Map<String, dynamic>>[].obs;

  var equivalentUsd = '0.00'.obs;
  var appliedRateLabel = ''.obs;
  var receiveEquivalent = '0.00'.obs;
  var receiveRateLabel = ''.obs;

  static const List<Map<String, String>> receiveCurrencies = [
    {'code': 'usd', 'name': 'دولار أمريكي (USD)'},
    {'code': 'syp', 'name': 'ليرة سورية (SYP)'},
  ];

  static const List<String> syrianGovernorates = [
    'دمشق', 'ريف دمشق', 'حلب', 'حمص', 'حماة', 'اللاذقية', 'طرطوس',
    'إدلب', 'دير الزور', 'الحسكة', 'القامشلي', 'الرقة', 'درعا', 'السويداء', 'القنيطرة',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
    amountController.addListener(_recalculate);
    ever(selectedSendCurrency, (_) => _recalculate());
    ever(selectedReceiveCurrencyCode, (_) => _recalculate());
  }

  void _recalculate() {
    if (amountController.text.isEmpty || selectedSendCurrency.value == null) {
      equivalentUsd.value = '0.00';
      appliedRateLabel.value = '';
      receiveEquivalent.value = '0.00';
      receiveRateLabel.value = '';
      return;
    }
    final double? amount = double.tryParse(FPValidators.cleanAmount(amountController.text));
    if (amount == null || amount <= 0) {
      equivalentUsd.value = '0.00';
      appliedRateLabel.value = '';
      receiveEquivalent.value = '0.00';
      receiveRateLabel.value = '';
      return;
    }

    final currency = currencies.firstWhere(
          (c) => c['id'] == selectedSendCurrency.value,
      orElse: () => {},
    );
    if (currency.isEmpty) return;

    try {
      // المكافئ بالدولار: يبقى دائماً بأسعار الدولار (هو ما يُحفظ في amount_in_usd)
      final result = _getEffectiveRate(currency, amount);
      final usdAmount = amount * (result['rate'] as double);
      equivalentUsd.value = usdAmount.toStringAsFixed(2);
      appliedRateLabel.value = result['label'] as String;

      if (selectedReceiveCurrencyCode.value != null) {
        final receiveCode = selectedReceiveCurrencyCode.value!.toUpperCase();
        if (receiveCode == 'USD') {
          // استلام بالدولار ← تصريف دولار
          receiveEquivalent.value = usdAmount.toStringAsFixed(2);
          receiveRateLabel.value = 'USD';
        } else if (receiveCode == 'SYP') {
          // ✅ استلام بالسوري ← التصريف بأسعار السوري
          _applySypReceive(currency, amount);
        }
      } else {
        receiveEquivalent.value = '0.00';
        receiveRateLabel.value = '';
      }
    } catch (e) {
      equivalentUsd.value = 'خطأ';
      appliedRateLabel.value = e.toString();
      print('❌ Rate calc error: $e');
    }
  }

  bool _isSypCode(dynamic code) =>
      (code ?? '').toString().toUpperCase() == 'SYP';

  /// يحسب سعر الصرف لمبلغ بنفس عملة [currency] المُمرَّرة.
  /// - [syp] = false ← أسعار الدولار (rates / price) كما كان تماماً.
  /// - [syp] = true  ← أسعار السوري (syp_rates / price_syp)، وتُستخدم عندما تكون عملة الاستلام SYP.
  ///
  /// - إن وُجدت شرائح تغطي [amount] ← تُستخدم شريحتها.
  /// - إن لم تكن هناك شرائح أصلاً ← السعر المرجعي (price للدولار، price_syp للسوري).
  /// - إن وُجدت شرائح لكنها لا تغطي [amount] ← خطأ صريح (سوء إعداد فعلي).
  Map<String, dynamic> _getEffectiveRate(
      Map<String, dynamic> currency, double amount,
      {bool syp = false}) {
    // إرسال بالليرة واستلام بالليرة: لا يوجد تصريف
    if (syp && _isSypCode(currency['code'])) {
      return {'rate': 1.0, 'label': 'ليرة سورية'};
    }

    final List rates = (syp ? currency['syp_rates'] : currency['rates']) ?? [];

    if (rates.isEmpty) {
      // main_price سعر تكلفة داخلي — يُستخدم للدولار فقط كحل أخير (السلوك القديم)
      final dynamic rawBase =
      syp ? currency['price_syp'] : (currency['price'] ?? currency['main_price']);
      final double? baseRate = double.tryParse((rawBase ?? '').toString());
      if (baseRate == null || baseRate <= 0) {
        throw Exception(syp
            ? 'لا يوجد سعر صرف بالسوري للعملة ${currency['code']}'
            : 'العملة ${currency['code']} ليس لديها شرائح أسعار ولا سعر مرجعي (price/main_price)');
      }
      return {
        'rate': baseRate,
        'label': syp ? 'السعر الأساسي (سوري)' : 'السعر الأساسي',
      };
    }

    final sorted = List<Map<String, dynamic>>.from(rates)
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
        final range = tier['max_amount'] != null
            ? 'شريحة ${_fmt(min)} – ${_fmt(max)}'
            : 'شريحة ${_fmt(min)}+';
        return {'rate': rate, 'label': syp ? 'سوري — $range' : range};
      }
    }

    throw Exception(
        'لا توجد شريحة سعرية${syp ? ' بالسوري' : ''} للمبلغ $amount في ${currency['code']}');
  }

  /// ✅ عملة الاستلام SYP: تصريف بأسعار السوري للعملة المُرسَلة.
  /// المبلغ المستلَم = المبلغ × سعر السوري (نفس ما يحسبه الـ API في amount_in_syp).
  void _applySypReceive(Map<String, dynamic> sendCurrency, double amount) {
    try {
      final r = _getEffectiveRate(sendCurrency, amount, syp: true);
      receiveEquivalent.value =
          (amount * (r['rate'] as double)).toStringAsFixed(0);
      receiveRateLabel.value = 'SYP';
      appliedRateLabel.value = r['label'] as String;
    } catch (e) {
      receiveEquivalent.value = '0.00';
      receiveRateLabel.value = '';
      appliedRateLabel.value = e.toString().replaceFirst('Exception: ', '');
    }
  }

  /// ✅ يحسب مكافئ عملة الاستلام من [usdAmount] باختيار شريحة الاستلام
  /// الصحيحة بناءً على المبلغ التقديري بعملة الاستلام نفسها. يستبدل
  /// _getSypRate القديمة التي كانت تأخذ أول شريحة دائماً بلا أي اعتبار
  /// للمبلغ الفعلي.
  Map<String, dynamic> _getReceiveConversion(
      Map<String, dynamic> receiveCurrency, double usdAmount) {
    final double? baseRate = double.tryParse(
      (receiveCurrency['price'] ?? receiveCurrency['main_price'] ?? '').toString(),
    );

    double estimatedAmount;
    if (baseRate != null && baseRate > 0) {
      estimatedAmount = usdAmount / baseRate;
    } else {
      final List rates = receiveCurrency['rates'] ?? [];
      if (rates.isEmpty) {
        throw Exception('العملة ${receiveCurrency['code']} ليس لديها سعر مرجعي ولا شرائح لتقدير المبلغ');
      }
      final sorted = List<Map<String, dynamic>>.from(rates)
        ..sort((a, b) => (double.tryParse(a['min_amount'].toString()) ?? 0)
            .compareTo(double.tryParse(b['min_amount'].toString()) ?? 0));
      final double firstRate = double.tryParse(sorted.first['rate'].toString()) ?? 0;
      if (firstRate <= 0) {
        throw Exception('تعذر تقدير مبلغ ${receiveCurrency['code']} (سعر الشريحة الأولى غير صالح)');
      }
      estimatedAmount = usdAmount / firstRate;
    }

    final result = _getEffectiveRate(receiveCurrency, estimatedAmount);
    final double finalRate = result['rate'] as double;

    return {
      'amount': usdAmount / finalRate,
      'label': result['label'],
    };
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

      final currencyRes = results[0];
      if (currencyRes.statusCode == 200) {
        final raw = _extractListFromResponse(currencyRes.data);
        currencies.assignAll(List<Map<String, dynamic>>.from(raw));

        for (var c in currencies) {
          final rates = c['rates'] ?? [];
          print('💱 ${c['code']} (id:${c['id']}) — USD rates: ${rates.length} | SYP rates: ${(c['syp_rates'] ?? []).length} | price_syp: ${c['price_syp']}');
          for (var r in rates) {
            print('   📊 ${r['min_amount']}–${r['max_amount']} @ ${r['rate']}');
          }
        }
      }

      final officesRes = results[1];
      if (officesRes.statusCode == 200) {
        final raw = _extractListFromResponse(officesRes.data);
        offices.assignAll(List<Map<String, dynamic>>.from(raw));
      }
    } catch (e) {
      FPFeedback.error(
        ApiError.message(e, fallback: 'فشل في جلب بيانات الحوالة'),
        title: 'تعذّر تحميل البيانات',
      );
      print('AgentCreateRemittance fetchInitialData error: $e');
    } finally {
      isFetchingData.value = false;
    }
  }

  List<dynamic> _extractListFromResponse(dynamic response) {
    if (response is List) return response;
    if (response is Map) {
      return response['data'] ??
          response['currencies'] ??
          response['offices'] ??
          response['result'] ??
          [];
    }
    return [];
  }

  /// أول خطأ في النموذج (بترتيب ظهور الحقول)، أو null إذا كان كل شيء صحيحًا.
  String? _formError() {
    return FPValidators.amount(amountController.text) ??
        (selectedSendCurrency.value == null ? 'اختر عملة الإرسال' : null) ??
        (selectedReceiveCurrencyCode.value == null
            ? 'اختر عملة الاستلام'
            : null) ??
        (selectedOfficeId.value == null ? 'اختر مكتب التسليم' : null) ??
        (selectedGovernorate.value == null ? 'اختر المحافظة' : null) ??
        FPValidators.fullName(receiverNameController.text, who: 'اسم المستلم') ??
        ((receiverPhoneFullNumber.value ?? '').trim().isEmpty
            ? 'أدخل رقم هاتف المستلم'
            : null);
  }

  Future<void> submitTransfer() async {
    if (isLoading.value) return;

    final formError = _formError();
    if (formError != null) {
      FPFeedback.error(formError, title: 'تحقق من البيانات');
      return;
    }

    final receiveCode = selectedReceiveCurrencyCode.value!.toUpperCase();
    final receiveCurrency = currencies.firstWhere(
          (c) => (c['code'] ?? '').toString().toUpperCase() == receiveCode,
      orElse: () => {},
    );

    if (receiveCurrency.isEmpty) {
      FPFeedback.error(
          'عملة الاستلام المختارة غير متاحة حاليًا، أعد فتح الصفحة وحاول مرة أخرى');
      return;
    }

    isLoading.value = true;
    try {
      final response = await _apiClient.dio.post(
        '/agent/transfers',
        data: {
          'amount': FPValidators.cleanAmount(amountController.text),
          'send_currency_id': selectedSendCurrency.value,
          'currency_id': receiveCurrency['id'],
          'destination_office_id': selectedOfficeId.value,
          'destination_city': selectedGovernorate.value,
          'receiver_name': receiverNameController.text.trim(),
          'receiver_phone': receiverPhoneFullNumber.value!.trim(),
        },
      );

      if (response.statusCode == 201) {
        FPFeedback.success('تم إرسال الحوالة بنجاح — جاهزة للاستلام');
        _resetForm();
      }
    } on DioException catch (e) {
      FPFeedback.error(
        ApiError.message(e, fallback: 'فشل إرسال الحوالة'),
        title: 'تعذّر إرسال الحوالة',
      );
      print(e.response?.data);
    } catch (e) {
      print('submitTransfer unexpected error: $e');
      FPFeedback.error('حدث خطأ غير متوقع أثناء إرسال الحوالة، حاول مرة أخرى');
    } finally {
      isLoading.value = false;
    }
  }

  void _resetForm() {
    resetTick.value++;
    amountController.clear();
    receiverNameController.clear();
    receiverPhoneController.clear();
    receiverPhoneFullNumber.value = null;
    selectedSendCurrency.value = null;
    selectedReceiveCurrencyCode.value = null;
    selectedOfficeId.value = null;
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