// =============================================================================
//  lib/views/auth/widgets/fp_auth_style.dart
//  FlashPay — هوية شاشات الدخول/التسجيل = هوية الـ Splash (أسود + ذهبي)
//
//  • FPAuth            : ألوان الهوية (نفس ثوابت splash_screen.dart)
//  • FPAuthTheme       : يُجبر الشاشة على ثيم داكن ذهبي (مستقل عن ثيم التطبيق)
//  • FPAuthThemeExt    : يقرؤها FPAuthField تلقائياً (لا حاجة لتمرير ألوان لكل حقل)
//  • FPAuthBackground  : شبكة هندسية + توهج ذهبي علوي/سفلي (كما في الـ Splash)
//  • FPAuthLogo        : دائرة ذهبية + برق داكن + حلقة نابضة (تتوقف مع "تقليل الحركة")
//  • FPAuthBrand       : "FlashPay" بتدرج ذهبي + خط تحته
//  • FPAuthCard        : بطاقة سوداء دافئة بحد ذهبي رفيع
//  • FPGoldButton      : زر ذهبي (نص أسود: تباين ≈ 11:1 بدل الأبيض ≈ 1.9:1)
// =============================================================================

import 'package:flutter/material.dart';

import 'package:flashpay/core/app_transitions.dart';

/// ألوان الهوية — مطابقة لثوابت splash_screen.dart
abstract final class FPAuth {
  static const Color bg        = Color(0xFF080808); // خلفية الـ Splash
  static const Color gold      = Color(0xFFECB651);
  static const Color goldLight = Color(0xFFF5D27A);
  static const Color goldDeep  = Color(0xFFD4982A);
  static const Color textSub   = Color(0xFF9E8878); // نص ثانوي (≥ 5.5:1 على السطح)

  static const Color surface   = Color(0xFF110F09); // بطاقة: أسود دافئ
  static const Color fieldFill = Color(0xFF181409); // حقل داخل البطاقة
  static const Color text      = Color(0xFFF5EFE6); // أبيض دافئ
  static const Color hint      = Color(0xFF8A7B6B); // تلميحات (≈ 4.6:1 على الحقل)
  static const Color success   = Color(0xFF4ADE80);

  /// حد الحقول: ذهبي بشفافية (≈ 2.6:1 مع الحقل)
  static Color get border => gold.withOpacity(0.42);

  static const LinearGradient goldGradient = LinearGradient(
    colors: [goldDeep, gold, goldLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}

// =============================================================================
//  ThemeExtension — تقرأه FPAuthField/FPAuthDropdown
// =============================================================================
class FPAuthThemeExt extends ThemeExtension<FPAuthThemeExt> {
  final Color accent;
  final Color fill;
  final Color label;
  final Color text;
  final Color hint;
  final Color border;

  const FPAuthThemeExt({
    required this.accent,
    required this.fill,
    required this.label,
    required this.text,
    required this.hint,
    required this.border,
  });

  @override
  FPAuthThemeExt copyWith({
    Color? accent,
    Color? fill,
    Color? label,
    Color? text,
    Color? hint,
    Color? border,
  }) =>
      FPAuthThemeExt(
        accent: accent ?? this.accent,
        fill: fill ?? this.fill,
        label: label ?? this.label,
        text: text ?? this.text,
        hint: hint ?? this.hint,
        border: border ?? this.border,
      );

  @override
  FPAuthThemeExt lerp(ThemeExtension<FPAuthThemeExt>? other, double t) {
    if (other is! FPAuthThemeExt) return this;
    return FPAuthThemeExt(
      accent: Color.lerp(accent, other.accent, t)!,
      fill: Color.lerp(fill, other.fill, t)!,
      label: Color.lerp(label, other.label, t)!,
      text: Color.lerp(text, other.text, t)!,
      hint: Color.lerp(hint, other.hint, t)!,
      border: Color.lerp(border, other.border, t)!,
    );
  }
}

/// يُجبر ما تحته على ثيم داكن ذهبي (الدخول/التسجيل دائماً بهوية الـ Splash)
class FPAuthTheme extends StatelessWidget {
  final Widget child;
  const FPAuthTheme({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);
    final dark = ThemeData.dark();

    return Theme(
      data: dark.copyWith(
        scaffoldBackgroundColor: FPAuth.bg,
        cardColor: FPAuth.surface,
        dividerColor: FPAuth.border,
        primaryColor: FPAuth.gold,
        canvasColor: FPAuth.surface,
        textTheme: base.textTheme.apply(
          bodyColor: FPAuth.text,
          displayColor: FPAuth.text,
        ),
        colorScheme: const ColorScheme.dark(
          primary: FPAuth.gold,
          secondary: FPAuth.goldLight,
          surface: FPAuth.surface,
          onSurface: FPAuth.text,
          onPrimary: FPAuth.bg,
          error: Color(0xFFFF8A80),
        ),
        iconTheme: const IconThemeData(color: FPAuth.gold),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: FPAuth.gold,
          selectionColor: FPAuth.gold.withOpacity(0.30),
          selectionHandleColor: FPAuth.gold,
        ),
        progressIndicatorTheme:
            const ProgressIndicatorThemeData(color: FPAuth.gold),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(color: FPAuth.goldLight),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF1B1710),
          contentTextStyle: TextStyle(color: FPAuth.text),
        ),
        extensions: [
          FPAuthThemeExt(
            accent: FPAuth.gold,
            fill: FPAuth.fieldFill,
            label: FPAuth.text,
            text: FPAuth.text,
            hint: FPAuth.hint,
            border: FPAuth.border,
          ),
        ],
      ),
      child: child,
    );
  }
}

// =============================================================================
//  الخلفية — شبكة هندسية + توهج ذهبي (مطابقة لـ _SplashGridPainter)
// =============================================================================
class FPAuthBackground extends StatelessWidget {
  final Widget child;
  const FPAuthBackground({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        const Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(painter: _AuthGridPainter()),
          ),
        ),
        // توهج علوي
        Positioned(
          top: -size.height * 0.15,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: size.height * 0.55,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    FPAuth.gold.withOpacity(0.14),
                    FPAuth.goldDeep.withOpacity(0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
        ),
        // توهج سفلي
        Positioned(
          bottom: -size.height * 0.1,
          left: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              height: size.height * 0.35,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    FPAuth.goldDeep.withOpacity(0.07),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class _AuthGridPainter extends CustomPainter {
  const _AuthGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = FPAuth.gold.withOpacity(0.028)
      ..strokeWidth = 0.6;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// =============================================================================
//  الشعار — دائرة ذهبية + برق داكن + حلقة نابضة
// =============================================================================
class FPAuthLogo extends StatefulWidget {
  /// قطر الدائرة الذهبية
  final double size;
  const FPAuthLogo({Key? key, this.size = 88}) : super(key: key);

  @override
  State<FPAuthLogo> createState() => _FPAuthLogoState();
}

class _FPAuthLogoState extends State<FPAuthLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  );

  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // احترام "تقليل الحركة": لا نبض
    if (!_started && !FPMotion.reduced(context)) {
      _started = true;
      _pulse.repeat();
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double d = widget.size;
    final double box = d * 1.7;

    return Semantics(
      label: 'شعار FlashPay',
      image: true,
      child: ExcludeSemantics(
        child: SizedBox(
          width: box,
          height: box,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // حلقة نابضة
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, __) {
                  final t = Curves.easeOut.transform(_pulse.value);
                  final s = 0.62 + 0.38 * t; // 0.62 → 1.0
                  return Opacity(
                    opacity: (1 - t).clamp(0.0, 0.45),
                    child: Container(
                      width: box * s,
                      height: box * s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: FPAuth.gold, width: 1.4),
                      ),
                    ),
                  );
                },
              ),
              // الدائرة الذهبية
              Container(
                width: d,
                height: d,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [FPAuth.goldLight, FPAuth.gold, FPAuth.goldDeep],
                    stops: [0.0, 0.55, 1.0],
                    center: Alignment(-0.2, -0.3),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: FPAuth.gold.withOpacity(0.45),
                      blurRadius: d * 0.32,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: FPAuth.goldDeep.withOpacity(0.25),
                      blurRadius: d * 0.58,
                      spreadRadius: d * 0.08,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.bolt_rounded,
                  color: FPAuth.bg,
                  size: d * 0.54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================================
//  اسم التطبيق — تدرج ذهبي + خط تحته
// =============================================================================
class FPAuthBrand extends StatelessWidget {
  final double fontSize;
  const FPAuthBrand({Key? key, this.fontSize = 36}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              FPAuth.goldDeep,
              FPAuth.goldLight,
              FPAuth.gold,
              FPAuth.goldLight,
              FPAuth.goldDeep,
            ],
            stops: [0.0, 0.25, 0.5, 0.75, 1.0],
          ).createShader(bounds),
          child: Text(
            'FlashPay',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: fontSize,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2.0,
              height: 1.0,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 84,
          height: 2,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Colors.transparent,
                FPAuth.goldDeep,
                FPAuth.goldLight,
                FPAuth.goldDeep,
                Colors.transparent,
              ],
              stops: [0.0, 0.2, 0.5, 0.8, 1.0],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
//  بطاقة النموذج
// =============================================================================
class FPAuthCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const FPAuthCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: FPAuth.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: FPAuth.gold.withOpacity(0.20)),
        boxShadow: [
          BoxShadow(
            color: FPAuth.gold.withOpacity(0.06),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.55),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
  }
}

// =============================================================================
//  الزر الذهبي — نص أسود على الذهبي (تباين عالٍ)، مع حالة تحميل
// =============================================================================
class FPGoldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final double height;

  const FPGoldButton({
    Key? key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.height = 54,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null && !loading;

    return Semantics(
      button: true,
      enabled: enabled,
      label: loading ? '$label، جارٍ التنفيذ' : label,
      child: ExcludeSemantics(
        child: Opacity(
          opacity: onPressed == null ? 0.5 : 1,
          child: Container(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              gradient: FPAuth.goldGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: FPAuth.gold.withOpacity(0.32),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                splashColor: Colors.black.withOpacity(0.12),
                highlightColor: Colors.black.withOpacity(0.06),
                onTap: enabled ? onPressed : null,
                child: Center(
                  child: AnimatedSwitcher(
                    duration: FPMotion.fast,
                    child: loading
                        ? const SizedBox(
                            key: ValueKey('loading'),
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: FPAuth.bg,
                              strokeWidth: 2.6,
                            ),
                          )
                        : Text(
                            label,
                            key: const ValueKey('label'),
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16.5,
                              fontWeight: FontWeight.w800,
                              color: FPAuth.bg,
                              letterSpacing: 0.4,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// زر نصي ذهبي (روابط ثانوية)
class FPGoldLink extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool bold;
  const FPGoldLink({
    Key? key,
    required this.label,
    required this.onPressed,
    this.bold = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: FPAuth.gold,
        minimumSize: const Size(48, 44),
        padding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          color: FPAuth.gold,
        ),
      ),
    );
  }
}
