import 'package:flutter/material.dart';

import '../../../../core/network/mock_config.dart';
import '../../../../core/network/result.dart';
import '../models/patient_profile.dart';
import 'patient_profiles_repository.dart';

/// Mock data matching the sample profile set in the mockup (Nguyễn Văn An + family).
/// Will be replaced by a real HIS-API repository once the backend is ready — the
/// [PatientProfilesRepository] interface stays the same, so providers/screens need no changes.
class MockPatientProfilesRepository implements PatientProfilesRepository {
  MockPatientProfilesRepository(this._config);

  final MockConfig _config;

  final List<PatientProfile> _profiles = [
    const PatientProfile(
      id: 'p1',
      fullName: 'Nguyễn Văn An',
      initials: 'NA',
      relationship: 'Tôi',
      birthYear: 1958,
      avatarColor: Color(0xFF149A4B),
      patientCode: 'NA0018292',
      isSelf: true,
    ),
    const PatientProfile(
      id: 'p2',
      fullName: 'Trần Thị Hoa',
      initials: 'TH',
      relationship: 'Vợ',
      birthYear: 1962,
      avatarColor: Color(0xFFE5399B),
      patientCode: 'NA0018293',
    ),
    const PatientProfile(
      id: 'p3',
      fullName: 'Nguyễn Minh Khang',
      initials: 'MK',
      relationship: 'Cháu',
      birthYear: 2018,
      avatarColor: Color(0xFFB36A00),
      patientCode: 'NA0018294',
    ),
  ];

  @override
  Future<Result<List<PatientProfile>>> getProfiles() async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    if (_config.forceEmpty) return const Result.success([]);
    return Result.success(List.unmodifiable(_profiles));
  }

  @override
  Future<Result<void>> addFamilyMember(
      {required String fullName, required int birthYear}) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    _profiles.add(
      PatientProfile(
        id: 'p${_profiles.length + 1}',
        fullName: fullName,
        initials: fullName.trim().isEmpty
            ? '?'
            : fullName
                .trim()
                .split(RegExp(r'\s+'))
                .map((w) => w[0])
                .take(2)
                .join()
                .toUpperCase(),
        relationship: 'Người thân',
        birthYear: birthYear,
        avatarColor: const Color(0xFF0F7C3C),
        patientCode: 'NA00${18290 + _profiles.length}',
      ),
    );
    return const Result.success(null);
  }
}
