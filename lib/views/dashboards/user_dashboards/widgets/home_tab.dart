// =============================================================================
//  home_tab.dart
//  Flash Pay — Home Tab (main scrollable body)
//  ─────────────────────────────────────────────
//  Extracted to its own StatefulWidget so flutter_animate re-runs entry
//  animations cleanly every time the user switches back to the Home tab.
//
//  Contains:
//    • DashboardHeader  (gradient hero + glass stats + greeting)
//    • Two RemittanceCards  (domestic + international)
//    • FeaturePillsRow  (trust badges)
//
//  ✅ UI-only.  All routing callbacks are injected so this widget carries
//     zero GetX or business-logic dependency.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import 'package:flashpay/controllers/user_dashboard_controller.dart';
import 'package:flashpay/views/create_intl_remittance.dart';
import 'package:flashpay/views/create_remittance.dart';

import 'dashboard_header.dart';
import 'feature_pills_row.dart';
import 'remittance_card.dart';
import 'section_title.dart';

class HomeTab extends StatefulWidget {
  final UserDashboardController controller;

  const HomeTab({Key? key, required this.controller}) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Gradient hero header ─────────────────────────────────────────
        SliverToBoxAdapter(
          child: Obx(
            // ✅ Obx reads controller.userName — logic untouched
            () => DashboardHeader(userName: widget.controller.userName.value),
          ),
        ),

        // ── Scrollable body content ──────────────────────────────────────
        SliverPadding(
          // bottom: 100 leaves clearance above the floating bottom nav bar
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 100),
          sliver: SliverList(
            delegate: SliverChildListDelegate([

              // ── Section: Quick Services ─────────────────────────────────
              const SectionTitle(label: 'الخدمات السريعة')
                  .animate()
                  .fadeIn(delay: 350.ms, duration: 450.ms)
                  .slideX(begin: -0.06, curve: Curves.easeOut),

              const SizedBox(height: 16),

              // ── Domestic remittance ─────────────────────────────────────
              RemittanceCard(
                data: kDomesticCard,
                // ✅ Routing & transition unchanged from original
                onTap: () => Get.to(
                  () => const CreateRemittanceView(),
                  transition: Transition.fadeIn,
                  duration: const Duration(milliseconds: 280),
                ),
              )
                  .animate()
                  .fadeIn(delay: 450.ms, duration: 500.ms)
                  .slideY(begin: 0.14, curve: Curves.easeOut),

              const SizedBox(height: 16),

              // ── International remittance ────────────────────────────────
              RemittanceCard(
                data: kInternationalCard,
                // ✅ Routing & transition unchanged from original
                onTap: () => Get.to(
                  () => const CreateIntlRemittanceView(),
                  transition: Transition.fadeIn,
                  duration: const Duration(milliseconds: 280),
                ),
              )
                  .animate()
                  .fadeIn(delay: 580.ms, duration: 500.ms)
                  .slideY(begin: 0.14, curve: Curves.easeOut),

              const SizedBox(height: 36),

              // ── Section: Why Flash Pay ──────────────────────────────────
              const SectionTitle(label: 'لماذا Flash Pay؟')
                  .animate()
                  .fadeIn(delay: 680.ms, duration: 450.ms)
                  .slideX(begin: -0.06, curve: Curves.easeOut),

              const SizedBox(height: 16),

              const FeaturePillsRow()
                  .animate()
                  .fadeIn(delay: 760.ms, duration: 500.ms)
                  .slideY(begin: 0.10, curve: Curves.easeOut),
            ]),
          ),
        ),
      ],
    );
  }
}
