/// Shared spacing & corner radii, taken from the mockup to keep every screen consistent.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Standard horizontal padding for content screens.
  static const double screenPadding = 20;

  /// Primary CTA button height.
  static const double buttonHeight = 54;

  /// Secondary button height (used on detail pages).
  static const double buttonHeightSmall = 50;

  /// Minimum tap target for older users (per ui-ux-app-benh-nhan.md section 1).
  static const double minTapTarget = 48;

  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 16;
  static const double radiusXl = 18;
  static const double radiusXxl = 24;
  static const double radiusPill = 999;
}
