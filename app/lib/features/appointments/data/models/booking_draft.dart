import 'specialty.dart';

/// Data accumulated across the 5 booking steps (Flow B — ui-ux-app-benh-nhan.md).
class BookingDraft {
  const BookingDraft({
    this.profileId,
    this.profileName,
    this.specialty,
    this.doctor,
    this.date,
    this.time,
    this.reason = '',
  });

  final String? profileId;
  final String? profileName;
  final Specialty? specialty;
  final Doctor? doctor;
  final BookingDateOption? date;
  final BookingTimeOption? time;
  final String reason;

  bool get hasProfile => profileId != null;
  bool get hasSpecialty => specialty != null;
  bool get hasDateTime => date != null && time != null;

  BookingDraft copyWith({
    String? profileId,
    String? profileName,
    Specialty? specialty,
    Doctor? doctor,
    BookingDateOption? date,
    BookingTimeOption? time,
    String? reason,
    bool clearTime = false,
  }) {
    return BookingDraft(
      profileId: profileId ?? this.profileId,
      profileName: profileName ?? this.profileName,
      specialty: specialty ?? this.specialty,
      doctor: doctor ?? this.doctor,
      date: date ?? this.date,
      time: clearTime ? null : (time ?? this.time),
      reason: reason ?? this.reason,
    );
  }
}

class BookingConfirmation {
  const BookingConfirmation({required this.code, required this.whenLabel});
  final String code;
  final String whenLabel;
}
