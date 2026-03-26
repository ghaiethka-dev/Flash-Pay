// (احتفظ بنفس الاستيرادات الخاصة بك في الأعلى)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:flashpay/controllers/agent_dashboard_controller.dart';
import 'package:flashpay/core/constants.dart';
import 'package:flashpay/views/profile/account_screen.dart';
import 'package:flashpay/views/settings/settings_screen.dart';

import 'widgets/agent_app_bar.dart';
import 'widgets/agent_bottom_nav.dart';
import 'widgets/approved_transfers_tab.dart';
import 'widgets/incoming_transfers_tab.dart';

class AgentDashboard extends StatefulWidget {
  const AgentDashboard({Key? key}) : super(key: key);

  @override
  State<AgentDashboard> createState() => _AgentDashboardState();
}

class _AgentDashboardState extends State<AgentDashboard> {
  late final AgentDashboardController controller;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(AgentDashboardController());
    _pageController = PageController(initialPage: controller.selectedIndex.value);
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
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light, 
          statusBarBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: context.theme.scaffoldBackgroundColor,
          appBar: const AgentAppBar(),
          
          // 🚀 الحل هنا: إزالة الـ Obx المزعج تماماً!
          // التبويبات بداخلها أصبحت ذكية وتدير تحميلها بنفسها
          body: PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              controller.changeTabIndex(index); 
            },
            children: [
              IncomingTransfersTab(controller: controller),
              ApprovedTransfersTab(controller: controller),
              const SettingsScreen(),
              const AccountScreen(),
            ],
          ),

          // الـ Obx هنا صحيح 100% لأنه يراقب selectedIndex.value
          bottomNavigationBar: Obx(
            () => AgentBottomNav(
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