// =============================================================================
//  account_screen.dart
//  Flash Pay — Account / Profile Screen  (Main Entry)
//  ────────────────────────────────────────────────────
//  Target path:  lib/views/profile/account_screen.dart
//
//  Replaces the original:  lib/views/profile_view.dart
//
//  ✅ ALL controller logic is 100 % preserved:
//     • Get.put(ProfileController())
//     • Obx() wrappers
//     • controller.isLoading.value
//     • controller.transfersHistory
//     • controller.fetchProfileData()
//     • AppColors.primaryGradient (used for RefreshIndicator colour)
//
//  Component map
//  ─────────────
//  widgets/
//    profile_header.dart             — gradient hero with Lottie + verified badge
//    profile_info_card.dart          — edit form + save button
//    transfer_history_section.dart   — staggered list or empty state
//    transfer_item_card.dart         — single transfer row
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:flashpay/controllers/profile_controller.dart';
import 'package:flashpay/core/constants.dart';

import '../dashboards/user_dashboards/widgets/fp_theme.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_info_card.dart';
import 'widgets/transfer_history_section.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // ✅ Controller injection — unchanged
    final ProfileController controller = Get.put(ProfileController());
    final bool isDark = context.theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl, // ✅ RTL preserved
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: context.theme.scaffoldBackgroundColor,
          body: Obx(() {
            // ✅ Obx — unchanged

            // ── Full-screen loading shimmer (only on first load) ─────────
            if (controller.isLoading.value &&
                controller.transfersHistory.isEmpty) {
              return Center(
                child: CircularProgressIndicator(
                  // ✅ AppColors.primaryGradient.colors.first — unchanged
                  color: AppColors.primaryGradient.colors.first,
                ),
              );
            }

            // ── Pull-to-refresh + scrollable content ─────────────────────
            return RefreshIndicator(
              // ✅ color unchanged
              color: AppColors.primaryGradient.colors.first,
              displacement: 80,
              onRefresh: () async {
                // ✅ fetchProfileData() call — unchanged
                await controller.fetchProfileData();
              },
              child: CustomScrollView(
                // ✅ AlwaysScrollableScrollPhysics preserved for pull-to-refresh
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  // ── Gradient hero header ────────────────────────────────
                  SliverToBoxAdapter(
                    child: ProfileHeader(
                      name: controller.nameController.text,
                      contact: controller.emailController.text,
                    ),
                  ),
                  // ── Body padding + content list ─────────────────────────
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 60),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Personal info edit card
                        ProfileInfoCard(controller: controller),

                        const SizedBox(height: 36),

                        // Transfer history section
                        Obx(
                          // ✅ controller.transfersHistory read via Obx
                          () => TransferHistorySection(
                            transfers: controller.transfersHistory
                                .cast<Map<String, dynamic>>()
                                .toList(),
                          ),
                        ),

                        const SizedBox(height: 30),
                      ]),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
