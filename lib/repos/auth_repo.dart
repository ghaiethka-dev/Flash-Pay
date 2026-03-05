import 'package:dio/dio.dart';
import '../data/network/api_client.dart';
import '../data/network/api_constants.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Response> loginUser(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.loginEndpoint, // تأكد أنها "/login" في api_constants.dart
        data: {
          'email': email,
          'password': password,
        },
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> registerUser(Map<String, dynamic> userData) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.registerEndpoint, // تأكد أنها "/register"
        data: userData,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
  // دالة تسجيل الخروج
  Future<Response> logoutUser() async {
    try {
      return await _apiClient.dio.post('/logout');
    } catch (e) {
      rethrow;
    }
  }
}