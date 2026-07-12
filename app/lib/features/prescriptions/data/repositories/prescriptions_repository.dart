import '../../../../core/network/result.dart';
import '../models/prescription.dart';

abstract class PrescriptionsRepository {
  Future<Result<Prescription>> getPrescription(String resultId);
  Future<Result<List<MedicationDose>>> getTodayDoses();
  Future<Result<void>> markDoseTaken(String doseId, bool taken);
}
