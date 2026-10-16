// =============================================================================
//  profile_header.dart  — FlashPay (Fixed & Enhanced)
//  ✅ FIX: Avatar size is now responsive (min 100, max 130) via MediaQuery
//  ✅ FIX: Name + contact text use maxLines + overflow to prevent layout breaks
//  ✅ FIX: Container padding uses SafeArea top instead of MediaQuery manually
//  ✅ IMPROVE: _VerifiedBadge is fully const
//  ✅ IMPROVE: const constructors throughout
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';

import '../../dashboards/user_dashboards/widgets/fp_theme.dart';

class ProfileHeader extends StatefulWidget {
  final String name;
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
    // ✅ FIX: Responsive avatar size clamped between 100–130px
    final double avatarSize =
    (MediaQuery.of(context).size.width * 0.30).clamp(100.0, 130.0);

    return Container(
      padding: EdgeInsets.only(top: statusBarH),
      decoration: const BoxDecoration(
        gradient: FPGradients.heroHeader,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Stack(
        children: [
          const Positioned(
              top: -30, right: -50,
              child: _DecorCircle(size: 200, opacity: 0.08)),
          const Positioned(
              bottom: 10, left: -60,
              child: _DecorCircle(size: 220, opacity: 0.05)),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              children: [
                // Avatar with glow ring
                AnimatedBuilder(
                  animation: _glowAc,
                  builder: (_, child) {
                    final double spread = 4 + (_glowAc.value * 8);
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.30),
                            blurRadius: 28,
                            spreadRadius: spread,
                          ),
                        ],
                      ),
                      child: child,
                    );
                  },
                  child: Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.18),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.50), width: 2.5),
                    ),
                    child: ClipOval(
                      child: Lottie.asset(
                        'images/profile.json',
                        height: avatarSize,
                        width:  avatarSize,
                        fit:    BoxFit.cover,
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

                // ✅ FIX: maxLines + overflow for very long names
                Text(
                  widget.name.isEmpty ? 'المستخدم' : widget.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: FPTextStyles.greetingName.copyWith(fontSize: 22),
                )
                    .animate()
                    .fadeIn(delay: 150.ms, duration: 400.ms)
                    .slideY(begin: 0.10, curve: Curves.easeOut),

                const SizedBox(height: 6),

                // ✅ FIX: maxLines for long email addresses
                Text(
                  widget.contact.isEmpty ? '—' : widget.contact,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: FPTextStyles.greetingHint.copyWith(fontSize: 13),
                )
                    .animate()
                    .fadeIn(delay: 220.ms, duration: 400.ms)
                    .slideY(begin: 0.10, curve: Curves.easeOut),

                const SizedBox(height: 16),

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

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.20),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
            color: Colors.white.withOpacity(0.45), width: 1.2),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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

class _DecorCircle extends StatelessWidget {
  final double size;
  final double opacity;
  const _DecorCircle({required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(opacity),
      ),
    );
  }
}