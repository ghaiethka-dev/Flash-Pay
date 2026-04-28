// =============================================================================
//  fp_theme.dart
//  Flash Pay — Centralised Design Tokens
//  ──────────────────────────────────────
//  Single source of truth for every colour, text-style, shadow, and gradient
//  used across the User Dashboard UI.
//
//  ✅ UI-only file — zero business logic.
//  Usage:  FPColors.primary  |  FPTextStyles.heading  |  FPShadows.card
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  COLOURS
// ─────────────────────────────────────────────────────────────────────────────
abstract final class FPColors {
  // Brand
  static const Color primary      = Color(0xFFA64D04);
  static const Color primaryLight = Color(0xFFCC6010);
  static const Color primaryDark  = Color(0xFF7A3800);
  static const Color accent       = Color(0xFFE67E22);

  // Semantic
  static const Color blue       = Color(0xFF2563EB);
  static const Color blueDark   = Color(0xFF1D4ED8);
  static const Color green      = Color(0xFF059669);
  static const Color greenLight = Color(0xFF34D399);
  static const Color purple     = Color(0xFF7C3AED);
  static const Color amber      = Color(0xFFF59E0B);

  // Neutrals
  static const Color surface   = Color(0xFFF4F6FA);
  static const Color cardBg    = Colors.white;
  static const Color textDark  = Color(0xFF1A1A2E);
  static const Color textMid   = Color(0xFF6B7280);
  static const Color textLight = Color(0xFFB0B8C1);
  static const Color divider   = Color(0xFFE5E9F0);
}

// ─────────────────────────────────────────────────────────────────────────────
//  TEXT STYLES
// ─────────────────────────────────────────────────────────────────────────────
abstract final class FPTextStyles {
  // App-bar / hero title
  static const TextStyle brandTitle = TextStyle(

    color: Color(0xFF000000),
    fontSize: 22,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.6,
  );

  // Section headings
  static const TextStyle sectionHeading = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: FPColors.textDark,
    letterSpacing: 0.2,
  );

  // Card primary label
  static const TextStyle cardTitle = TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.2,
  );

  // Card sub-label
  static TextStyle cardSubtitle = TextStyle(
    color: Colors.white.withOpacity(0.82),
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  // Greeting
  static const TextStyle greetingHint = TextStyle(
    color: Colors.white70,
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle greetingName = TextStyle(
    color: Colors.white,
    fontSize: 30,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.4,
  );

  // Stats strip
  static const TextStyle statValue = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w800,
  );

  static TextStyle statLabel = TextStyle(
    color: Colors.white.withOpacity(0.75),
    fontSize: 11,
    fontWeight: FontWeight.w500,
  );

  // Pill badge on card
  static const TextStyle badge = TextStyle(
    color: Colors.white,
    fontSize: 11,
    fontWeight: FontWeight.w700,
  );

  // Feature pill label
  static const TextStyle pillLabel = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: FPColors.textDark,
    height: 1.3,
  );

  // Bottom nav active text
  static const TextStyle navActive = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: FPColors.primary,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  SHADOWS
// ─────────────────────────────────────────────────────────────────────────────
abstract final class FPShadows {
  // General card shadow
  static final List<BoxShadow> card = [
    BoxShadow(
      color: Colors.black.withOpacity(0.07),
      blurRadius: 18,
      spreadRadius: 0,
      offset: const Offset(0, 6),
    ),
  ];

  // Coloured glow shadow for remittance cards
  static List<BoxShadow> cardGlow(Color color) => [
        BoxShadow(
          color: color.withOpacity(0.36),
          blurRadius: 22,
          spreadRadius: 0,
          offset: const Offset(0, 10),
        ),
      ];

  // Bottom nav bar shadow
  static final List<BoxShadow> navBar = [
    BoxShadow(
      color: Colors.black.withOpacity(0.09),
      blurRadius: 28,
      spreadRadius: 0,
      offset: const Offset(0, -6),
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
//  GRADIENTS
// ─────────────────────────────────────────────────────────────────────────────
abstract final class FPGradients {
  /// Warm brand gradient used in the hero header.
  static const LinearGradient heroHeader = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFFCC6010),
      FPColors.primary,
      FPColors.primaryDark,
    ],
    stops: [0.0, 0.55, 1.0],
  );

  /// Domestic remittance card gradient (warm orange).
  static const LinearGradient domestic = LinearGradient(
    colors: [FPColors.accent, FPColors.primary],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  /// International remittance card gradient (blue).
  static const LinearGradient international = LinearGradient(
    colors: [FPColors.blue, FPColors.blueDark],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );
}
