import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
// تأكد من استدعاء مسار ApiClient الذي أنشأناه سابقاً
import '../data/network/api_client.dart'; 

class CreateRemittanceController extends GetxController {
  final ApiClient _apiClient = ApiClient();

  var isLoading = false.obs;
  var isFetchingData = true.obs; // للتحكم بمؤشر التحميل عند فتح الصفحة

  // حقول الإدخال
  final amountController = TextEditingController();
  final receiverNameController = TextEditingController();
  final receiverPhoneController = TextEditingController();

  // متغيرات القوائم المنسدلة (تحفظ الـ ID كأرقام لأن Laravel يطلب IDs)
  var selectedCurrency = RxnInt();
  var selectedOffice = RxnInt();
  var selectedAgent = RxnInt();

  // قوائم البيانات التي سنملؤها من السيرفر
  var currencies = <Map<String, dynamic>>[].obs;
  var offices = <Map<String, dynamic>>[].obs;
  var agents = <Map<String, dynamic>>[].obs;

  var equivalentUsd = '0.00'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInitialData();
    // مراقبة كتابة المستخدم
    amountController.addListener(calculateUsd);
    ever(selectedCurrency, (_) => calculateUsd());
  }

  void calculateUsd() {
    if (amountController.text.isEmpty || selectedCurrency.value == null) {
      equivalentUsd.value = '0.00';
      return;
    }
    double? amount = double.tryParse(amountController.text);
    if (amount == null) return;

    var currency = currencies.firstWhere((c) => c['id'] == selectedCurrency.value, orElse: () => {});
    if (currency.isNotEmpty && currency['price'] != null) {
      double price = double.parse(currency['price'].toString());
      equivalentUsd.value = (amount / price).toStringAsFixed(2); 
      // ملاحظة: قسمة (/) أو ضرب (*) تعتمد على نوع الـ API، API المستخدم يعطي سعر الدولار مقابل العملة، لذا نستخدم القسمة.
    }
  }
  // دالة جلب العملات والمكاتب من Laravel
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

      // 2. جلب المكاتب
      final officeRes = await _apiClient.dio.get('/offices');
      if (officeRes.statusCode == 200) {
        if (officeRes.data is List) {
          offices.assignAll(List<Map<String, dynamic>>.from(officeRes.data));
        } else {
          offices.assignAll(List<Map<String, dynamic>>.from(officeRes.data['data']));
        }
      }

      // 3. جلب الوكلاء الفعليين
      final agentRes = await _apiClient.dio.get('/agents');
      if (agentRes.statusCode == 200) {
        if (agentRes.data is List) {
          agents.assignAll(List<Map<String, dynamic>>.from(agentRes.data));
        } else {
          agents.assignAll(List<Map<String, dynamic>>.from(agentRes.data['data']));
        }
      }

    } catch (e) {
      Get.snackbar('خطأ', 'فشل في جلب البيانات من الخادم', backgroundColor: Colors.red, colorText: Colors.white);
      print("Error fetching data: $e"); 
    } finally {
      isFetchingData.value = false;
    }
  }

  // دالة إرسال الحوالة إلى الخادم
  Future<void> submitTransfer() async {
    // التحقق من الحقول
    if (amountController.text.isEmpty || receiverNameController.text.isEmpty || receiverPhoneController.text.isEmpty) {
      Get.snackbar('تنبيه', 'يرجى تعبئة جميع الحقول النصية', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }
    if (selectedCurrency.value == null || selectedOffice.value == null || selectedAgent.value == null) {
      Get.snackbar('تنبيه', 'يرجى اختيار العملة والمكتب والوكيل', backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final response = await _apiClient.dio.post(
        '/transfers', // مسار إنشاء الحوالة
        data: {
          'amount': amountController.text.trim(),
          'currency_id': selectedCurrency.value,
          'destination_office_id': selectedOffice.value,
          'destination_agent_id': selectedAgent.value,
          'receiver_name': receiverNameController.text.trim(),
          'receiver_phone': receiverPhoneController.text.trim(),
        },
      );

      if (response.statusCode == 201) {
        // 1. إظهار رسالة النجاح
        Get.snackbar(
          'نجاح', 
          'تم إرسال الحوالة بنجاح وهي الآن قيد المراجعة', 
          backgroundColor: Colors.green, 
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // 2. تصفير الحقول النصية
        amountController.clear();
        receiverNameController.clear();
        receiverPhoneController.clear();

        // 3. تصفير القوائم المنسدلة
        selectedCurrency.value = null;
        selectedOffice.value = null;
        selectedAgent.value = null;
        
        // (تم إزالة Get.back() لكي تبقى الشاشة مفتوحة وجاهزة لحوالة جديدة)
      }
    } on DioException catch (e) {
      String errorMessage = 'فشل إرسال الحوالة';
      if (e.response?.statusCode == 422) {
         errorMessage = e.response?.data['message'] ?? 'تحقق من صحة البيانات المدخلة';
      }
      Get.snackbar('خطأ', errorMessage, backgroundColor: Colors.red, colorText: Colors.white);
      print(e.response?.data); 
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