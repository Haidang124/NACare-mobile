import '../../../../core/network/result.dart';
import '../models/appointment.dart';
import '../models/booking_draft.dart';
import '../models/specialty.dart';

abstract class AppointmentsRepository {
  Future<Result<List<Appointment>>> getAppointments({required bool upcoming});
  Future<Result<Appointment>> getAppointmentDetail(String id);
  Future<Result<void>> cancelAppointment(String id);

  Future<Result<List<Specialty>>> getSpecialties();
  Future<Result<List<Doctor>>> getDoctors(String specialtyId);
  Future<Result<List<BookingDateOption>>> getAvailableDates();
  Future<Result<List<BookingTimeOption>>> getAvailableTimes(
      BookingDateOption date);
  Future<Result<BookingConfirmation>> submitBooking(BookingDraft draft);
}
