import '../../../../core/network/mock_config.dart';
import '../../../../core/network/result.dart';
import '../models/appointment.dart';
import '../models/booking_draft.dart';
import '../models/specialty.dart';
import 'appointments_repository.dart';

class MockAppointmentsRepository implements AppointmentsRepository {
  MockAppointmentsRepository(this._config);

  final MockConfig _config;

  final List<Appointment> _upcoming = const [
    Appointment(
      id: 'a1',
      code: 'LH-260703-089',
      status: AppointmentStatus.today,
      title: 'Khám Tim mạch',
      doctorName: 'BS.CKI Trần Minh Đức',
      room: 'Phòng 305, Tầng 3',
      whenLabel: 'Hôm nay, 09:30',
      feeVnd: 150000,
    ),
    Appointment(
      id: 'a2',
      code: 'LH-260712-031',
      status: AppointmentStatus.upcoming,
      title: 'Tái khám Nội tổng quát',
      doctorName: 'ThS.BS Lê Hồng Nhung',
      room: 'Phòng 210',
      whenLabel: 'CN, 12/07 · 08:00',
      feeVnd: 100000,
    ),
  ];

  final List<Appointment> _past = const [
    Appointment(
      id: 'a3',
      code: 'LH-260628-102',
      status: AppointmentStatus.completed,
      title: 'Khám Nội tổng quát',
      doctorName: 'ThS.BS Lê Hồng Nhung',
      room: 'Phòng 210',
      whenLabel: '28/06 · 08:30',
      feeVnd: 100000,
      isPast: true,
    ),
    Appointment(
      id: 'a4',
      code: 'LH-260610-047',
      status: AppointmentStatus.cancelled,
      title: 'Khám Da liễu',
      doctorName: 'BS. Phạm Thu Trang',
      room: 'Phòng 118',
      whenLabel: '10/06 · 14:00',
      feeVnd: 0,
      isPast: true,
    ),
  ];

  static const _specialties = [
    Specialty(
        id: 'noi',
        name: 'Nội tổng quát',
        note: 'Khám sức khỏe chung',
        emoji: '🩺'),
    Specialty(id: 'tim', name: 'Tim mạch', note: 'Huyết áp, tim', emoji: '🫀'),
    Specialty(
        id: 'tmh',
        name: 'Tai Mũi Họng',
        note: 'TMH người lớn & trẻ em',
        emoji: '👂'),
    Specialty(
        id: 'nhi', name: 'Nhi khoa', note: 'Trẻ dưới 16 tuổi', emoji: '🧒'),
    Specialty(id: 'da', name: 'Da liễu', note: 'Da, tóc, móng', emoji: '🧴'),
    Specialty(
        id: 'coxuongkhop',
        name: 'Cơ Xương Khớp',
        note: 'Xương khớp, cột sống',
        emoji: '🦴'),
    Specialty(id: 'mat', name: 'Mắt', note: 'Khúc xạ, đáy mắt', emoji: '👁'),
    Specialty(
        id: 'rhm',
        name: 'Răng Hàm Mặt',
        note: 'Nha khoa tổng quát',
        emoji: '🦷'),
  ];

  static const _doctors = [
    Doctor(
        id: 'd1',
        name: 'BS.CKI Trần Minh Đức',
        subtitle: '12 năm kinh nghiệm · Khám: T2–T6'),
    Doctor(
        id: 'd2',
        name: 'ThS.BS Lê Hồng Nhung',
        subtitle: '9 năm kinh nghiệm · Khám: T3–T7'),
    Doctor(
        id: 'd3',
        name: 'Bỏ qua — bệnh viện sắp xếp',
        subtitle: 'Gặp bác sĩ trực khoa trong ca',
        isAnyDoctor: true),
  ];

  @override
  Future<Result<List<Appointment>>> getAppointments(
      {required bool upcoming}) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    if (_config.forceEmpty) return const Result.success([]);
    return Result.success(upcoming ? _upcoming : _past);
  }

  @override
  Future<Result<Appointment>> getAppointmentDetail(String id) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    final all = [..._upcoming, ..._past];
    final found = all.where((a) => a.id == id);
    if (found.isEmpty) return Result.failure(AppFailure.notFound());
    return Result.success(found.first);
  }

  @override
  Future<Result<void>> cancelAppointment(String id) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    return const Result.success(null);
  }

  @override
  Future<Result<List<Specialty>>> getSpecialties() async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    return const Result.success(_specialties);
  }

  @override
  Future<Result<List<Doctor>>> getDoctors(String specialtyId) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    return const Result.success(_doctors);
  }

  @override
  Future<Result<List<BookingDateOption>>> getAvailableDates({
    required String specialtyId,
    String? doctorId,
  }) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    final today = DateTime.now();
    const dows = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final offIndexes = {1, 5, 6};
    final options = List.generate(7, (i) {
      final date = today.add(Duration(days: i));
      return BookingDateOption(
        date: date,
        dayOfWeek: dows[date.weekday - 1],
        dayNumber: date.day.toString(),
        isOff: offIndexes.contains(i),
      );
    });
    return Result.success(options);
  }

  @override
  Future<Result<List<BookingTimeOption>>> getAvailableTimes(
    BookingDateOption date, {
    required String specialtyId,
    String? doctorId,
  }) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    const labels = [
      '07:30',
      '08:00',
      '08:30',
      '09:00',
      '09:30',
      '10:00',
      '14:00',
      '14:30',
      '15:00'
    ];
    const offIndexes = {1, 4};
    final options = List.generate(
      labels.length,
      (i) => BookingTimeOption(label: labels[i], isOff: offIndexes.contains(i)),
    );
    return Result.success(options);
  }

  @override
  Future<Result<BookingConfirmation>> submitBooking(BookingDraft draft) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    final code =
        'LH-${DateTime.now().toIso8601String().substring(2, 10).replaceAll('-', '')}-'
        '${100 + _upcoming.length}';
    final when = draft.date != null && draft.time != null
        ? '${draft.date!.dayOfWeek}, ${draft.date!.dayNumber} · ${draft.time!.label}'
        : '';
    return Result.success(BookingConfirmation(code: code, whenLabel: when));
  }
}
