import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/appointments/data/models/booking_draft.dart';
import '../../features/appointments/presentation/screens/appointment_detail_screen.dart';
import '../../features/appointments/presentation/screens/appointments_tab_screen.dart';
import '../../features/appointments/presentation/screens/book_appointment_screen.dart';
import '../../features/appointments/presentation/screens/booking_success_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/link_profile_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/pin_setup_screen.dart';
import '../../features/checkin/presentation/screens/checkin_screen.dart';
import '../../features/checkin/presentation/screens/queue_screen.dart';
import '../../features/consent/presentation/screens/consent_screen.dart';
import '../../features/health_metrics/presentation/screens/health_metrics_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/immunization/presentation/screens/immunization_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/payments/presentation/screens/bill_detail_screen.dart';
import '../../features/payments/presentation/screens/payments_screen.dart';
import '../../features/personal_info/presentation/screens/personal_info_screen.dart';
import '../../features/prescriptions/presentation/screens/medication_reminders_screen.dart';
import '../../features/prescriptions/presentation/screens/prescription_screen.dart';
import '../../features/profile/presentation/screens/profile_tab_screen.dart';
import '../../features/results/presentation/screens/result_detail_screen.dart';
import '../../features/results/presentation/screens/results_tab_screen.dart';
import '../../features/security/presentation/screens/consent_management_screen.dart';
import '../../features/security/presentation/screens/security_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import 'app_routes.dart';

// The full route → file table lives in docs/architecture/02-danh-sach-man-hinh.md.
final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionControllerProvider);

  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    redirect: (context, state) {
      const authRoutes = {
        AppRoutes.onboarding,
        AppRoutes.login,
        AppRoutes.otp,
        AppRoutes.linkProfile,
        AppRoutes.pinSetup,
        AppRoutes.consent,
      };
      final isOnAuthRoute = authRoutes.contains(state.matchedLocation);

      if (!session.isAuthenticated && !isOnAuthRoute) {
        return AppRoutes.onboarding;
      }
      if (session.isAuthenticated && isOnAuthRoute) return AppRoutes.home;
      return null;
    },
    routes: [
      // ── Auth / onboarding ──
      GoRoute(
          path: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingScreen()),
      GoRoute(
          path: AppRoutes.login,
          builder: (context, state) => const LoginScreen()),
      GoRoute(
          path: AppRoutes.otp, builder: (context, state) => const OtpScreen()),
      GoRoute(
          path: AppRoutes.linkProfile,
          builder: (context, state) => const LinkProfileScreen()),
      GoRoute(
          path: AppRoutes.pinSetup,
          builder: (context, state) => const PinSetupScreen()),
      GoRoute(
          path: AppRoutes.consent,
          builder: (context, state) => const ConsentScreen()),

      // ── 5-tab shell ──
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.appointments,
                builder: (context, state) => const AppointmentsTabScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.results,
                builder: (context, state) => const ResultsTabScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.notifications,
                builder: (context, state) => const NotificationsScreen()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileTabScreen()),
          ]),
        ],
      ),

      // ── Booking & check-in ──
      GoRoute(
          path: AppRoutes.bookAppointment,
          builder: (context, state) => const BookAppointmentScreen()),
      GoRoute(
        path: AppRoutes.bookAppointmentSuccess,
        builder: (context, state) => BookingSuccessScreen(
            confirmation: state.extra as BookingConfirmation),
      ),
      GoRoute(
        path: AppRoutes.appointmentDetail,
        builder: (context, state) =>
            AppointmentDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
          path: AppRoutes.checkin,
          builder: (context, state) => const CheckinScreen()),
      GoRoute(
          path: AppRoutes.queue,
          builder: (context, state) => const QueueScreen()),

      // ── Results & prescriptions ──
      GoRoute(
        path: AppRoutes.resultDetail,
        builder: (context, state) =>
            ResultDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.prescription,
        builder: (context, state) =>
            PrescriptionScreen(resultId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: AppRoutes.medicationReminders,
        builder: (context, state) => const MedicationRemindersScreen(),
      ),

      // ── Profile ──
      GoRoute(
          path: AppRoutes.personalInfo,
          builder: (context, state) => const PersonalInfoScreen()),
      GoRoute(
          path: AppRoutes.payments,
          builder: (context, state) => const PaymentsScreen()),
      GoRoute(
        path: AppRoutes.billDetail,
        builder: (context, state) =>
            BillDetailScreen(id: state.pathParameters['id']!),
      ),
      GoRoute(
          path: AppRoutes.immunization,
          builder: (context, state) => const ImmunizationScreen()),
      GoRoute(
          path: AppRoutes.healthMetrics,
          builder: (context, state) => const HealthMetricsScreen()),
      GoRoute(
          path: AppRoutes.security,
          builder: (context, state) => const SecurityScreen()),
      GoRoute(
        path: AppRoutes.consentManagement,
        builder: (context, state) => const ConsentManagementScreen(),
      ),
    ],
  );
});
