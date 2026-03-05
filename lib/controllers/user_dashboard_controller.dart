import 'package:flashpay/controllers/profile_controller.dart';
import 'package:get/get.dart';
import '../data/local/storage_service.dart'; // تأكد من مسار الاستدعاء لديك

class UserDashboardController extends GetxController {
  final StorageService _storageService = Get.find<StorageService>();

  // مؤشر شريط التنقل السفلي
  final RxInt selectedIndex = 0.obs;
  
  // متغير لحفظ اسم المستخدم
  final RxString userName = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // جلب الاسم المحفوظ في الذاكرة المحلية، وإذا كان فارغاً نضع "ضيف" مؤقتاً
    userName.value = _storageService.getUserName() ?? 'ضيف';
  }

  void changeTabIndex(int index) {
    selectedIndex.value = index;
    if (index == 3) {
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().fetchProfileData();
      }
    }
  }
}