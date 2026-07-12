import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/result.dart';
import '../../../../core/utils/formatting.dart';
import '../models/appointment.dart';
import '../models/booking_draft.dart';
import '../models/specialty.dart';
import 'appointments_repository.dart';

/// Bản thật của [AppointmentsRepository] — module Appointments của BE.
///   GET  /patient/appointments?upcoming=bool   → danh sách (sắp tới / lịch sử)
///   GET  /patient/appointments/{id}            → chi tiết
///   POST /patient/appointments/{id}/cancel     → huỷ
///
/// BE trả `AppointmentDto(id, examAtUtc, specialtyName, doctorName?, location?, reason?, status)`.
class ApiAppointmentsRepository implements AppointmentsRepository {
  ApiAppointmentsRepository(this._dio);

  final Dio _dio;

  @override
  Future<Result<List<Appointment>>> getAppointments({required bool upcoming}) =>
      apiCall(
        () => _dio.get('/patient/appointments',
            queryParameters: {'upcoming': upcoming}),
        (json) => (json as List)
            .map((e) => _map((e as Map).cast<String, dynamic>()))
            .toList(),
      );

  @override
  Future<Result<Appointment>> getAppointmentDetail(String id) => apiCall(
        () => _dio.get('/patient/appointments/$id'),
        (json) => _map((json as Map).cast<String, dynamic>()),
      );

  @override
  Future<Result<void>> cancelAppointment(String id) => apiCallVoid(
        () => _dio.post('/patient/appointments/$id/cancel'),
      );

  @override
  Future<Result<List<Specialty>>> getSpecialties() => apiCall(
        () => _dio.get('/public/specialties'),
        (json) => (json as List)
            .map((e) => _mapSpecialty((e as Map).cast<String, dynamic>()))
            .toList(),
      );

  @override
  Future<Result<List<Doctor>>> getDoctors(String specialtyId) => apiCall(
        () => _dio.get('/public/specialties/$specialtyId/doctors'),
        (json) => (json as List)
            .map((e) => _mapDoctor((e as Map).cast<String, dynamic>()))
            .toList(),
      );

  @override
  Future<Result<List<BookingDateOption>>> getAvailableDates({
    required String specialtyId,
    String? doctorId,
  }) =>
      apiCall(
        () => _dio.get(
          '/patient/booking/dates',
          queryParameters: {
            'specialtyId': specialtyId,
            if (doctorId != null && doctorId.isNotEmpty) 'doctorId': doctorId,
          },
        ),
        (json) => (json as List)
            .map((e) => _mapDateOption(e.toString()))
            .toList(),
      );

  @override
  Future<Result<List<BookingTimeOption>>> getAvailableTimes(
    BookingDateOption date, {
    required String specialtyId,
    String? doctorId,
  }) =>
      apiCall(
        () => _dio.get(
          '/patient/booking/times',
          queryParameters: {
            'specialtyId': specialtyId,
            'date': DateFormat('yyyy-MM-dd').format(date.date),
            if (doctorId != null && doctorId.isNotEmpty) 'doctorId': doctorId,
          },
        ),
        (json) => (json as List)
            .map((e) => _mapTimeOption((e as Map).cast<String, dynamic>()))
            .toList(),
      );

  @override
  Future<Result<BookingConfirmation>> submitBooking(BookingDraft draft) =>
      apiCall(
        () => _dio.post(
          '/patient/appointments',
          data: {
            'specialtyId': draft.specialty?.id,
            'slotAtUtc': _slotAtUtc(draft).toIso8601String(),
            'profileId': draft.profileId,
            if (draft.doctor != null && !draft.doctor!.isAnyDoctor)
              'doctorId': draft.doctor!.id,
            if (draft.reason.trim().isNotEmpty) 'reason': draft.reason.trim(),
          },
          options: Options(headers: {'Idempotency-Key': _idempotencyKey()}),
        ),
        (json) {
          final appointment = _map((json as Map).cast<String, dynamic>());
          return BookingConfirmation(
            code: appointment.code,
            whenLabel: appointment.whenLabel,
          );
        },
      );

  Appointment _map(Map<String, dynamic> j) {
    final status = _mapStatus(j['status']);
    final id = j['id'].toString();
    return Appointment(
      id: id,
      code: id, // TODO: BE chưa có mã hiển thị riêng cho lịch hẹn.
      status: status,
      title: (j['specialtyName'] as String?) ?? '',
      doctorName: (j['doctorName'] as String?) ?? '',
      room: (j['location'] as String?) ?? '',
      whenLabel: vnWhenLabel(DateTime.parse(j['examAtUtc'] as String)),
      feeVnd: 0, // TODO: BE AppointmentDto chưa có phí khám.
      isPast: status == AppointmentStatus.completed ||
          status == AppointmentStatus.cancelled,
    );
  }

  Specialty _mapSpecialty(Map<String, dynamic> j) {
    final name = (j['name'] as String?) ?? '';
    return Specialty(
      id: j['id'].toString(),
      name: name,
      note: (j['description'] as String?) ?? '',
      emoji: _emojiForSpecialty(name),
    );
  }

  Doctor _mapDoctor(Map<String, dynamic> j) {
    final title = (j['title'] as String?) ?? '';
    return Doctor(
      id: j['id'].toString(),
      name: (j['fullName'] as String?) ?? '',
      subtitle: title,
    );
  }

  BookingDateOption _mapDateOption(String dateText) {
    final date = DateTime.parse(dateText);
    const dows = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return BookingDateOption(
      date: date,
      dayOfWeek: dows[date.weekday - 1],
      dayNumber: date.day.toString(),
    );
  }

  BookingTimeOption _mapTimeOption(Map<String, dynamic> j) {
    final startAt = DateTime.parse(j['startAtUtc'] as String).toLocal();
    return BookingTimeOption(label: DateFormat('HH:mm').format(startAt));
  }

  DateTime _slotAtUtc(BookingDraft draft) {
    final date = draft.date?.date;
    final label = draft.time?.label;
    if (date == null || label == null) {
      throw StateError('Booking draft is missing date/time.');
    }

    final parts = label.split(':');
    final local = DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
    return local.toUtc();
  }

  String _idempotencyKey() =>
      'mobile-${DateTime.now().microsecondsSinceEpoch}';

  String _emojiForSpecialty(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('tim')) return '🫀';
    if (lower.contains('tai') || lower.contains('mũi') || lower.contains('họng')) {
      return '👂';
    }
    if (lower.contains('nhi')) return '🧒';
    if (lower.contains('da')) return '🧴';
    if (lower.contains('xương') || lower.contains('khớp')) return '🦴';
    if (lower.contains('mắt')) return '👁';
    if (lower.contains('răng')) return '🦷';
    return '🩺';
  }
}

/// BE có thể trả enum status dạng số (0..3) hoặc chuỗi ("Upcoming"...) tuỳ cấu hình
/// JSON — xử lý cả hai để không vỡ khi đổi cấu hình.
AppointmentStatus _mapStatus(dynamic v) {
  if (v is int) {
    const order = [
      AppointmentStatus.upcoming,
      AppointmentStatus.today,
      AppointmentStatus.completed,
      AppointmentStatus.cancelled,
    ];
    return (v >= 0 && v < order.length) ? order[v] : AppointmentStatus.upcoming;
  }
  return switch (v?.toString().toLowerCase()) {
    'today' => AppointmentStatus.today,
    'completed' => AppointmentStatus.completed,
    'cancelled' => AppointmentStatus.cancelled,
    _ => AppointmentStatus.upcoming,
  };
}
