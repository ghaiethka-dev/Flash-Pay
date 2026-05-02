// =============================================================================
//  splash_screen.dart  —  Flash Pay
//  lib/views/auth/splash_screen.dart
// =============================================================================

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/BiometricController.dart';
import '../../data/local/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  // ── ألوان الهوية ──────────────────────────────────────────────────────────
  static const Color kBg        = Color(0xFF080808);   // خلفية سوداء
  static const Color kGold      = Color(0xFFECB651);   // ذهبي أساسي
  static const Color kGoldLight = Color(0xFFF5D27A);   // ذهبي فاتح
  static const Color kGoldDeep  = Color(0xFFD4982A);   // ذهبي عميق
  static const Color kTextSub   = Color(0xFF9E8878);   // نص ثانوي

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
    _boltCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
    _boltScale = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.15)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 60),
      TweenSequenceItem(
          tween: Tween(begin: 1.15, end: 1.0)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 40),
    ]).animate(_boltCtrl);
    _boltGlow = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _boltCtrl, curve: const Interval(0.4, 1.0)));

    // ── Pulse rings ──
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat();
    _pulseRing1 = Tween<double>(begin: 0.6, end: 1.4).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeOut));
    _pulseRing2 = Tween<double>(begin: 0.6, end: 1.4).animate(
        CurvedAnimation(
            parent: _pulseCtrl,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOut)));

    // ── Orbit particles ──
    _orbitCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
    _orbit = Tween<double>(begin: 0, end: 2 * math.pi).animate(
        CurvedAnimation(parent: _orbitCtrl, curve: Curves.linear));

    // ── Entrance text ──
    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1400));
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _entranceCtrl.forward();
    });
    _fadeLogoText = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _entranceCtrl,
            curve: const Interval(0.0, 0.5, curve: Curves.easeOut)));
    _slideLogoText =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _entranceCtrl,
                curve: const Interval(0.0, 0.5, curve: Curves.easeOutCubic)));
    _fadeTagline = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: _entranceCtrl,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOut)));

    // ── Progress bar ──
    _progressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2800));
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) _progressCtrl.forward();
    });
    _progress =
        CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut);
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(milliseconds: 3200));
    if (!mounted) return;

    final storageService = Get.find<StorageService>();
    final token     = storageService.getToken();
    final role      = storageService.getUserRole();
    final isBlocked = storageService.getIsBlocked();

    if (token == null || token.isEmpty) {
      Get.offAllNamed('/login');
      return;
    }

    final biometricController = Get.find<BiometricController>();
    final bool passed = await biometricController.authenticateOnLaunch();

    if (!mounted) return;

    if (!passed) {
      Get.offAllNamed('/login');
      return;
    }

    if (isBlocked) {
      Get.offAllNamed('/blocked');
    } else if (role == 'agent') {
      Get.offAllNamed('/agent_dashboard');
    } else {
      Get.offAllNamed('/user_dashboard');
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

          // ── خلفية شبكة هندسية ذهبية خفيفة ───────────────────────────────
          CustomPaint(painter: _SplashGridPainter(), size: Size.infinite),

          // ── توهج علوي ذهبي ────────────────────────────────────────────────
          Positioned(
            top: -size.height * 0.15,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _boltGlow,
              builder: (_, __) => Container(
                height: size.height * 0.55,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      kGold.withOpacity(0.14 * _boltGlow.value),
                      kGoldDeep.withOpacity(0.05 * _boltGlow.value),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
          ),

          // ── توهج سفلي ذهبي ────────────────────────────────────────────────
          Positioned(
            bottom: -size.height * 0.1,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _boltGlow,
              builder: (_, __) => Container(
                height: size.height * 0.35,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      kGoldDeep.withOpacity(0.07 * _boltGlow.value),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── المحتوى المركزي ──────────────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                // ── الأيقونة مع الحلقات النابضة ──────────────────────────
                SizedBox(
                  width: 240,
                  height: 240,
                  child: AnimatedBuilder(
                    animation: Listenable.merge(
                        [_pulseRing1, _pulseRing2, _boltScale, _orbit]),
                    builder: (_, __) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [

                          // حلقة نبضية خارجية — ذهبية
                          Opacity(
                            opacity: (1 - (_pulseRing1.value - 0.6) / 0.8)
                                .clamp(0.0, 0.45),
                            child: Container(
                              width: 200 * _pulseRing1.value,
                              height: 200 * _pulseRing1.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: kGold, width: 1.5),
                              ),
                            ),
                          ),

                          // حلقة نبضية داخلية — ذهبية فاتحة
                          Opacity(
                            opacity: (1 - (_pulseRing2.value - 0.6) / 0.8)
                                .clamp(0.0, 0.30),
                            child: Container(
                              width: 155 * _pulseRing2.value,
                              height: 155 * _pulseRing2.value,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: kGoldLight, width: 1),
                              ),
                            ),
                          ),

                          // جسيمات مدارية ذهبية
                          ..._buildOrbitParticles(_orbit.value),

                          // ── الدائرة الذهبية الرئيسية ──
                          Transform.scale(
                            scale: _boltScale.value,
                            child: AnimatedBuilder(
                              animation: _boltGlow,
                              builder: (_, __) => Container(
                                width: 112,
                                height: 112,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  // Gradient ذهبي مشع من المركز
                                  gradient: RadialGradient(
                                    colors: [
                                      kGoldLight,
                                      kGold,
                                      kGoldDeep,
                                    ],
                                    stops: const [0.0, 0.55, 1.0],
                                    center: const Alignment(-0.2, -0.3),
                                  ),
                                  boxShadow: [
                                    // هالة ذهبية متوهجة
                                    BoxShadow(
                                      color: kGold.withOpacity(
                                          0.55 * _boltGlow.value),
                                      blurRadius: 36,
                                      spreadRadius: 4,
                                    ),
                                    BoxShadow(
                                      color: kGoldDeep.withOpacity(
                                          0.28 * _boltGlow.value),
                                      blurRadius: 65,
                                      spreadRadius: 12,
                                    ),
                                  ],
                                ),
                                // ── أيقونة البرق سوداء داكنة داخل الذهبي ──
                                child: const Icon(
                                  Icons.bolt_rounded,
                                  color: Color(0xFF080808),
                                  size: 60,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 36),

                // ── اسم التطبيق بـ Gradient ذهبي ─────────────────────────
                SlideTransition(
                  position: _slideLogoText,
                  child: FadeTransition(
                    opacity: _fadeLogoText,
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              kGoldDeep,
                              kGoldLight,
                              kGold,
                              kGoldLight,
                              kGoldDeep,
                            ],
                            stops: [0.0, 0.25, 0.5, 0.75, 1.0],
                          ).createShader(bounds),
                          child: const Text(
                            'FlashPay',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 2.0,
                              height: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // خط ذهبي أسفل الاسم
                        Container(
                          width: 90,
                          height: 2,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Colors.transparent,
                                kGoldDeep,
                                kGoldLight,
                                kGoldDeep,
                                Colors.transparent,
                              ],
                              stops: [0.0, 0.2, 0.5, 0.8, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── Tagline ───────────────────────────────────────────────
                FadeTransition(
                  opacity: _fadeTagline,
                  child: const Text(
                    'تحويل فوري  ·  آمن  ·  موثوق',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: kTextSub,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── شريط التقدم الذهبي ────────────────────────────────────────────
          Positioned(
            bottom: 56,
            left: 48,
            right: 48,
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 2.5,
                    color: const Color(0xFF1C1508),
                    child: AnimatedBuilder(
                      animation: _progress,
                      builder: (_, __) => FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: _progress.value,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [kGoldDeep, kGold, kGoldLight],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: kGold.withOpacity(0.65),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kGold.withOpacity(0.8),
                        boxShadow: [
                          BoxShadow(
                            color: kGold.withOpacity(0.5),
                            blurRadius: 5,
                          ),
                        ],
                      ),
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

  /// جسيمات مدارية ذهبية — 6 جسيمات
  List<Widget> _buildOrbitParticles(double angle) {
    const double radius = 82;
    final particles = <Widget>[];

    for (int i = 0; i < 6; i++) {
      final particleAngle = angle + (i * math.pi / 3);
      final dx = radius * math.cos(particleAngle);
      final dy = radius * math.sin(particleAngle);
      final isLarge = i % 2 == 0;

      particles.add(
        Transform.translate(
          offset: Offset(dx, dy),
          child: Container(
            width: isLarge ? 7 : 4,
            height: isLarge ? 7 : 4,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLarge
                  ? kGold.withOpacity(0.9)
                  : kGoldLight.withOpacity(0.55),
              boxShadow: [
                BoxShadow(
                  color: kGold.withOpacity(isLarge ? 0.7 : 0.35),
                  blurRadius: isLarge ? 8 : 4,
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
//  خلفية شبكة هندسية ذهبية
// ─────────────────────────────────────────────
class _SplashGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFFECB651).withOpacity(0.028)
      ..strokeWidth = 0.6;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }

    // توهج ذهبي مركزي
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFECB651).withOpacity(0.09),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width * 0.55,
      ));
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width * 0.55, glow);

    // توهج ذهبي سفلي
    final glowBottom = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFD4982A).withOpacity(0.06),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width / 2, size.height),
        radius: size.width * 0.6,
      ));
    canvas.drawCircle(
        Offset(size.width / 2, size.height), size.width * 0.6, glowBottom);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}