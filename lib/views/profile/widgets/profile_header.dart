// =============================================================================
//  profile_header.dart
//  Flash Pay — Profile Hero Header
//  ─────────────────────────────────
//  Full-bleed gradient section that shows:
//    • Lottie avatar inside a circular glowing frame
//    • User's name + email/phone (read from controller text values)
//    • "Verified User" badge with animated glow ring
//
//  ✅ UI-only.  Accepts data as plain Strings — rebuilt by parent Obx().
//     The Lottie asset path is unchanged from the original: 'images/profile.json'
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

// Re-use shared brand tokens from the dashboard revamp
import '../../dashboards/user_dashboards/widgets/fp_theme.dart';

class ProfileHeader extends StatefulWidget {
  /// User's full name — read from controller.nameController.text
  final String name;

  /// Contact detail shown below the name (email or phone)
  final String contact;

  const ProfileHeader({
    Key? key,
    required this.name,
    required this.contact,
  }) : super(key: key);

  @override
  State<ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<ProfileHeader>
    with SingleTickerProviderStateMixin {
  // ── Pulsing glow animation (local UI state only) ─────────────────────────
  late final AnimationController _glowAc = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _glowAc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarH = MediaQuery.of(context).padding.top;

    return Container(
      padding: EdgeInsets.only(top: statusBarH),
      decoration: const BoxDecoration(
        gradient: FPGradients.heroHeader,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Stack(
        children: [
          // ── Decorative background circles ───────────────────────────────
          const Positioned(top: -30, right: -50,
              child: _DecorCircle(size: 200, opacity: 0.08)),
          const Positioned(bottom: 10, left: -60,
              child: _DecorCircle(size: 220, opacity: 0.05)),

          // ── Main content ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              children: [
                // Avatar with animated glow ring
                AnimatedBuilder(
                  animation: _glowAc,
                  builder: (_, child) {
                    final double glowSpread =
                        4 + (_glowAc.value * 8); // 4–12 px pulse
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.30),
                            blurRadius: 28,
                            spreadRadius: glowSpread,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.18),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.50), width: 2.5),
                    ),
                    // ✅ Lottie path unchanged from original
                    child: ClipOval(
                      child: Lottie.asset(
                        'images/profile.json',
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                        repeat: true,
                      ),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(
                      begin: const Offset(0.7, 0.7),
                      curve: Curves.easeOutBack,
                    ),

                const SizedBox(height: 16),

                // User name
                Text(
                  widget.name.isEmpty ? 'المستخدم' : widget.name,
                  style: FPTextStyles.greetingName.copyWith(fontSize: 24),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(delay: 150.ms, duration: 400.ms)
                    .slideY(begin: 0.10, curve: Curves.easeOut),

                const SizedBox(height: 6),

                // Email / phone
                Text(
                  widget.contact.isEmpty ? '—' : widget.contact,
                  style: FPTextStyles.greetingHint.copyWith(fontSize: 13),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(delay: 220.ms, duration: 400.ms)
                    .slideY(begin: 0.10, curve: Curves.easeOut),

                const SizedBox(height: 16),

                // "Verified User" badge
                const _VerifiedBadge()
                    .animate()
                    .fadeIn(delay: 320.ms, duration: 450.ms)
                    .slideY(begin: 0.10, curve: Curves.easeOut),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Verified badge pill ──────────────────────────────────────────────────────
class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.20),
        borderRadius: BorderRadius.circular(30),
        border:
            Border.all(color: Colors.white.withOpacity(0.45), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.verified_rounded, color: Colors.white, size: 16),
          SizedBox(width: 6),
          Text(
            'مستخدم موثَّق',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Decorative background circle ────────────────────────────────────────────
class _DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const _DecorCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}
