import 'package:flutter/material.dart';

/// Brand palette — Madurai Finance Emerald & Forest Green Theme.
class AppColors {
  // Rich Emerald & Forest Greens
  static const Color deepGreen = Color(0xFF0F3D2C);    // Dark Forest Emerald
  static const Color primary = Color(0xFF145C45);      // Deep Emerald Green
  static const Color green = Color(0xFF16A34A);        // Bright Green
  static const Color heroMid = Color(0xFF0B2E21);      // Dark Forest
  static const Color emeraldLight = Color(0xFF34D399); // Light Emerald
  static const Color mint = Color(0xFF10B981);         // Mint / Emerald
  static const Color mintSoft = Color(0xFFECFDF5);     // Soft Mint Tint

  // Royal Gold Accents
  static const Color gold = Color(0xFFC9A227);
  static const Color goldLight = Color(0xFFE7C766);
  static const Color goldWarm = Color(0xFFD4AF37);
  static const Color goldTint = Color(0xFFF9E8B2);
  static const Color goldDark = Color(0xFF947214);
  static const Color goldGlass = Color(0x33C9A227);

  // Surfaces & Backgrounds
  static const Color bg = Color(0xFFF8FAFC);
  static const Color bgDark = Color(0xFF062319);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFE2E8F0);
  static const Color cardDark = Color(0xFF0B2E21);

  // Typography
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textGold = Color(0xFFD4AF37);

  // Status & Real-time Indicators
  static const Color liveGreen = Color(0xFF10B981);
  static const Color liveGreenGlow = Color(0x6610B981);
  static const Color danger = Color(0xFFDC2626);
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color info = Color(0xFF0284C7);
}

/// Gradients used across hero sections, cards, and buttons.
class AppGradients {
  static const LinearGradient hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF062319),
      Color(0xFF0F3D2C),
      Color(0xFF145C45),
    ],
  );

  static const LinearGradient gold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE7C766),
      Color(0xFFC9A227),
      Color(0xFFB58E1A),
    ],
  );

  static const LinearGradient emeraldCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0B2E21),
      Color(0xFF0F3D2C),
    ],
  );

  static const LinearGradient glassGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x29C9A227),
      Color(0x0DC9A227),
    ],
  );

  static const LinearGradient softSurface = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFFFFF),
      Color(0xFFF8FAFC),
    ],
  );
}

/// Elevation shadows with tinting.
class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x0D0F3D2C),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> elevated = [
    BoxShadow(
      color: Color(0x1A0F3D2C),
      blurRadius: 24,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> goldGlow = [
    BoxShadow(
      color: Color(0x40C9A227),
      blurRadius: 18,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> livePulse = [
    BoxShadow(
      color: Color(0x6638BDF8),
      blurRadius: 10,
      spreadRadius: 2,
    ),
  ];
}

/// SharedPreferences keys.
class PrefKeys {
  static const String lastRole = 'mf_last_role';
}

/// Loan / application status color+label helpers.
class StatusMeta {
  static Color colorFor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
      case 'PENDING REVIEW':
        return AppColors.warning;
      case 'APPROVED':
        return AppColors.green;
      case 'DISBURSED':
        return AppColors.deepGreen;
      case 'CLOSED':
      case 'SUCCESS':
      case 'ACTIVE':
        return AppColors.success;
      case 'REJECTED':
      case 'DISABLED':
      case 'FAILED':
        return AppColors.danger;
      default:
        return AppColors.textMuted;
    }
  }
}

/// Hardcoded backend API base URL.
const String kBaseUrl = 'https://datadesigndecide.com/madurai_finance/backend/api';
