// =============================================================================
//  team_screen.dart
//  Flash Pay — شاشة فريق العمل
//  Target path:  lib/views/settings/team_screen.dart
//
//  - لا تحتاج أي حزمة جديدة (flutter / get / flutter_animate فقط).
//  - لتعديل الأسماء أو المسميات: عدّل القائمة _team في الأسفل فقط.
//  - نص حقوق النشر في _CopyrightCard — عدّله بما يناسب مالك التطبيق.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../dashboards/user_dashboards/widgets/fp_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  بيانات الفريق  (عدّل هنا فقط)
// ─────────────────────────────────────────────────────────────────────────────
class _Member {
  final String name;
  final String title; // المسمى بالعربية
  final String titleEn; // المسمى بالإنجليزية
  final Color color;

  const _Member({
    required this.name,
    required this.title,
    required this.titleEn,
    required this.color,
  });
}

const List<_Member> _team = [
  _Member(
    name: 'قيس العفيف',
    title: 'مهندس برمجيات',
    titleEn: 'Software Engineer',
    color: FPColors.primary,
  ),
  _Member(
    name: 'أمير دوارة',
    title: 'مهندس برمجيات',
    titleEn: 'Software Engineer',
    color: FPColors.purple,
  ),
  _Member(
    name: 'غيث كحل',
    title: 'مهندس برمجيات',
    titleEn: 'Software Engineer',
    color: FPColors.blue,
  ),
  _Member(
    name: 'دلع عدوان',
    title: 'مهندسة برمجيات',
    titleEn: 'Software Engineer',
    color: Color(0xFF0F9D8A),
  ),
  _Member(
    name: 'حلا هلال',
    title: 'مهندسة برمجيات',
    titleEn: 'Software Engineer',
    color: Color(0xFFE0663A),
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
//  الشاشة
// ─────────────────────────────────────────────────────────────────────────────
class TeamScreen extends StatelessWidget {
  const TeamScreen({Key? key}) : super(key: key);

  /// يُلغي الحركة تلقائياً لمن فعّل "تقليل الحركة" في جهازه.
  Widget _reveal(Widget child, int index, bool reduceMotion) {
    if (reduceMotion) return child;
    return child
        .animate()
        .fadeIn(delay: (120 + index * 90).ms, duration: 450.ms)
        .slideY(begin: 0.10, curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark;
    final bool reduce = MediaQuery.of(context).disableAnimations;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: context.theme.scaffoldBackgroundColor,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _reveal(const _TeamHeader(), -1, reduce)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _reveal(const _SectionLabel('فريق التطوير'), 0, reduce),
                    const SizedBox(height: 10),
                    for (int i = 0; i < _team.length; i++) ...[
                      _reveal(_MemberCard(member: _team[i]), 1 + i, reduce),
                      const SizedBox(height: 10),
                    ],
                    const SizedBox(height: 14),
                    _reveal(const _CopyrightCard(), 1 + _team.length, reduce),
                    const SizedBox(height: 22),
                    _reveal(const _TeamFooter(), 2 + _team.length, reduce),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  الهيدر
// ─────────────────────────────────────────────────────────────────────────────
class _TeamHeader extends StatelessWidget {
  const _TeamHeader();

  @override
  Widget build(BuildContext context) {
    final double statusBarH = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.fromLTRB(20, statusBarH + 12, 20, 30),
      decoration: const BoxDecoration(
        gradient: FPGradients.heroHeader,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -20,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.07),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // زر الرجوع (مساحة لمس 48×48)
              Semantics(
                button: true,
                label: 'رجوع',
                child: InkWell(
                  onTap: () => Get.back(),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.groups_rounded,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'فريق العمل',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'المهندسون الذين صمّموا وبنوا Flash Pay',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  بطاقة حقوق النشر والملكية الفكرية
// ─────────────────────────────────────────────────────────────────────────────
class _CopyrightCard extends StatelessWidget {
  const _CopyrightCard();

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: FPShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: FPColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(Icons.copyright_rounded,
                    color: FPColors.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'حقوق النشر والملكية الفكرية',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : FPColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: context.theme.dividerColor),
          const SizedBox(height: 14),

          const _RightsRow(
            icon: Icons.verified_user_rounded,
            color: FPColors.primary,
            title: 'الملكية',
            text: 'تطبيق Flash Pay بتصميمه وشيفرته البرمجية وشعاره ومحتواه '
                'ملك لأصحابه، وهو محمي بموجب قوانين حقوق المؤلف '
                'والملكية الفكرية المعمول بها.',
          ),
          const SizedBox(height: 14),
          const _RightsRow(
            icon: Icons.block_rounded,
            color: Color(0xFFE10707),
            title: 'الاستخدام',
            text: 'لا يجوز نسخ أي جزء من التطبيق أو تعديله أو إعادة نشره '
                'أو بيعه أو فك تشفيره، إلا بإذن خطي مسبق من أصحابه.',
          ),
          const SizedBox(height: 14),

          const _RightsRow(
            icon: Icons.support_agent_rounded,
            color: FPColors.purple,
            title: 'للتواصل',
            text: 'لطلب إذن استخدام أو للإبلاغ عن أي استخدام غير مصرّح به، '
                'تواصل معنا عبر الدعم من صفحة الإعدادات.',
          ),

          const SizedBox(height: 14),
          Divider(height: 1, color: context.theme.dividerColor),
          const SizedBox(height: 12),
          Center(
            child: Text(
              '© 2026 Flash Pay. جميع الحقوق محفوظة.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : FPColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RightsRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String text;

  const _RightsRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : FPColors.textDark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                text,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.65,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white70 : FPColors.textMid,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  عنوان قسم
// ─────────────────────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: FPColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : FPColors.textDark,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  الصورة الرمزية (أيقونة شخص)
// ─────────────────────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final Color color;
  final double size;

  const _Avatar({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.72)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(Icons.person_rounded, color: Colors.white, size: size * 0.55),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  بطاقة عضو
// ─────────────────────────────────────────────────────────────────────────────
class _MemberCard extends StatelessWidget {
  final _Member member;
  const _MemberCard({required this.member});

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark;

    return Semantics(
      label: '${member.name}، ${member.title}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: FPShadows.card,
        ),
        child: Row(
          children: [
            _Avatar(color: member.color, size: 46),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : FPColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${member.title} · ${member.titleEn}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : FPColors.textMid,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  التذييل
// ─────────────────────────────────────────────────────────────────────────────
class _TeamFooter extends StatelessWidget {
  const _TeamFooter();

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.10),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.favorite_rounded, color: Colors.red, size: 22),
        ),
        const SizedBox(height: 12),
        Text(
          'بُني بجهد فريق واحد لخدمتكم',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : FPColors.textDark,
          ),
        ),
      ],
    );
  }
}