import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/mock_config.dart';
import '../../data/models/appointment.dart';
import '../../data/models/specialty.dart';
import '../../data/repositories/appointments_repository.dart';
import '../../data/repositories/mock_appointments_repository.dart';

final appointmentsRepositoryProvider = Provider<AppointmentsRepository>((ref) {
  return MockAppointmentsRepository(ref.watch(mockConfigProvider));
});

final upcomingAppointmentsProvider =
    FutureProvider.autoDispose<List<Appointment>>((ref) async {
  return (await ref
          .watch(appointmentsRepositoryProvider)
          .getAppointments(upcoming: true))
      .dataOrThrow;
});

final pastAppointmentsProvider =
    FutureProvider.autoDispose<List<Appointment>>((ref) async {
  return (await ref
          .watch(appointmentsRepositoryProvider)
          .getAppointments(upcoming: false))
      .dataOrThrow;
});

final appointmentDetailProvider =
    FutureProvider.autoDispose.family<Appointment, String>((ref, id) async {
  return (await ref
          .watch(appointmentsRepositoryProvider)
          .getAppointmentDetail(id))
      .dataOrThrow;
});

final specialtiesProvider =
    FutureProvider.autoDispose<List<Specialty>>((ref) async {
  return (await ref.watch(appointmentsRepositoryProvider).getSpecialties())
      .dataOrThrow;
});

final doctorsProvider = FutureProvider.autoDispose
    .family<List<Doctor>, String>((ref, specialtyId) async {
  return (await ref
          .watch(appointmentsRepositoryProvider)
          .getDoctors(specialtyId))
      .dataOrThrow;
});

final bookingDatesProvider =
    FutureProvider.autoDispose<List<BookingDateOption>>((ref) async {
  return (await ref.watch(appointmentsRepositoryProvider).getAvailableDates())
      .dataOrThrow;
});

final bookingTimesProvider = FutureProvider.autoDispose
    .family<List<BookingTimeOption>, BookingDateOption>(
  (ref, date) async {
    return (await ref
            .watch(appointmentsRepositoryProvider)
            .getAvailableTimes(date))
        .dataOrThrow;
  },
);
