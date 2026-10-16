// =============================================================================
//  app_transitions.dart — FlashPay
//  Target path: lib/core/app_transitions.dart
//
//  انتقال صفحات موحّد لكل التطبيق عبر GetX:
//  • fade + انزلاق خفيف + تكبير بسيط جدًا (حركة تعبّر عن الاتجاه)
//  • يراعي الاتجاه RTL (الصفحة الجديدة تدخل من اليسار)
//  • الصفحة السابقة تتراجع قليلًا (عمق مكاني) بدل أن تبقى ثابتة
//  • إن فعّل المستخدم "تقليل الحركة" في النظام: fade فقط بدون انزلاق
//  • الخروج أسرع من الدخول (ينتهي الـ reverse مبكرًا عبر Interval)
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

/// ثوابت الحركة — استخدمها في كل مكان بدل أرقام متفرقة
class FPMotion {
  FPMotion._();

  static const Duration micro = Duration(milliseconds: 160); // ضغطات/تبديل
  static const Duration fast = Duration(milliseconds: 240); // ظهور عناصر
  static const Duration medium = Duration(milliseconds: 320); // توسّع/انتقال داخل الصفحة
  static const Duration page = Duration(milliseconds: 380); // انتقال صفحة
  static const Duration stagger = Duration(milliseconds: 70); // فاصل التتابع

  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;

  /// هل فعّل المستخدم "تقليل الحركة" في النظام؟
  static bool reduced(BuildContext context) =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;
}

class FPTransition extends CustomTransition {
  @override
  Widget buildTransition(
      BuildContext context,
      Curve? curve,
      Alignment? alignment,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    final bool reduce = MediaQuery.of(context).disableAnimations;

    // الدخول: easeOutCubic | الخروج: easeInCubic وينتهي أسرع (آخر 70% فقط)
    final Animation<double> enter = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 1.0, curve: FPMotion.enter),
      reverseCurve: const Interval(0.3, 1.0, curve: FPMotion.exit),
    );

    final Animation<double> fade = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      reverseCurve: const Interval(0.4, 1.0, curve: Curves.easeIn),
    );

    if (reduce) {
      return FadeTransition(opacity: fade, child: child);
    }

    // الصفحة الجديدة: تنزلق من اليسار (اتجاه RTL) مع تكبير خفيف
    final Animation<Offset> slideIn = Tween<Offset>(
      begin: const Offset(-0.08, 0),
      end: Offset.zero,
    ).animate(enter);

    final Animation<double> scaleIn = Tween<double>(
      begin: 0.98,
      end: 1.0,
    ).animate(enter);

    // الصفحة القديمة (عند push فوقها): تتراجع قليلًا نحو اليمين
    final Animation<Offset> slideOutBack = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.04, 0),
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: FPMotion.enter,
    ));

    return SlideTransition(
      position: slideOutBack,
      child: FadeTransition(
        opacity: fade,
        child: SlideTransition(
          position: slideIn,
          child: ScaleTransition(scale: scaleIn, child: child),
        ),
      ),
    );
  }
}

// =============================================================================
//  دخول متتابع للعناصر (Stagger) — يحترم "تقليل الحركة" في النظام
//  الاستخدام:  MyWidget().fpEntrance(context, 2)
//  الرقم index يحدد ترتيب الظهور (كل عنصر يتأخر 70ms عن السابق)
// =============================================================================
extension FPEntrance on Widget {
  Widget fpEntrance(BuildContext context, int index) {
    if (MediaQuery.of(context).disableAnimations) return this;
    return animate()
        .fadeIn(
      delay: FPMotion.stagger * index,
      duration: FPMotion.fast,
      curve: FPMotion.enter,
    )
        .slideY(
      begin: 0.10,
      end: 0,
      delay: FPMotion.stagger * index,
      duration: FPMotion.fast,
      curve: FPMotion.enter,
    );
  }
}


// =============================================================================
//  اهتزاز أفقي قصير عند فشل التحقق:  shakeKey.currentState?.shake()
// =============================================================================
class FPShake extends StatefulWidget {
  final Widget child;
  const FPShake({Key? key, required this.child}) : super(key: key);

  @override
  State<FPShake> createState() => FPShakeState();
}

class FPShakeState extends State<FPShake> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  void shake() {
    if (FPMotion.reduced(context)) return;
    _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (_, child) {
        final dx = math.sin(_c.value * math.pi * 4) * (1 - _c.value) * 8;
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
    );
  }
}