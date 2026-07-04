import '../../../../core/network/result.dart';
import '../models/security_settings.dart';

abstract class SecurityRepository {
  Future<Result<List<SecurityToggle>>> getToggles();
  Future<Result<void>> setToggle(String id, bool enabled);

  Future<Result<List<LoggedInDevice>>> getDevices();
  Future<Result<void>> logoutDevice(String id);

  Future<Result<List<ConsentItem>>> getConsentItems();
  Future<Result<void>> setConsent(String id, bool enabled);
  Future<Result<void>> requestDataDeletion();
}
