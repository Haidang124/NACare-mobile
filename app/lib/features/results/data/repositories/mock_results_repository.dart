import '../../../../core/network/mock_config.dart';
import '../../../../core/network/result.dart';
import '../models/exam_result.dart';
import 'results_repository.dart';

class MockResultsRepository implements ResultsRepository {
  MockResultsRepository(this._config);

  final MockConfig _config;

  static const _summaries = [
    ExamResultSummary(
      id: 'r1',
      date: '28/06/2026',
      isNew: true,
      title: 'Khám Nội tổng quát',
      doctor: 'ThS.BS Lê Hồng Nhung',
      tags: ['Xét nghiệm máu', 'Đơn thuốc'],
    ),
    ExamResultSummary(
      id: 'r2',
      date: '15/03/2026',
      isNew: false,
      title: 'Khám Tim mạch',
      doctor: 'BS.CKI Trần Minh Đức',
      tags: ['Điện tim', 'Siêu âm tim'],
    ),
    ExamResultSummary(
      id: 'r3',
      date: '02/12/2025',
      isNew: false,
      title: 'Khám sức khỏe định kỳ',
      doctor: 'Khoa Khám bệnh',
      tags: ['Tổng quát', 'X-quang'],
    ),
  ];

  static const _detail = ExamResultDetail(
    id: 'r1',
    title: 'Khám Nội tổng quát',
    date: '28/06/2026',
    doctor: 'BS. Lê Hồng Nhung',
    diagnosis: 'Tăng huyết áp độ I — theo dõi đường huyết',
    advice:
        'Hạn chế muối, tập thể dục nhẹ 30 phút/ngày. Uống thuốc đều theo đơn, tái khám sau 4 tuần.',
    labs: [
      LabValue(
          name: 'Glucose (đói)',
          value: '6.8',
          unit: 'mmol/L',
          reference: '3.9 – 5.6',
          outOfRange: true),
      LabValue(
          name: 'Cholesterol toàn phần',
          value: '5.9',
          unit: 'mmol/L',
          reference: '< 5.2',
          outOfRange: true),
      LabValue(
          name: 'Hồng cầu (RBC)',
          value: '4.7',
          unit: 'T/L',
          reference: '4.2 – 5.9',
          outOfRange: false),
      LabValue(
          name: 'Bạch cầu (WBC)',
          value: '7.2',
          unit: 'G/L',
          reference: '4.0 – 10.0',
          outOfRange: false),
      LabValue(
          name: 'Creatinine',
          value: '88',
          unit: 'µmol/L',
          reference: '62 – 106',
          outOfRange: false),
    ],
    attachmentName: 'KetQua_XetNghiem_28-06.pdf',
    attachmentSize: '248 KB',
  );

  @override
  Future<Result<List<ExamResultSummary>>> getResults() async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    if (_config.forceEmpty) return const Result.success([]);
    return const Result.success(_summaries);
  }

  @override
  Future<Result<ExamResultDetail>> getResultDetail(String id) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    // Mock: every id returns the same sample detail data.
    return const Result.success(_detail);
  }
}
