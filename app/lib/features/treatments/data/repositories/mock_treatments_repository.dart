import '../../../../core/network/mock_config.dart';
import '../../../../core/network/result.dart';
import '../../../../core/utils/formatting.dart';
import '../models/treatment.dart';
import 'treatments_repository.dart';

/// Dữ liệu mẫu để demo màn lần điều trị khi chưa nối BE. Sinh vài lượt khám nằm trong
/// [year] yêu cầu để việc lọc theo năm/tháng hoạt động giống thật.
class MockTreatmentsRepository implements TreatmentsRepository {
  MockTreatmentsRepository(this._config);

  final MockConfig _config;

  @override
  Future<Result<List<Treatment>>> getTreatments({
    required String profileId,
    required int year,
    int? month,
  }) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    if (_config.forceEmpty) return const Result.success([]);

    final all = _sampleFor(year);
    final filtered = month == null
        ? all
        : all.where((t) => t.inTime?.month == month).toList();
    return Result.success(filtered);
  }

  List<Treatment> _sampleFor(int year) {
    Treatment make(int month, int day, String code, String icdCode,
        String icdName, String type, String dept, String reason) {
      final dt = DateTime(year, month, day, 8, 30);
      return Treatment(
        treatmentCode: code,
        date: vnDate(dt),
        inTime: dt,
        icdCode: icdCode,
        icdName: icdName,
        typeName: type,
        department: dept,
        reason: reason,
      );
    }

    return [
      make(9, 12, 'DT${year}0912', 'I10', 'Tăng huyết áp vô căn', 'Ngoại trú',
          'Khoa Nội tim mạch', 'Tái khám huyết áp'),
      make(6, 3, 'DT${year}0603', 'E11', 'Đái tháo đường type 2', 'Ngoại trú',
          'Khoa Nội tiết', 'Kiểm tra đường huyết định kỳ'),
      make(3, 20, 'DT${year}0320', 'J06', 'Viêm đường hô hấp trên', 'Ngoại trú',
          'Khoa Khám bệnh', 'Ho, sốt nhẹ'),
    ];
  }
}
