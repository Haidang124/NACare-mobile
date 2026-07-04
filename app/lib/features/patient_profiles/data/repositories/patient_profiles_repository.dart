import '../../../../core/network/result.dart';
import '../models/patient_profile.dart';

/// Interface decoupling the UI from the data source — presentation depends only on
/// this interface, unaware of (and indifferent to) the mock or real API behind it.
abstract class PatientProfilesRepository {
  Future<Result<List<PatientProfile>>> getProfiles();
  Future<Result<void>> addFamilyMember(
      {required String fullName, required int birthYear});
}
