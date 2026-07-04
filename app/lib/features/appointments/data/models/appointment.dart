import '../../../../core/widgets/badges/status_badge.dart';

enum AppointmentStatus { today, upcoming, completed, cancelled }

extension AppointmentStatusX on AppointmentStatus {
  String get label => switch (this) {
        AppointmentStatus.today => 'HÔM NAY',
        AppointmentStatus.upcoming => 'SẮP TỚI',
        AppointmentStatus.completed => 'ĐÃ KHÁM',
        AppointmentStatus.cancelled => 'ĐÃ HỦY',
      };

  StatusTone get tone => switch (this) {
        AppointmentStatus.today => StatusTone.success,
        AppointmentStatus.upcoming => StatusTone.warning,
        AppointmentStatus.completed => StatusTone.neutral,
        AppointmentStatus.cancelled => StatusTone.error,
      };
}

class Appointment {
  const Appointment({
    required this.id,
    required this.code,
    required this.status,
    required this.title,
    required this.doctorName,
    required this.room,
    required this.whenLabel,
    required this.feeVnd,
    this.isPast = false,
  });

  final String id;
  final String code;
  final AppointmentStatus status;
  final String title;
  final String doctorName;
  final String room;
  final String whenLabel;
  final int feeVnd;
  final bool isPast;

  String get doctorAndRoom => '$doctorName · $room';
}
