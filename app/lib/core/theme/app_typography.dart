import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Type scale tuned for older users: body is at least 16sp (per ui-ux-app-benh-nhan.md
/// section 1). Uses a single font (Be Vietnam Pro) across the whole app.
abstract final class AppTypography {
  static TextStyle _base({
    required double size,
    required FontWeight weight,
    Color color = AppColors.textPrimary,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.beVietnamPro(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// 28sp/800 — app name on onboarding.
  static TextStyle get brand => _base(
      size: 28,
      weight: FontWeight.w800,
      color: Colors.white,
      letterSpacing: 0.3);

  /// 24sp/800 — large screen heading (display).
  static TextStyle get display => _base(size: 24, weight: FontWeight.w800);

  /// 23sp/800 — tab heading (Appointments, Results...).
  static TextStyle get tabTitle => _base(size: 23, weight: FontWeight.w800);

  /// 20sp/800 — standard title (app bar with a back button).
  static TextStyle get title => _base(size: 20, weight: FontWeight.w800);

  /// 18sp/800 — secondary app bar title.
  static TextStyle get titleSmall => _base(size: 18, weight: FontWeight.w800);

  /// 17sp/700 — primary button, large phone number.
  static TextStyle get button =>
      _base(size: 17, weight: FontWeight.w700, color: Colors.white);

  /// 16sp/400 — main body (minimum for reading content).
  static TextStyle get body =>
      _base(size: 16, weight: FontWeight.w400, color: AppColors.textBody);

  /// 16sp/700 — emphasized body.
  static TextStyle get bodyBold => _base(size: 16, weight: FontWeight.w700);

  /// 15sp/600 — secondary body / input label.
  static TextStyle get bodySecondary =>
      _base(size: 15, weight: FontWeight.w600, color: AppColors.textSecondary);

  /// 14sp/400 — caption / secondary description.
  static TextStyle get caption =>
      _base(size: 14, weight: FontWeight.w400, color: AppColors.textSecondary);

  /// 14sp/700 — emphasized caption (small price, large badge).
  static TextStyle get captionBold => _base(size: 14, weight: FontWeight.w700);

  /// 13sp/600 — badge / small label.
  static TextStyle get label =>
      _base(size: 13, weight: FontWeight.w700, color: AppColors.textTertiary);

  /// 12sp/800 — uppercase label (SECTION HEADER, TODAY...).
  static TextStyle get eyebrow => _base(
        size: 12,
        weight: FontWeight.w800,
        color: AppColors.textTertiary,
        letterSpacing: 0.5,
      );

  /// 11sp/700 — micro label (very small badge).
  static TextStyle get micro => _base(size: 11.5, weight: FontWeight.w800);

  /// Large number (queue ticket number).
  static TextStyle get numberHero =>
      _base(size: 88, weight: FontWeight.w800, color: Colors.white, height: 1);
}
