import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/mock_config.dart';
import '../../data/models/patient_profile.dart';
import '../../data/repositories/mock_patient_profiles_repository.dart';
import '../../data/repositories/patient_profiles_repository.dart';

/// The single join point between the UI and the data layer: switching to the real API
/// later only requires editing this provider (return `ApiPatientProfilesRepository(...)`
/// instead of the mock), with no widget changes.
final patientProfilesRepositoryProvider =
    Provider<PatientProfilesRepository>((ref) {
  return MockPatientProfilesRepository(ref.watch(mockConfigProvider));
});

final patientProfilesProvider =
    FutureProvider<List<PatientProfile>>((ref) async {
  final repo = ref.watch(patientProfilesRepositoryProvider);
  return (await repo.getProfiles()).dataOrThrow;
});

/// The currently selected profile for viewing data (Home/Appointments/Results follow this profile).
final activeProfileIdProvider = StateProvider<String?>((ref) => null);

final activeProfileProvider = Provider<PatientProfile?>((ref) {
  final profiles = ref.watch(patientProfilesProvider).valueOrNull;
  if (profiles == null || profiles.isEmpty) return null;
  final activeId = ref.watch(activeProfileIdProvider);
  return profiles.firstWhere(
    (p) => p.id == activeId,
    orElse: () => profiles.first,
  );
});
