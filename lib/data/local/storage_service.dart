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
    await _box.remove('user_name');
    await _box.remove('is_blocked'); // \u2705 مسح حالة الحظر عند تسجيل الخروج
  }

  Future<void> saveUserName(String name) async {
    await _box.write('user_name', name);
  }

  String? getUserName() {
    return _box.read('user_name');
  }
  Future<void> saveUserId(int id) async {
  await _box.write('user_id', id); // حفظ الـ ID
}

int? getUserId() {
  return _box.read('user_id'); // استرجاع الـ ID
}

  // حفظ حالة الحظر
  Future<void> saveIsBlocked(bool isBlocked) async {
    await _box.write('is_blocked', isBlocked);
  }

  // قراءة حالة الحظر (افتراضي: false = غير محظور)
  bool getIsBlocked() {
    return _box.read('is_blocked') ?? false;
  }

  void saveThemeMode(bool isDarkMode) {
    
     _box.write('isDarkMode', isDarkMode);
  }

  bool isDarkMode() {
     return _box.read('isDarkMode') ?? false;
  
  }


}