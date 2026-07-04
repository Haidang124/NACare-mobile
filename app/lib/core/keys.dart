import 'package:flutter/widgets.dart';

/// Stable keys for important widgets, used by widget/integration tests.
///
/// Centralized (instead of scattering raw `Key('...')` strings) so tests find
/// widgets via a Dart reference — safe to rename, IDE-autocompleted, no typos.
///
/// Usage:
/// ```dart
/// ElevatedButton(key: AppKeys.loginSubmit, onPressed: ...);
/// // in a test:
/// await tester.tap(find.byKey(AppKeys.loginSubmit));
/// ```
class AppKeys {
  const AppKeys._();

  // Auth
  static const loginPhoneField = Key('login_phone_field');
  static const loginSubmit = Key('login_submit');
  static const otpField = Key('otp_field');

  // Booking
  static const bookAppointmentCta = Key('book_appointment_cta');
  static const bookingConfirm = Key('booking_confirm');

  // Main navigation (bottom tabs)
  static const tabHome = Key('tab_home');
  static const tabAppointments = Key('tab_appointments');
  static const tabResults = Key('tab_results');
  static const tabNotifications = Key('tab_notifications');
  static const tabProfile = Key('tab_profile');
}
