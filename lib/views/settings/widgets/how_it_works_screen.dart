// =============================================================================
//  how_it_works_screen.dart
//  Flash Pay — صفحة شرح التطبيق (كيف تعمل الحوالة)
//  Target path:  lib/views/settings/how_it_works_screen.dart
//
//  - نفس ستايل صفحة الإعدادات/الفريق (FPColors + FPGradients + FPShadows).
//  - لتعديل الخطوات أو النصوص: عدّل القوائم _steps و _statuses و _tips فقط.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../dashboards/user_dashboards/widgets/fp_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  المحتوى (عدّل هنا فقط)
// ─────────────────────────────────────────────────────────────────────────────
class _Step {
  final IconData icon;
  final Color color;
  final String title;
  final String text;
  const _Step(this.icon, this.color, this.title, this.text);
}

const List<_Step> _steps = [
  _Step(
    Icons.edit_note_rounded,
    FPColors.primary,
    'أدخل بيانات الحوالة',
    'اكتب المبلغ، واختر عملة الإرسال وعملة الاستلام، ثم أدخل اسم المستلم '
        'ورقم هاتفه، واختر المكتب أو المدينة التي سيستلم منها. '
        'تأكد من صحة الاسم والرقم فهما أساس عملية الاستلام.',
  ),
  _Step(
    Icons.send_rounded,
    FPColors.blue,
    'أرسل الحوالة',
    'بعد الإرسال يُنشئ التطبيق رقم تتبع يبدأ بـ TRX- ويظهر لك مع حالة '
        '"قيد الانتظار". احتفظ بهذا الرقم، فهو مرجعك ومرجع المستلم.',
  ),
  _Step(
    Icons.chat_bubble_rounded,
    FPColors.purple,
    'أكمل الدفع في المحادثة',
    'تنتقل بعد الإرسال إلى المحادثة مع المكتب لإتمام الأمور المالية '
        'وتسليم المبلغ. اتبع تعليمات الموظف في المحادثة حتى تتم العملية.',
  ),
  _Step(
    Icons.verified_rounded,
    Color(0xFF0F9D8A),
    'اعتماد الحوالة',
    'يراجع المكتب الحوالة ويعتمدها، فتتحول حالتها إلى "جاهزة للاستلام" '
        'ويصلك إشعار على التطبيق.',
  ),
  _Step(
    Icons.storefront_rounded,
    Color(0xFFE0663A),
    'الاستلام من المكتب',
    'يذهب المستلم إلى المكتب المحدد ومعه هويته ويذكر رقم الحوالة. '
        'يتحقق الموظف من الهوية ويسلّمه المبلغ، فتصبح الحالة "مكتملة" '
        'ويصلك إشعار بتسليم الحوالة.',
  ),
];

class _Status {
  final String label;
  final String text;
  final Color color;
  const _Status(this.label, this.text, this.color);
}

const List<_Status> _statuses = [
  _Status('قيد الانتظار', 'تم إرسال الحوالة وبانتظار اعتماد المكتب.',
      Color(0xFFE08A00)),
  _Status('جاهزة', 'اعتُمدت الحوالة ويمكن للمستلم استلامها من المكتب.',
      FPColors.blue),
  _Status('مكتملة', 'تم تسليم المبلغ للمستلم بنجاح.', Color(0xFF1E9E5A)),
];

const List<String> _tips = [
  'احتفظ برقم التتبع ولا تشاركه إلا مع المستلم.',
  'يجب أن يحضر المستلم هويته عند الاستلام.',
  'راجع اسم المستلم ورقم هاتفه قبل الإرسال.',
  'عند أي مشكلة، تواصل مع الدعم من صفحة الإعدادات.',
];

// ─────────────────────────────────────────────────────────────────────────────
//  الشاشة
// ─────────────────────────────────────────────────────────────────────────────
class HowItWorksScreen extends StatelessWidget {
  const HowItWorksScreen({Key? key}) : super(key: key);

  /// يُلغي الحركة تلقائياً لمن فعّل "تقليل الحركة" في جهازه.
  Widget _reveal(Widget child, int index, bool reduceMotion) {
    if (reduceMotion) return child;
    return child
        .animate()
        .fadeIn(delay: (100 + index * 80).ms, duration: 450.ms)
        .slideY(begin: 0.10, curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final bool reduce = MediaQuery.of(context).disableAnimations;

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
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                  child: _reveal(const _GuideHeader(), -1, reduce)),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 60),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _reveal(const _SectionLabel('خطوات إرسال حوالة'), 0, reduce),
                    const SizedBox(height: 14),
                    for (int i = 0; i < _steps.length; i++)
                      _reveal(
                        _StepTile(
                          number: i + 1,
                          step: _steps[i],
                          isLast: i == _steps.length - 1,
                        ),
                        1 + i,
                        reduce,
                      ),
                    const SizedBox(height: 22),
                    _reveal(const _SectionLabel('حالات الحوالة'), 6, reduce),
                    const SizedBox(height: 12),
                    _reveal(const _StatusesCard(), 7, reduce),
                    const SizedBox(height: 22),
                    _reveal(const _SectionLabel('نصائح مهمة'), 8, reduce),
                    const SizedBox(height: 12),
                    _reveal(const _TipsCard(), 9, reduce),
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
class _GuideHeader extends StatelessWidget {
  const _GuideHeader();

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
                    child: const Icon(Icons.menu_book_rounded,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'كيف يعمل التطبيق',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'من إرسال الحوالة حتى استلامها، خطوة بخطوة',
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
//  خطوة (Timeline)
// ─────────────────────────────────────────────────────────────────────────────
class _StepTile extends StatelessWidget {
  final int number;
  final _Step step;
  final bool isLast;

  const _StepTile({
    required this.number,
    required this.step,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark;

    return Semantics(
      label: 'الخطوة $number: ${step.title}. ${step.text}',
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // العمود: الدائرة + الخط
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [step.color, step.color.withOpacity(0.72)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Text(
                      '$number',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(
                          color: context.theme.dividerColor,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // البطاقة
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: context.theme.cardColor,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: FPShadows.card,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: step.color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(step.icon, color: step.color, size: 18),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              step.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : FPColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        step.text,
                        style: TextStyle(
                          fontSize: 12.5,
                          height: 1.7,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white70 : FPColors.textMid,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  حالات الحوالة
// ─────────────────────────────────────────────────────────────────────────────
class _StatusesCard extends StatelessWidget {
  const _StatusesCard();

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: FPShadows.card,
      ),
      child: Column(
        children: [
          for (int i = 0; i < _statuses.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: const BoxConstraints(minWidth: 92),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statuses[i].color.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statuses[i].label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: _statuses[i].color,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(
                      _statuses[i].text,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white70 : FPColors.textMid,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (i != _statuses.length - 1) ...[
              const SizedBox(height: 12),
              Divider(height: 1, color: context.theme.dividerColor),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  نصائح
// ─────────────────────────────────────────────────────────────────────────────
class _TipsCard extends StatelessWidget {
  const _TipsCard();

  @override
  Widget build(BuildContext context) {
    final bool isDark = context.theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: FPShadows.card,
      ),
      child: Column(
        children: [
          for (int i = 0; i < _tips.length; i++) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(Icons.check_circle_rounded,
                      color: FPColors.primary, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _tips[i],
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : FPColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
            if (i != _tips.length - 1) const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}