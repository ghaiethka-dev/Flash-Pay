// =============================================================================
//  chat_controller.dart — FlashPay
//  ✅ تحديث تلقائي: polling صامت كل 4 ثوانٍ (مع تباطؤ عند فشل الشبكة)
//  ✅ يتوقف في الخلفية ويُستأنف فوراً عند العودة للتطبيق
//  ✅ Pusher يبقى كمسار لحظي إضافي (والتكرار مُمنوع بالـ id)
//  ✅ لا قفز في التمرير: ينزل تلقائياً فقط إن كان المستخدم أسفل المحادثة،
//     وإلا تظهر شارة "رسائل جديدة"
// =============================================================================
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flashpay/data/network/api_client.dart';
import 'package:flashpay/data/network/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'package:pusher_client_fixed/pusher_client_fixed.dart';
import '../models/message_model.dart';
import '../data/local/storage_service.dart';

class ChatController extends GetxController with WidgetsBindingObserver {
  final int transferId;
  final int currentUserId;

  ChatController({required this.transferId, required this.currentUserId});

  // ── الحالة المرصودة ─────────────────────────────────────────────────────
  var isLoading = true.obs;          // تحميل أولي فقط (يُظهر هيكل التحميل)
  var isSending = false.obs;
  var messages = <MessageModel>[].obs;
  var selectedImageFile = Rx<File?>(null);

  final isSyncing = false.obs;       // تحديث صامت جارٍ
  final isOnline = true.obs;         // آخر محاولة تحديث نجحت؟
  final unreadNew = 0.obs;           // رسائل جديدة وصلت والمستخدم بعيد عن الأسفل
  final showJumpToBottom = false.obs;

  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  late final dio.Dio _dio;

  // ── التحديث التلقائي ────────────────────────────────────────────────────
  static const int _pollSeconds = 4;
  Timer? _pollTimer;
  bool _fetching = false;
  bool _inForeground = true;
  bool _closed = false;
  bool _nearBottom = true;
  int _failures = 0;
  // رسائل أُرسلت للتو محلياً وقد لا تكون ظهرت بعد في رد تحديث بدأ قبل الإرسال
  final Set<int> _pendingLocalIds = {};

  // ── Pusher ──────────────────────────────────────────────────────────────
  late PusherClient pusher;
  late Channel channel;
  bool _pusherInitialized = false;
  bool _channelSubscribed = false;

  @override
  void onInit() {
    super.onInit();
    _dio = ApiClient().dio;
    WidgetsBinding.instance.addObserver(this);
    scrollController.addListener(_onScroll);
    fetchMessages();
    initPusher();
    _scheduleNextPoll();
  }

  @override
  void onClose() {
    _closed = true;
    _pollTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    scrollController.removeListener(_onScroll);

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

  // ===========================================================================
  //  دورة حياة التطبيق: أوقف التحديث في الخلفية، واستأنفه فوراً عند العودة
  // ===========================================================================
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _inForeground = false;
      _pollTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      _inForeground = true;
      _failures = 0;
      fetchMessages(silent: true).then((_) => _scheduleNextPoll());
    }
  }

  // ===========================================================================
  //  Polling ذاتي الجدولة (لا تتراكم الطلبات): 4ث، ثم يتباطأ حتى 32ث عند الفشل
  // ===========================================================================
  void _scheduleNextPoll() {
    _pollTimer?.cancel();
    if (_closed || !_inForeground) return;
    final secs = _failures == 0 ? _pollSeconds : _pollSeconds * (1 << _failures.clamp(0, 3).toInt());
    _pollTimer = Timer(Duration(seconds: secs), () async {
      await fetchMessages(silent: true);
      _scheduleNextPoll();
    });
  }

  // ===========================================================================
  //  التمرير
  // ===========================================================================
  void _onScroll() {
    if (!scrollController.hasClients) return;
    final p = scrollController.position;
    final near = (p.maxScrollExtent - p.pixels) < 140;
    _nearBottom = near;
    if (showJumpToBottom.value == near) showJumpToBottom.value = !near;
    if (near && unreadNew.value > 0) unreadNew.value = 0;
  }

  /// ينزل لآخر رسالة. initial=true يعيد المحاولة بعد تحميل الصور لتصحيح الارتفاع
  void scrollToBottom({bool initial = false}) {
    void go(bool animate) {
      if (!scrollController.hasClients) return;
      final max = scrollController.position.maxScrollExtent;
      if (animate) {
        scrollController.animateTo(
          max,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        scrollController.jumpTo(max);
      }
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => go(!initial));
    if (initial) {
      Future.delayed(const Duration(milliseconds: 450), () => go(false));
    }
    unreadNew.value = 0;
  }

  // ===========================================================================
  //  الصور
  // ===========================================================================
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: source,
        imageQuality: 82,  // ضغط خفيف: الحد الأقصى في السيرفر 5MB
        maxWidth: 1800,
      );
      if (image != null) selectedImageFile.value = File(image.path);
    } catch (e) {
      debugPrint("pickImage error: $e");
      Get.snackbar('تعذّر فتح الصور', 'تحقق من صلاحيات الكاميرا والمعرض');
    }
  }

  void removeImage() => selectedImageFile.value = null;

  // ===========================================================================
  //  Pusher (مسار لحظي إضافي — التطبيق يعمل بدونه بفضل الـ polling)
  // ===========================================================================
  Future<void> initPusher() async {
    if (_pusherInitialized && _channelSubscribed) return;

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
            _ingestIncoming(newMsg);
          } catch (e) {
            debugPrint("Pusher Event Parse Error: $e");
          }
        });
      }
    } catch (e) {
      debugPrint("Pusher Init Error: $e");
    }
  }

  /// رسالة واحدة وصلت لحظياً من Pusher
  void _ingestIncoming(MessageModel newMsg) {
    if (messages.any((m) => m.id == newMsg.id)) return;
    if (newMsg.senderId == currentUserId) return;
    messages.add(newMsg);
    HapticFeedback.selectionClick();
    if (_nearBottom) {
      scrollToBottom();
    } else {
      unreadNew.value += 1;
    }
  }

  // ===========================================================================
  //  جلب الرسائل
  //  silent=false → تحميل أولي بهيكل تحميل | silent=true → تحديث خلفي بلا وميض
  // ===========================================================================
  Future<void> fetchMessages({bool silent = false}) async {
    if (_fetching) return;
    _fetching = true;
    if (silent) {
      isSyncing(true);
    } else {
      isLoading(true);
    }

    try {
      final response = await _dio.get('/transfers/$transferId/messages');

      if (response.statusCode == 200) {
        final data = response.data['data'] as List;
        final fresh = data
            .map((m) => MessageModel.fromJson(m as Map<String, dynamic>))
            .toList();
        _failures = 0;
        isOnline(true);
        _applyFresh(fresh, firstLoad: !silent);
      }
    } on dio.DioException catch (e) {
      _failures++;
      isOnline(false);
      if (!silent) Get.snackbar('تعذّر التحميل', 'تحقق من اتصالك بالإنترنت');
      debugPrint("fetchMessages error: ${e.response?.data}");
    } catch (e) {
      _failures++;
      debugPrint("fetchMessages parse error: $e");
    } finally {
      _fetching = false;
      isLoading(false);
      isSyncing(false);
    }
  }

  bool _sameList(List<MessageModel> a, List<MessageModel> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].isRead != b[i].isRead ||
          a[i].imageUrl != b[i].imageUrl) {
        return false;
      }
    }
    return true;
  }

  void _applyFresh(List<MessageModel> fresh, {required bool firstLoad}) {
    final freshIds = fresh.map((m) => m.id).toSet();

    // لا تُسقط رسالة أُرسلت للتو ولم تظهر بعد في هذا الرد
    final merged = [...fresh];
    for (final m in messages) {
      if (_pendingLocalIds.contains(m.id) && !freshIds.contains(m.id)) {
        merged.add(m);
      }
    }
    _pendingLocalIds.removeWhere(freshIds.contains);

    final oldIds = messages.map((m) => m.id).toSet();
    final changed = !_sameList(messages, merged);

    if (firstLoad) {
      if (changed) messages.assignAll(merged);
      scrollToBottom(initial: true);
      return;
    }
    if (!changed) return;

    final added = merged.where((m) => !oldIds.contains(m.id)).toList();
    messages.assignAll(merged);
    if (added.isEmpty) return; // تغيّرت علامات القراءة فقط

    final fromOthers = added.where((m) => m.senderId != currentUserId).length;
    final mine = added.any((m) => m.senderId == currentUserId);

    if (_nearBottom || mine) {
      scrollToBottom();
    } else if (fromOthers > 0) {
      unreadNew.value += fromOthers;
    }
    if (fromOthers > 0) HapticFeedback.selectionClick();
  }

  // ===========================================================================
  //  إرسال رسالة (نص + صورة اختيارية)
  // ===========================================================================
  Future<void> sendMessage() async {
    if (isSending.value) return;
    final text = messageController.text.trim();
    if (text.isEmpty && selectedImageFile.value == null) return;

    isSending(true);

    try {
      final formData = dio.FormData.fromMap({"message": text});

      final file = selectedImageFile.value;
      if (file != null) {
        formData.files.add(MapEntry(
          "image",
          await dio.MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        ));
      }

      final response = await _dio.post(
        '/transfers/$transferId/messages',
        data: formData,
      );

      if (response.statusCode == 201) {
        final data = response.data['data'] as List;
        for (final m in data) {
          final newMsg = MessageModel.fromJson(m as Map<String, dynamic>);
          if (!messages.any((x) => x.id == newMsg.id)) {
            messages.add(newMsg);
            _pendingLocalIds.add(newMsg.id);
          }
        }
        messageController.clear();
        selectedImageFile.value = null;
        isOnline(true);
        scrollToBottom();
      }
    } on dio.DioException catch (e) {
      Get.snackbar('تعذّر الإرسال', 'لم تُرسل الرسالة، حاول مرة أخرى');
      debugPrint("sendMessage error: ${e.response?.data}");
    } finally {
      isSending(false);
    }
  }
}