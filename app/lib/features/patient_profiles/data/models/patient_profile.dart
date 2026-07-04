import 'package:flutter/material.dart';

/// A patient profile (self or a family member) — used on every screen with a profile
/// switcher: Home, Appointments, Results, booking step 1, and the Profile tab.
@immutable
class PatientProfile {
  const PatientProfile({
    required this.id,
    required this.fullName,
    required this.initials,
    required this.relationship,
    required this.birthYear,
    required this.avatarColor,
    required this.patientCode,
    this.isSelf = false,
    this.insuranceValid = true,
  });

  final String id;
  final String fullName;
  final String initials;

  /// "Me", "Wife", "Grandchild"... — shown next to the name in the profile switcher.
  final String relationship;
  final int birthYear;
  final Color avatarColor;
  final String patientCode;
  final bool isSelf;
  final bool insuranceValid;
}
