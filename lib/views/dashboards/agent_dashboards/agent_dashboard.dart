import 'package:flashpay/views/dashboards/agent_dashboards/widgets/safe_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:flashpay/controllers/agent_dashboard_controller.dart';
import 'package:flashpay/core/constants.dart';
import 'package:flashpay/views/profile/account_screen.dart';
import 'package:flashpay/views/settings/settings_screen.dart';

import 'widgets/agent_app_bar.dart';
import 'widgets/agent_bottom_nav.dart';
import 'widgets/agent_send_remittance_tab.dart'; // ← تاب إرسال الحوالة الجديد
import 'widgets/bank_transfer_tab.dart';

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
          appBar: AgentAppBar(
            onSafeTap: () {
              // استدعاء جلب البيانات ثم إظهار الـ BottomSheet
              controller.fetchAgentSafe();
              AgentSafeSheet.show(controller);
            },
          ),
          body: PageView(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              controller.changeTabIndex(index);
            },
            children: const [
              // تاب 0: إرسال حوالة (الوكيل يرسل كالزبون → super_safe)
              AgentSendRemittanceTab(),

              // تاب 1: التحويل البنكي
              BankTransferTab(),

              // تاب 2: الإعدادات
              SettingsScreen(),

              // تاب 3: الحساب
              AccountScreen(),
            ],
          ),
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