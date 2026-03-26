import 'dart:convert';
import 'dart:io';
import 'package:flashpay/data/network/api_client.dart';
import 'package:flashpay/data/network/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
// 🚀 الاستيراد الجديد للمكتبة
import 'package:pusher_client_fixed/pusher_client_fixed.dart'; 
import '../models/message_model.dart';
import '../data/local/storage_service.dart'; // مسار جلب التوكن

class ChatController extends GetxController {
  final int transferId;
  final int currentUserId;

  ChatController({required this.transferId, required this.currentUserId});

  var isLoading = true.obs;
  var isSending = false.obs;
  var messages = <MessageModel>[].obs;
  var selectedImageFile = Rx<File?>(null);

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  late final dio.Dio _dio;

  // 🚀 تعريف متغيرات المكتبة الجديدة
  late PusherClient pusher;
  late Channel channel;

  @override
  void onInit() {
    super.onInit();
    _dio = ApiClient().dio;
    fetchMessages();
    initPusher();
  }

  @override
  void onClose() {
    // إغلاق الاتصال عند الخروج
    try{
    pusher.unsubscribe('private-transfer.$transferId');
    pusher.disconnect();
    }catch(e){
      debugPrint("Pusher Unsubscribe Warning: $e");
    }
    // تنظيف باقي المتغيرات لمنع تسريب الذاكرة (Memory Leaks)
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      selectedImageFile.value = File(image.path); // حفظ الصورة لعرضها
    }
  }
  // ✅ 3. دالة لحذف الصورة إذا تراجع المستخدم
  void removeImage() {
    selectedImageFile.value = null;
  }


  Future<void> pickAndSendImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image == null) return; // تم الإلغاء من قبل المستخدم

    isSending(true);

    try {
      String fileName = image.path.split('/').last;
      
      // تجهيز البيانات كـ FormData لدعم رفع الملفات
      dio.FormData formData = dio.FormData.fromMap({
        "image": await dio.MultipartFile.fromFile(image.path, filename: fileName),
        "message": "",
        // يمكنك هنا إرسال نص مع الصورة إذا أردت، أو تركها صورة فقط
      });

      final response = await _dio.post(
        '/transfers/$transferId/messages',
        data: formData,
      );

      if (response.statusCode == 201) {
        final data = response.data['data'] as List;
        for (var m in data) {
          messages.add(MessageModel.fromJson(m));
        }
        _scrollToBottom();
      }
    } on dio.DioException catch (e) {
      Get.snackbar('خطأ', 'فشل رفع الصورة. تأكد من حجم الملف والاتصال.');
      print("تفاصيل خطأ السيرفر: ${e.response?.data}");
    } finally {
      isSending(false);
    }
  }

  // =====================================
  // 🚀 إعداد البث اللحظي بالمكتبة الجديدة
  // =====================================
  Future<void> initPusher() async {
    try {
      // 1. جلب التوكن الخاص بالمستخدم لتصريح الدخول للقناة الخاصة
      String? token = Get.find<StorageService>().getToken();
    final hostIp = Uri.parse(ApiConstants.baseUrl).host;
      // 2. إعداد خيارات الاتصال بسيرفر Reverb المحلي
      PusherOptions options = PusherOptions(
        host: hostIp, // IP جهازك
        wsPort: 8080,
        encrypted: false, // بدون SSL لأننا محلي
        cluster: 'mt1',
        // مصادقة الدخول (لكي لا يرفض لارافيل الاتصال)
        auth: PusherAuth(
          '${ApiConstants.baseUrl}/broadcasting/auth',
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      // 3. تهيئة الاتصال
      pusher = PusherClient(
        "u2hdemwhetdsiavg3a9d", // من ملف .env في لارافيل
        options,
        autoConnect: true,
      );

      // طباعة حالة الاتصال في الكونسول للتأكد
      pusher.onConnectionStateChange((state) {
        print("Pusher State: ${state?.currentState}");
      });

      try {
      pusher.unsubscribe('private-transfer.$transferId');
    } catch (_) {
      // تجاهل بصمت إذا لم يكن هناك اشتراك
    }
      try {
        
      // 4. الاشتراك في القناة الخاصة بالحوالة
      channel = pusher.subscribe('private-transfer.$transferId');

      // 5. الاستماع للرسائل القادمة
      channel.bind('App\\Events\\MessageSent', (event) {
        if (event?.data != null) {
          final data = json.decode(event!.data!);
          final newMsg = MessageModel.fromJson(data['message']);

          // إضافة الرسالة إذا لم تكن أنت مرسلها
          if (newMsg.senderId != currentUserId) {
            messages.add(newMsg);
            _scrollToBottom();
          }
        }
      });
    }catch (e){
      debugPrint("Pusher Subscribe Warning: $e");
    }} catch (e) {
      print("Pusher Init Error: $e");
    }
  }

  // 1. جلب الرسائل السابقة
  Future<void> fetchMessages() async {
    try {
      isLoading(true);
      
      // الطلب الآن أبسط بكثير بفضل الـ ApiClient
      final response = await _dio.get('/transfers/$transferId/messages');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        messages.value = data.map((m) => MessageModel.fromJson(m)).toList();
        _scrollToBottom();
      }
    } on dio.DioException catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل المحادثة');
    } finally {
      isLoading(false);
    }
  }

 // ✅ 4. تعديل دالة الإرسال لترسل النص والصورة معاً
  Future<void> sendMessage() async {
    final text = messageController.text.trim();

    // منع الإرسال إذا كان النص فارغاً ولا توجد صورة
    if (text.isEmpty && selectedImageFile.value == null) return;

    isSending(true);

    try {
      // تجهيز البيانات (FormData)
      dio.FormData formData = dio.FormData.fromMap({
        "message": text, // النص (حتى لو كان فارغاً سيقبله السيرفر بسبب تعديلنا السابق)
      });

      // إضافة الصورة إذا تم اختيارها
      if (selectedImageFile.value != null) {
        String fileName = selectedImageFile.value!.path.split('/').last;
        formData.files.add(MapEntry(
          "image",
          await dio.MultipartFile.fromFile(selectedImageFile.value!.path, filename: fileName),
        ));
      }

      final response = await _dio.post(
        '/transfers/$transferId/messages',
        data: formData, // إرسال الـ FormData
      );

      if (response.statusCode == 201) {
        final data = response.data['data'] as List;
        for (var m in data) {
          messages.add(MessageModel.fromJson(m));
        }
        messageController.clear();
        selectedImageFile.value = null; // ✅ تفريغ الصورة بعد الإرسال بنجاح
        _scrollToBottom();
      }
    } on dio.DioException catch (e) {
      Get.snackbar('خطأ', 'لم يتم إرسال الرسالة');
    } finally {
      isSending(false);
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}