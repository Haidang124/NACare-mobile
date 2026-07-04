/// Route path constants — use these everywhere instead of typing strings, to avoid drift.
abstract final class AppRoutes {
  // Auth / onboarding stack (not logged in)
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String linkProfile = '/link-profile';
  static const String pinSetup = '/pin-setup';
  static const String consent = '/consent';

  // Bottom-nav shell (logged in) — 5 tabs per ui-ux-app-benh-nhan.md section 3.
  static const String home = '/home';
  static const String appointments = '/appointments';
  static const String results = '/results';
  static const String notifications = '/notifications';
  static const String profile = '/profile';

  // Booking & check-in
  static const String bookAppointment = '/appointments/book';
  static const String bookAppointmentSuccess = '/appointments/book/success';
  static const String appointmentDetail = '/appointments/:id';
  static const String checkin = '/checkin';
  static const String queue = '/queue';

  // Results & prescriptions
  static const String resultDetail = '/results/:id';
  static const String prescription = '/results/:id/prescription';
  static const String medicationReminders = '/medication-reminders';

  // Profile
  static const String personalInfo = '/profile/personal-info';
  static const String payments = '/profile/payments';
  static const String billDetail = '/profile/payments/:id';
  static const String immunization = '/profile/immunization';
  static const String healthMetrics = '/profile/health-metrics';
  static const String security = '/profile/security';
  static const String consentManagement = '/profile/security/consent';

  static String appointmentDetailPath(String id) => '/appointments/$id';
  static String resultDetailPath(String id) => '/results/$id';
  static String prescriptionPath(String resultId) =>
      '/results/$resultId/prescription';
  static String billDetailPath(String id) => '/profile/payments/$id';
}
