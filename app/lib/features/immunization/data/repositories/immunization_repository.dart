import '../../../../core/network/result.dart';
import '../models/vaccine_record.dart';

abstract class ImmunizationRepository {
  Future<Result<ImmunizationRecord>> getRecord(String profileId);
}
