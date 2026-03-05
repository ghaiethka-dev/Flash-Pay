import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class StorageService extends GetxService {
  final _box = GetStorage();

  // تهيئة الذاكرة (يتم استدعاؤها في main.dart)
  Future<StorageService> init() async {
    await GetStorage.init();
    return this;
  }

  // حفظ التوكن
  Future<void> saveToken(String token) async {
    await _box.write('auth_token', token);
  }

  // جلب التوكن
  String? getToken() {
    return _box.read('auth_token');
  }

  // حفظ دور المستخدم (user أو agent)
  Future<void> saveUserRole(String role) async {
    await _box.write('user_role', role);
  }

  String? getUserRole() {
    return _box.read('user_role');
  }

  // حذف البيانات عند تسجيل الخروج
  Future<void> clearAuthData() async {
    await _box.remove('auth_token');
    await _box.remove('user_role');
  }

  Future<void> saveUserName(String name) async {
    await _box.write('user_name', name);
  }

  String? getUserName() {
    return _box.read('user_name');
  }
}