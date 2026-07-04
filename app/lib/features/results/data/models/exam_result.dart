class ExamResultSummary {
  const ExamResultSummary({
    required this.id,
    required this.date,
    required this.isNew,
    required this.title,
    required this.doctor,
    required this.tags,
  });

  final String id;
  final String date;
  final bool isNew;
  final String title;
  final String doctor;
  final List<String> tags;
}

class LabValue {
  const LabValue({
    required this.name,
    required this.value,
    required this.unit,
    required this.reference,
    required this.outOfRange,
  });

  final String name;
  final String value;
  final String unit;
  final String reference;
  final bool outOfRange;
}

class ExamResultDetail {
  const ExamResultDetail({
    required this.id,
    required this.title,
    required this.date,
    required this.doctor,
    required this.diagnosis,
    required this.advice,
    required this.labs,
    required this.attachmentName,
    required this.attachmentSize,
  });

  final String id;
  final String title;
  final String date;
  final String doctor;
  final String diagnosis;
  final String advice;
  final List<LabValue> labs;
  final String attachmentName;
  final String attachmentSize;
}
