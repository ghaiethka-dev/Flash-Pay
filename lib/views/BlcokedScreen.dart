import 'dart:async';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/local/storage_service.dart';
import '../data/network/api_client.dart';
import '../data/network/api_constants.dart';

// ==========================================
//  BlockedScreen — صفحة الحساب المحظور
//  FlashPay · مع زر التواصل عبر تيليغرام
// ==========================================

class BlockedScreen extends StatefulWidget {
  const BlockedScreen({Key? key}) : super(key: key);

  @override
  State<BlockedScreen> createState() => _BlockedScreenState();
}

class _BlockedScreenState extends State<BlockedScreen>
    with TickerProviderStateMixin {
  static const Color kPrimary     = Color(0xFFA64D04);
  static const Color kPrimaryDark = Color(0xFF7A3803);
  static const Color kPrimaryGlow = Color(0xFFE8834A);
  static const Color kBg          = Color(0xFF0D0D0D);
  static const Color kSurface     = Color(0xFF1A1410);
  static const Color kBorder      = Color(0xFF2E1F10);
  static const Color kTextPrimary = Color(0xFFF5EDE4);
  static const Color kTextSub     = Color(0xFF9E8878);

  // لون تيليغرام
  static const Color kTelegram    = Color(0xFF2AABEE);

  late final AnimationController _pulseCtrl;
  late final AnimationController _floatCtrl;
  late final AnimationController _entranceCtrl;
  late final Animation<double> _pulseAnim;
  late final Animation<double> _floatAnim;

  Timer? _unblockTimer;
  static const Duration _pollInterval = Duration(seconds: 15);
  late final Animation<double> _fadeIcon;
  late final Animation<Offset> _slideTitle;
  late final Animation<double> _fadeTitle;
  late final Animation<double> _fadeCard;
  late final Animation<double> _fadeButtons;

  @override
  void initState() {
    super.initState();
    _startUnblockPolling();

    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.85, end: 1.15).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));

    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800))
      ..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8.0, end: 8.0).animate(
        CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    _entranceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600))
      ..forward();

    _fadeIcon = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));

    _slideTitle = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
        CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.25, 0.6, curve: Curves.easeOutCubic)));

    _fadeTitle = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.25, 0.6, curve: Curves.easeOut)));

    _fadeCard = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.5, 0.8, curve: Curves.easeOut)));

    _fadeButtons = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _entranceCtrl, curve: const Interval(0.72, 1.0, curve: Curves.easeOut)));
  }

  @override
  void dispose() {
    _unblockTimer?.cancel();
    _pulseCtrl.dispose();
    _floatCtrl.dispose();
    _entranceCtrl.dispose();
    super.dispose();
  }

  void _startUnblockPolling() {
    _checkIfUnblocked();
    _unblockTimer = Timer.periodic(_pollInterval, (_) => _checkIfUnblocked());
  }

  Future<void> _checkIfUnblocked() async {
    try {
      final storageService = Get.find<StorageService>();
      final token = storageService.getToken();
      if (token == null || token.isEmpty) return;

      final client = ApiClient();
      final response = await client.dio.get(
        ApiConstants.meEndpoint,
        options: dio.Options(
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      );

      if (response.statusCode == 200) {
        final isActive = response.data['user']['is_active'];
        if (isActive == true || isActive == 1) {
          _unblockTimer?.cancel();
          await storageService.saveIsBlocked(false);
          Get.offAllNamed('/user_dashboard');
          Get.snackbar(
            'تم فك الحظر',
            'تم تفعيل حسابك، يمكنك الاستخدام الآن',
            backgroundColor: const Color(0xFF16a34a),
            colorText: const Color(0xFFFFFFFF),
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 4),
            margin: const EdgeInsets.all(12),
            borderRadius: 12,
            icon: const Icon(Icons.check_circle_outline, color: Color(0xFFFFFFFF)),
          );
        }
      }
    } on dio.DioException catch (_) {
    } catch (_) {}
  }

  Future<void> _openTelegram() async {
    // يفتح تطبيق تيليغرام مباشرة إن وُجد، وإلا يفتح الويب
    final appUri = Uri.parse('tg://resolve?domain=Majdi_exchange');
    final webUri = Uri.parse('https://t.me/Majdi_exchange');

    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri);
    } else {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _logout() async {
    final storageService = Get.find<StorageService>();
    await storageService.clearAuthData();
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: Stack(
        children: [
          const _GridBackground(),
          SafeArea(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // شعار
                    FadeTransition(
                      opacity: _fadeIcon,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8, height: 8,
                            decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'FlashPay',
                            style: TextStyle(
                              fontFamily: 'Cairo', fontSize: 17, fontWeight: FontWeight.w800,
                              color: kTextSub, letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(flex: 2),

                    // أيقونة القفل
                    FadeTransition(
                      opacity: _fadeIcon,
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_pulseAnim, _floatAnim]),
                        builder: (_, __) => Transform.translate(
                          offset: Offset(0, _floatAnim.value),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Transform.scale(
                                scale: _pulseAnim.value,
                                child: Container(
                                  width: 148, height: 148,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: kPrimary.withOpacity(0.13), width: 1.5),
                                  ),
                                ),
                              ),
                              Transform.scale(
                                scale: _pulseAnim.value * 0.87,
                                child: Container(
                                  width: 118, height: 118,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(color: kPrimary.withOpacity(0.24), width: 1.5),
                                  ),
                                ),
                              ),
                              Container(
                                width: 94, height: 94,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: kSurface,
                                  border: Border.all(color: kPrimaryDark, width: 2),
                                  boxShadow: [BoxShadow(color: kPrimary.withOpacity(0.38), blurRadius: 32, spreadRadius: 4)],
                                ),
                                child: const Icon(Icons.lock_outline_rounded, size: 44, color: kPrimaryGlow),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 48),

                    // العنوان
                    SlideTransition(
                      position: _slideTitle,
                      child: FadeTransition(
                        opacity: _fadeTitle,
                        child: Column(
                          children: [
                            const Text(
                              'تم تعليق حسابك',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Cairo', fontSize: 30, fontWeight: FontWeight.w900,
                                color: kTextPrimary, height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              width: 44, height: 3,
                              decoration: BoxDecoration(color: kPrimary, borderRadius: BorderRadius.circular(2)),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // بطاقة الرسالة
                    FadeTransition(
                      opacity: _fadeCard,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 24),
                        decoration: BoxDecoration(
                          color: kSurface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: kBorder, width: 1),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 36, height: 36,
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: kPrimary.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.info_outline_rounded, color: kPrimaryGlow, size: 20),
                            ),
                            const Text(
                              'حسابك موقوف مؤقتاً من قبل الإدارة.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Cairo', fontSize: 15, fontWeight: FontWeight.w700,
                                color: kTextPrimary, height: 1.6,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'يُرجى التواصل مع الإدارة\nلمعرفة سبب التعليق وإعادة تفعيل حسابك.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Cairo', fontSize: 13,
                                color: kTextSub, height: 1.9,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // ── زر التواصل عبر تيليغرام ──
                            GestureDetector(
                              onTap: _openTelegram,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF1E96D0), Color(0xFF2AABEE)],
                                    begin: Alignment.centerRight,
                                    end: Alignment.centerLeft,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: kTelegram.withOpacity(0.30),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.send_rounded, color: Colors.white, size: 18),
                                    SizedBox(width: 10),
                                    Text(
                                      'تواصل معنا عبر تيليغرام',
                                      style: TextStyle(
                                        fontFamily: 'Cairo',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Spacer(flex: 3),

                    // زر تسجيل الخروج
                    FadeTransition(
                      opacity: _fadeButtons,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 36),
                        child: GestureDetector(
                          onTap: _logout,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF2E1F10),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.logout_rounded, color: Color(0xFF9E8878), size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'تسجيل الخروج',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF9E8878),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  خلفية شبكة هندسية
// ─────────────────────────────────────────────
class _GridBackground extends StatelessWidget {
  const _GridBackground();
  @override
  Widget build(BuildContext context) => CustomPaint(painter: _GridPainter(), size: Size.infinite);
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFFA64D04).withOpacity(0.045)..strokeWidth = 0.8;
    const step = 48.0;
    for (double x = 0; x < size.width; x += step) canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    for (double y = 0; y < size.height; y += step) canvas.drawLine(Offset(0, y), Offset(size.width, y), p);

    final g1 = Paint()..shader = RadialGradient(
      colors: [const Color(0xFFA64D04).withOpacity(0.14), Colors.transparent],
    ).createShader(Rect.fromCircle(center: Offset(size.width / 2, size.height * 0.38), radius: size.width * 0.55));
    canvas.drawCircle(Offset(size.width / 2, size.height * 0.38), size.width * 0.55, g1);

    final g2 = Paint()..shader = RadialGradient(
      colors: [const Color(0xFFA64D04).withOpacity(0.07), Colors.transparent],
    ).createShader(Rect.fromCircle(center: Offset(size.width / 2, size.height), radius: size.width * 0.6));
    canvas.drawCircle(Offset(size.width / 2, size.height), size.width * 0.6, g2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}