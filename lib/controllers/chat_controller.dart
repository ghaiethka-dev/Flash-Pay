import 'dart:convert';
import 'dart:io';
import 'package:flashpay/data/network/api_client.dart';
import 'package:flashpay/data/network/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'package:pusher_client_fixed/pusher_client_fixed.dart';
import '../models/message_model.dart';
import '../data/local/storage_service.dart';

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

  late PusherClient pusher;
  late Channel channel;
  bool _pusherInitialized = false;
  bool _channelSubscribed = false; // ✅ منع الاشتراك المزدوج

  @override
  void onInit() {
    super.onInit();
    _dio = ApiClient().dio;
    fetchMessages();
    initPusher();
  }

  @override
  void onClose() {
    if (_pusherInitialized && _channelSubscribed) {
      try {
        channel.unbind('App\\Events\\MessageSent');
        pusher.unsubscribe('private-transfer.$transferId');
      } catch (e) {
        debugPrint("Pusher Unsubscribe Warning: $e");
      }
      try {
        pusher.disconnect();
      } catch (e) {
        debugPrint("Pusher Disconnect Warning: $e");
      }
    }
    _channelSubscribed = false;
    _pusherInitialized = false;
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source);
    if (image != null) {
      selectedImageFile.value = File(image.path);
    }
  }

  void removeImage() {
    selectedImageFile.value = null;
  }

  // =====================================================
  // ✅ إعداد Pusher مع إصلاح استقبال الرسائل اللحظي
  // =====================================================
  Future<void> initPusher() async {
    // ✅ إذا كان Pusher شغالاً والقناة مشتركة → لا تعيد التهيئة
    if (_pusherInitialized && _channelSubscribed) {
      debugPrint("Pusher: already initialized and subscribed, skipping.");
      return;
    }

    try {
      String? token = Get.find<StorageService>().getToken();
      final hostIp = Uri.parse(ApiConstants.baseUrl).host;

      PusherOptions options = PusherOptions(
        host: hostIp,
        wsPort: 8080,
        encrypted: false,
        cluster: 'mt1',
        auth: PusherAuth(
          '${ApiConstants.baseUrl}/broadcasting/auth',
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'application/json',
          },
        ),
      );

      // ✅ إذا كان Pusher موجوداً بالفعل لا تُنشئ نسخة جديدة
      if (!_pusherInitialized) {
        pusher = PusherClient(
          "u2hdemwhetdsiavg3a9d",
          options,
          autoConnect: true,
        );
        _pusherInitialized = true;

        pusher.onConnectionStateChange((state) {
          debugPrint("Pusher State: ${state?.currentState}");
        });

        pusher.onConnectionError((error) {
          debugPrint("Pusher Connection Error: ${error?.message}");
        });
      }

      // ✅ لا تشترك إذا كانت القناة مشتركة مسبقاً
      if (!_channelSubscribed) {
        channel = pusher.subscribe('private-transfer.$transferId');
        _channelSubscribed = true;

        channel.bind('App\\Events\\MessageSent', (event) {
          if (event?.data == null) return;

          try {
            final dynamic raw = event!.data is String
                ? json.decode(event.data!)
                : event.data;

            final dynamic msgData = raw['message'] ?? raw;

            final newMsg = MessageModel.fromJson(
              msgData is String ? json.decode(msgData) : msgData,
            );

            final bool alreadyExists = messages.any((m) => m.id == newMsg.id);
            if (alreadyExists) return;

            if (newMsg.senderId != currentUserId) {
              messages.add(newMsg);
              _scrollToBottom();
            }
          } catch (e) {
            debugPrint("Pusher Event Parse Error: $e");
            debugPrint("Raw event data: ${event?.data}");
          }
        });
      }
    } catch (e) {
      debugPrint("Pusher Init Error: $e");
    }
  }

  // ✅ جلب الرسائل السابقة
  Future<void> fetchMessages() async {
    try {
      isLoading(true);
      final response = await _dio.get('/transfers/$transferId/messages');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        messages.value = data.map((m) => MessageModel.fromJson(m)).toList();
        _scrollToBottom();
      }
    } on dio.DioException catch (e) {
      Get.snackbar('خطأ', 'فشل تحميل المحادثة');
      debugPrint("fetchMessages error: ${e.response?.data}");
    } finally {
      isLoading(false);
    }
  }

  // ✅ إرسال رسالة (نص + صورة اختياري)
  Future<void> sendMessage() async {
    final text = messageController.text.trim();
    if (text.isEmpty && selectedImageFile.value == null) return;

    isSending(true);

    try {
      dio.FormData formData = dio.FormData.fromMap({
        "message": text,
      });

      if (selectedImageFile.value != null) {
        String fileName = selectedImageFile.value!.path.split('/').last;
        formData.files.add(MapEntry(
          "image",
          await dio.MultipartFile.fromFile(
            selectedImageFile.value!.path,
            filename: fileName,
          ),
        ));
      }

      final response = await _dio.post(
        '/transfers/$transferId/messages',
        data: formData,
      );

      if (response.statusCode == 201) {
        final data = response.data['data'] as List;
        for (var m in data) {
          final newMsg = MessageModel.fromJson(m);
          // ✅ تجنب التكرار — Pusher قد يُعيد نفس الرسالة
          final bool alreadyExists = messages.any((msg) => msg.id == newMsg.id);
          if (!alreadyExists) {
            messages.add(newMsg);
          }
        }
        messageController.clear();
        selectedImageFile.value = null;
        _scrollToBottom();
      }
    } on dio.DioException catch (e) {
      Get.snackbar('خطأ', 'لم يتم إرسال الرسالة');
      debugPrint("sendMessage error: ${e.response?.data}");
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