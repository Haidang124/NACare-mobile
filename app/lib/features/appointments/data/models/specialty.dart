class Specialty {
  const Specialty(
      {required this.id,
      required this.name,
      required this.note,
      required this.emoji});
  final String id;
  final String name;
  final String note;
  final String emoji;
}

class Doctor {
  const Doctor(
      {required this.id,
      required this.name,
      required this.subtitle,
      this.isAnyDoctor = false});
  final String id;
  final String name;
  final String subtitle;

  /// "Skip — let the hospital assign".
  final bool isAnyDoctor;
}

class BookingDateOption {
  const BookingDateOption(
      {required this.date,
      required this.dayOfWeek,
      required this.dayNumber,
      this.isOff = false});
  final DateTime date;
  final String dayOfWeek;
  final String dayNumber;
  final bool isOff;
}

class BookingTimeOption {
  const BookingTimeOption({required this.label, this.isOff = false});
  final String label;
  final bool isOff;
}
