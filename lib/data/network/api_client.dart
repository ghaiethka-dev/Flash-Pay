import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../local/storage_service.dart';
import 'api_constants.dart';

class ApiClient {
  late Dio dio;
  final StorageService _storageService = Get.find<StorageService>();

  ApiClient() {
    BaseOptions options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    dio = Dio(options);

    // إضافة Interceptor لحقن التوكن تلقائياً في الطلبات
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        String? token = _storageService.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        // يمكنك هنا معالجة أخطاء الـ 401 (انتهاء صلاحية التوكن) وتوجيه المستخدم لتسجيل الدخول
        if (e.response?.statusCode == 401) {
          _storageService.clearAuthData();
          Get.offAllNamed('/login');
        }
        return handler.next(e);
      },
    ));
  }
}