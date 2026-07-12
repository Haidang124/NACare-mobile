class Medication {
  const Medication({
    required this.name,
    required this.strength,
    required this.days,
    required this.times,
    required this.note,
  });

  final String name;
  final String strength;
  final String days;
  final List<String> times;
  final String note;
}

class Prescription {
  const Prescription(
      {required this.examDate,
      required this.durationDays,
      required this.medications});
  final String examDate;
  final int durationDays;
  final List<Medication> medications;
}

class MedicationDose {
  const MedicationDose({
    required this.id,
    required this.time,
    required this.name,
    required this.note,
    required this.taken,
  });

  final String id;
  final String time;
  final String name;
  final String note;
  final bool taken;

  MedicationDose copyWith({bool? taken}) {
    return MedicationDose(
      id: id,
      time: time,
      name: name,
      note: note,
      taken: taken ?? this.taken,
    );
  }
}
