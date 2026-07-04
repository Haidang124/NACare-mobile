import '../../../../core/network/result.dart';
import '../models/personal_info.dart';

abstract class PersonalInfoRepository {
  Future<Result<PersonalInfo>> getPersonalInfo(String profileId);
}
