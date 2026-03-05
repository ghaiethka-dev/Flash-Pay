import 'package:flashpay/controllers/user_dashboard_controller.dart';
import 'package:flashpay/views/create_remittance.dart';
import 'package:flashpay/views/profile_view.dart';
import 'package:flashpay/views/settings_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class UserDashboardView extends GetView<UserDashboardController> {
  const UserDashboardView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(UserDashboardController());

    // إضافة Directionality لضبط الاتجاه من اليمين لليسار (عربي)
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: _buildAppBar(),
        body: Obx(() => _buildBody()),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFA64D04),
      elevation: 0,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          SizedBox(width: 8),
          // تم الإبقاء على اسم التطبيق بالإنجليزية كما طلبت
          Text(
            'Flash Pay',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 22,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (controller.selectedIndex.value) {
      case 0:
        return _buildHomeTab();
      case 1:
        return const Center(child: Text('الإشعارات', style: TextStyle(fontSize: 18, color: Color(0xFFA64D04))));
      case 2:
        return const SettingsView();
      case 3:
        return const ProfileView();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            ' مرحباً بك : ',
            style: TextStyle(
              fontSize: 26,
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          // قراءة اسم المستخدم بشكل ديناميكي من الـ Controller
          Obx(() => Text(
            controller.userName.value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFA64D04),
            ),
          )),
          const SizedBox(height: 32),
          _buildRemittanceCard(),
        ],
      ),
    );
  }

  Widget _buildRemittanceCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE67E22), Color(0xFFA64D04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA64D04).withOpacity(0.4),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          highlightColor: Colors.white.withOpacity(0.1),
          splashColor: Colors.white.withOpacity(0.2),
          onTap: () {
            Get.to(() => const CreateRemittanceView(), transition: Transition.rightToLeft);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'إرسال حوالة',
                  style: TextStyle(
                    fontSize: 26,
                    fontFamily: 'Tajawal',
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Obx(
            () => GNav(
              rippleColor: Colors.grey[300]!,
              hoverColor: Colors.grey[100]!,
              gap: 8,
              activeColor: const Color(0xFFA64D04),
              iconSize: 26,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              duration: const Duration(milliseconds: 400),
              tabBackgroundColor: const Color(0xFFA64D04).withOpacity(0.08),
              color: Colors.grey[500],
              tabs: const [
                GButton(
                  icon: Icons.home_rounded,
                  text: 'الرئيسية', // تعريب التبويبات
                ),
                GButton(
                  icon: Icons.notifications_rounded,
                  text: 'الإشعارات',
                ),
                GButton(
                  icon: Icons.settings_rounded,
                  text: 'الإعدادات',
                ),
                GButton(
                  icon: Icons.person_rounded,
                  text: 'الحساب',
                ),
              ],
              selectedIndex: controller.selectedIndex.value,
              onTabChange: controller.changeTabIndex,
            ),
          ),
        ),
      ),
    );
  }
}