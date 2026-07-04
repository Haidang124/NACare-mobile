import 'package:flutter/material.dart';

/// Design tokens taken from the mockup `NaHealth-UI/NAHealth App.dc.html`.
/// Named semantically (not by color name) to make adding dark mode easier later.
abstract final class AppColors {
  // Brand / primary
  static const Color primary = Color(0xFF149A4B);
  static const Color primaryDark = Color(0xFF0F7C3C);
  static const Color primaryLight = Color(0xFF18A853);
  static const Color primarySoft = Color(0xFF1BAA56);
  static const Color gradientTop = Color(0xFF0D6E35);
  static const Color gradientBottom = Color(0xFF118A43);

  // Surfaces
  static const Color surfaceBg = Color(0xFFF2F7F3);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color surfaceInput = Color(0xFFF7FAF8);

  // Borders / dividers
  static const Color borderCard = Color(0xFFE7F0EA);
  static const Color borderDivider = Color(0xFFF0F6F1);
  static const Color borderSoft = Color(0xFFE2EEE6);
  static const Color borderMedium = Color(0xFFD6E2DA);
  static const Color borderDashed = Color(0xFFA9CDB6);
  static const Color otpFilledBorder = Color(0xFFB5DCC4);

  // Icon chip backgrounds
  static const Color iconBgSoft = Color(0xFFEEF5F0);
  static const Color iconBgSoft2 = Color(0xFFEFF7F1);

  // Text
  static const Color textPrimary = Color(0xFF14301F);
  static const Color textBody = Color(0xFF3E4E44);
  static const Color textSecondary = Color(0xFF5B6B60);
  static const Color textTertiary = Color(0xFF7A8A7F);
  static const Color textMuted = Color(0xFF9AAAA0);
  static const Color textChevron = Color(0xFFB7C6BC);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Green tints (success / active states)
  static const Color greenTint = Color(0xFFE3F5EA);
  static const Color greenTintSoft = Color(0xFFF4FBF6);
  static const Color greenBorder = Color(0xFFCBE5D4);
  static const Color greenBorderLight = Color(0xFFC7E3D1);
  static const Color greenAvatarRing = Color(0xFF7FD6A2);
  static const Color timelineLine = Color(0xFFDCE8DF);

  // Accent (highlights / unread dots / "new")
  static const Color accent = Color(0xFFE5399B);
  static const Color accentTint = Color(0xFFFDEBF4);
  static const Color accentText = Color(0xFF9C2A66);
  static const Color accentTextSoft = Color(0xFFB0568A);
  static const Color accentBorder = Color(0xFFF5C8DF);

  // Warning (pending / awaiting action / payment due)
  static const Color warning = Color(0xFFB36A00);
  static const Color warningTint = Color(0xFFFFF3DF);
  static const Color warningTintSoft = Color(0xFFFFF9EC);
  static const Color warningBorder = Color(0xFFF2E3BC);
  static const Color warningText = Color(0xFF8A6D1F);

  // Error / destructive (cancelled, overdue, out of range)
  static const Color error = Color(0xFFC2333E);
  static const Color errorTint = Color(0xFFFBEBEC);
  static const Color errorTintRow = Color(0xFFFEF6F6);
  static const Color errorBorder = Color(0xFFF3C9CD);
  static const Color errorBorderStrong = Color(0xFFE39AA0);

  // Neutral (past / cancelled badge)
  static const Color neutralTint = Color(0xFFEDF2EE);

  // Info (light-blue icon background, e.g. the Payment / VNPay shortcut)
  static const Color infoTint = Color(0xFFEAF1FB);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [gradientTop, gradientBottom],
  );

  static const LinearGradient onboardingGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryDark, Color(0xFF149A4B), primarySoft],
    stops: [0.0, 0.6, 1.0],
  );

  static const LinearGradient heroCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primaryLight],
  );
}
