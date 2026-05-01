// =============================================================================
//  splash_screen.dart
//  Flash Pay — Splash Screen
//  Target path:  lib/views/auth/splash_screen.dart
//  (أو استبدل SplashScreen في main.dart بهذا الملف)
//
//  التصميم:
//   • خلفية داكنة مع شبكة هندسية وتوهج برتقالي
//   • شعار FlashPay يظهر مع أنيميشن نبضة ذهبية
//   • أيقونة برق (⚡) متحركة في المركز
//   • نص "تحويل فوري · آمن · موثوق" يظهر تدريجياً
//   • شريط تقدم (Progress) في الأسفل
// =============================================================================

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/local/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // ── ألوان الهوية ──────────────────────────────────────────────────────────
  static const Color kBg          = Color(0xFF080808);
  static const Color kPrimary     = Color(0xFFA64D04);
  static const Color kGold        = Color(0xFFECB651);
  static const Color kGoldLight   = Color(0xFFF5D27A);
  static const Color kSurface     = Color(0xFF141008);
  static const Color kTextPrimary = Color(0xFFF5EDE4);
  static const Color kTextSub     = Color(0xFF9E8878);

  // ── AnimationControllers ──────────────────────────────────────────────────
  late final AnimationController _boltCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _progressCtrl;
  late final AnimationController _entranceCtrl;
  late final AnimationController _orbitCtrl;

  // ── Animations ────────────────────────────────────────────────────────────
  late final Animation<double> _boltScale;
  late final Animation<double> _boltGlow;
  late final Animation<double> _pulseRing1;
  late final Animation<double> _pulseRing2;
  late final Animation<double> _progress;
  late final Animation<double> _fadeLogoText;
  late final Animation<Offset> _slideLogoText;
  late final Animation<double> _fadeTagline;
  late final Animation<double> _orbit;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _navigate();
  }

  void _setupAnimations() {
    // ── Bolt entrance ──
    _boltCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
    _boltScale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.15).chain(CurveTween(curve: Curves.easeOut)), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 40),
    ]).animate(_boltCtrl);
    _boltGlow = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _boltCtrl, curve: const Interval(0.4, 1.0)));

    // ── Pulse rings ──
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();
    _pulseRing1 = Tween<double>(begin: 0.6, end: 1.4).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut));
    _pulseRing2 = Tween<double>(begin: 0.6, end: 1.4).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: const Interval(0.3, 1.0, curve: Curves.easeOut)));

    // ── Orbit particles ──
    _orbitCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
    _orbit = Tween<double>(begin: 0, end: 2 * math.pi).animate(
        CurvedAnimation(parent: _orbitCtrl, curve: Curves.linear));

    // ── Entrance text ──
    _entranceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _entranceCtrl.forward();
    });
    _fadeLogoText = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));
    _slideLogoText = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
        CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic)));
    _fadeTagline = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.4, 1.0, curve: Curves.easeOut)));

    // ── Progress bar ──
    _progressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800));
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _progressCtrl.forward();
    });
    _progress = CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut);
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 3200));
    if (!mounted) return;

    final storageService = Get.find<StorageService>();
    final token    = storageService.getToken();
    final role     = storageService.getUserRole();
    final isBlocked = storageService.getIsBlocked();

    if (token != null && token.isNotEmpty) {
      if (isBlocked) {
        Get.offAllNamed('/blocked');
      } else if (role == 'agent') {
        Get.offAllNamed('/agent_dashboard');
      } else {
        Get.offAllNamed('/user_dashboard');
      }
    } else {
      Get.offAllNamed('/login');
    }
  }

  @override
  void dispose() {
    _boltCtrl.dispose();
    _pulseCtrl.dispose();
    _progressCtrl.dispose();
    _entranceCtrl.dispose();
    _orbitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          // ── خلفية شبكة هندسية ──────────────────────────────────────────
          CustomPaint(painter: _SplashGridPainter(), size: Size.infinite),

          // ── توهج علوي ──────────────────────────────────────────────────
          Positioned(
            top: -size.height * 0.1,
            left: size.width * 0.1,
            right: size.width * 0.1,
            child: AnimatedBuilder(
              animation: _boltGlow,
              builder: (_, __) => Container(
                height: size.height * 0.4,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      kPrimary.withOpacity(0.18 * _boltGlow.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── المحتوى المركزي ──────────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // ── الأيقونة مع الحلقات النابضة ──
                SizedBox(
                  width: 220, height: 220,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_pulseRing1, _pulseRing2, _boltScale, _orbit]),
                    builder: (_, __) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // حلقة نبضية خارجية
                          Opacity(
                            opacity: (1 - (_pulseRing1.value - 0.6) / 0.8).clamp(0.0, 0.5),
                            child: Container(
                              width: 180 * _pulseRing1.value,
                              height: 180 * _pulseRing1.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: kPrimary, width: 1.5),
                              ),
                            ),
                          ),

                          // حلقة نبضية داخلية
                          Opacity(
                            opacity: (1 - (_pulseRing2.value - 0.6) / 0.8).clamp(0.0, 0.35),
                            child: Container(
                              width: 140 * _pulseRing2.value,
                              height: 140 * _pulseRing2.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: kGold, width: 1),
                              ),
                            ),
                          ),

                          // جسيمات مدارية
                          ..._buildOrbitParticles(_orbit.value),

                          // الدائرة الرئيسية
                          Transform.scale(
                            scale: _boltScale.value,
                            child: Container(
                              width: 110, height: 110,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const RadialGradient(
                                  colors: [Color(0xFF1C1008), Color(0xFF0A0703)],
                                ),
                                border: Border.all(color: kPrimary.withOpacity(0.6), width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: kPrimary.withOpacity(0.5 * _boltGlow.value),
                                    blurRadius: 40, spreadRadius: 6,
                                  ),
                                  BoxShadow(
                                    color: kGold.withOpacity(0.2 * _boltGlow.value),
                                    blurRadius: 20, spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.bolt_rounded,
                                  size: 58,
                                  color: kGoldLight,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),

                // ── اسم التطبيق ──
                SlideTransition(
                  position: _slideLogoText,
                  child: FadeTransition(
                    opacity: _fadeLogoText,
                    child: Column(
                      children: [
                        // اسم التطبيق بخط ذهبي
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [kGold, kGoldLight, kGold],
                            stops: [0.0, 0.5, 1.0],
                          ).createShader(bounds),
                          child: const Text(
                            'FlashPay',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 42,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 1.5,
                              height: 1.0,
                            ),
                          ),
                        ),

                        const SizedBox(height: 6),

                        // الخط الذهبي تحت الاسم
                        Container(
                          width: 48, height: 2.5,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.transparent, kGold, Colors.transparent],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // ── Tagline ──
                FadeTransition(
                  opacity: _fadeTagline,
                  child: const Text(
                    'تحويل فوري  ·  آمن  ·  موثوق',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: kTextSub,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── شريط التقدم في الأسفل ──────────────────────────────────────
          Positioned(
            bottom: 60,
            left: 48,
            right: 48,
            child: Column(
              children: [
                // حاوية شريط التقدم
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 3,
                    color: const Color(0xFF1E1408),
                    child: AnimatedBuilder(
                      animation: _progress,
                      builder: (_, __) => FractionallySizedBox(
                        alignment: Alignment.centerRight,
                        widthFactor: _progress.value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [kPrimary, kGold],
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: kGold.withOpacity(0.5),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // نقطة + نص أسفل الشريط
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6, height: 6,
                      decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'نظام إدارة الحوالات المالية',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11,
                        color: kTextSub,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// جسيمات تدور حول الأيقونة
  List<Widget> _buildOrbitParticles(double angle) {
    const double radius = 75;
    final particles = <Widget>[];

    for (int i = 0; i < 4; i++) {
      final particleAngle = angle + (i * math.pi / 2);
      final dx = radius * math.cos(particleAngle);
      final dy = radius * math.sin(particleAngle);
      final isGold = i % 2 == 0;

      particles.add(
        Transform.translate(
          offset: Offset(dx, dy),
          child: Container(
            width: isGold ? 6 : 4,
            height: isGold ? 6 : 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isGold ? kGold.withOpacity(0.8) : kPrimary.withOpacity(0.6),
              boxShadow: [
                BoxShadow(
                  color: (isGold ? kGold : kPrimary).withOpacity(0.6),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return particles;
  }
}

// ─────────────────────────────────────────────
//  خلفية شبكة هندسية مخصصة للسبلاش
// ─────────────────────────────────────────────
class _SplashGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFA64D04).withOpacity(0.035)
      ..strokeWidth = 0.7;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }

    // توهج مركزي
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFA64D04).withOpacity(0.10),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width * 0.5,
      ));
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width * 0.5, glow);

    // توهج سفلي
    final glowBottom = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFECB651).withOpacity(0.05),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width / 2, size.height),
        radius: size.width * 0.55,
      ));
    canvas.drawCircle(Offset(size.width / 2, size.height), size.width * 0.55, glowBottom);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
