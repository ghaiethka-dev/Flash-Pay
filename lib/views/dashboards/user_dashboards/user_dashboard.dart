import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:flashpay/controllers/user_dashboard_controller.dart';
import 'package:flashpay/views/profile/account_screen.dart';
import 'package:flashpay/views/settings/settings_screen.dart';

import 'widgets/fp_bottom_nav_bar.dart';
import 'widgets/fp_theme.dart';
import 'widgets/home_tab.dart';
import 'widgets/notifications_tab.dart';

class UserDashboardView extends StatefulWidget {
  const UserDashboardView({Key? key}) : super(key: key);

  @override
  State<UserDashboardView> createState() => _UserDashboardViewState();
}

class _UserDashboardViewState extends State<UserDashboardView> {
  late final UserDashboardController controller;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(UserDashboardController());
    _pageController = PageController(
      initialPage: controller.selectedIndex.value,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        // نبقي الأيقونات بيضاء دائماً لأن الهيدر العلوي ملون (Gradient)
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light, 
          statusBarBrightness: Brightness.dark,
        ),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          // 🚀 السطر السحري للخلفية:
          backgroundColor: context.theme.scaffoldBackgroundColor,

          body: PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              controller.changeTabIndex(index);
            },
            children: [
              HomeTab(controller: controller),
              const NotificationsTab(),
              const SettingsScreen(),
              const AccountScreen(),
            ],
          ),

          bottomNavigationBar: Obx(
            () => FPBottomNavBar(
              selectedIndex: controller.selectedIndex.value,
              onTabChange: (index) {
                controller.changeTabIndex(index);
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}