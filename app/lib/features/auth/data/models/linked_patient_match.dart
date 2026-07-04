import 'package:flutter/foundation.dart';

/// A profile found in the HIS by phone number during OTP verification — the data is
/// masked because the patient hasn't yet confirmed this is them (Flow A, step 3).
@immutable
class LinkedPatientMatch {
  const LinkedPatientMatch({
    required this.maskedName,
    required this.patientCode,
    required this.maskedBirthYear,
    required this.gender,
    required this.lastVisit,
    required this.initials,
  });

  final String maskedName;
  final String patientCode;
  final String maskedBirthYear;
  final String gender;
  final String lastVisit;
  final String initials;
}
