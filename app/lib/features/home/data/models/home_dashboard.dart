/// Aggregated data bundle for the Home screen — mirrors a single dashboard endpoint the
/// real backend would return (so Home doesn't have to call 3-4 separate APIs).
class TodayAppointmentSummary {
  const TodayAppointmentSummary({
    required this.id,
    required this.timeLabel,
    required this.statusLabel,
    required this.title,
    required this.doctorAndRoom,
  });

  final String id;
  final String timeLabel;
  final String statusLabel;
  final String title;
  final String doctorAndRoom;
}

class MedicationReminderSummary {
  const MedicationReminderSummary(
      {required this.title,
      required this.subtitle,
      required this.remainingCount});
  final String title;
  final String subtitle;
  final int remainingCount;
}

class NewResultSummary {
  const NewResultSummary(
      {required this.id, required this.title, required this.subtitle});
  final String id;
  final String title;
  final String subtitle;
}

class HomeDashboard {
  const HomeDashboard({this.todayAppointment, this.reminder, this.newResult});

  final TodayAppointmentSummary? todayAppointment;
  final MedicationReminderSummary? reminder;
  final NewResultSummary? newResult;
}
