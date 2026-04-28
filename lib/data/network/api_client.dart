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
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    dio = Dio(options);
    dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));
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
        // مرر الخطأ للـ controller ليتعامل معه (تجنب التعارض مع block check)
        return handler.next(e);
      },
    ));
  }
}