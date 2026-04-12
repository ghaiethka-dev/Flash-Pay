import 'package:dio/dio.dart';
import '../data/network/api_client.dart';
import '../data/network/api_constants.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Response> loginUser(String email, String password) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.loginEndpoint,
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

  Future<Response> registerUser(dynamic userData) async {
    try {
      final response = await _apiClient.dio.post(
        ApiConstants.registerEndpoint,
        data: userData,
        options: Options(
          contentType: userData is FormData
              ? 'multipart/form-data'
              : 'application/json',
        ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<Response> logoutUser() async {
    try {
      return await _apiClient.dio.post('/logout');
    } catch (e) {
      rethrow;
    }
  }

  // ✅ جلب قائمة الدول (public endpoint - بدون token)
  Future<Response> getCountries() async {
    try {
      return await _apiClient.dio.get('/countries');
    } catch (e) {
      rethrow;
    }
  }

  // ✅ جلب قائمة المدن (public endpoint - بدون token)
  Future<Response> getCities() async {
    try {
      return await _apiClient.dio.get('/cities');
    } catch (e) {
      rethrow;
    }
  }
}