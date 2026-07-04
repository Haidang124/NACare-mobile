import '../../../../core/network/mock_config.dart';
import '../../../../core/network/result.dart';
import '../models/personal_info.dart';
import 'personal_info_repository.dart';

class MockPersonalInfoRepository implements PersonalInfoRepository {
  MockPersonalInfoRepository(this._config);

  final MockConfig _config;

  @override
  Future<Result<PersonalInfo>> getPersonalInfo(String profileId) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    return const Result.success(
      PersonalInfo(
        // Order & values match the mockup.
        adminItems: [
          AdminInfoItem(label: 'Họ và tên', value: 'Nguyễn Văn An'),
          AdminInfoItem(label: 'Ngày sinh', value: '12/05/1958'),
          AdminInfoItem(label: 'Giới tính', value: 'Nam'),
          AdminInfoItem(label: 'CCCD', value: '040058******'),
          AdminInfoItem(label: 'Số điện thoại', value: '090 123 4567'),
        ],
        insurance: InsuranceCard(
          number: 'DN 4 40 0182 9203',
          registeredHospital: 'BV Hữu Nghị ĐK Nghệ An',
          validUntil: '31/12/2026',
          isValid: true,
        ),
        medical: MedicalBackground(
          allergies: ['Penicillin'],
          chronicConditions: 'Tăng huyết áp, rối loạn đường huyết',
          bloodType: 'O+',
        ),
      ),
    );
  }
}
