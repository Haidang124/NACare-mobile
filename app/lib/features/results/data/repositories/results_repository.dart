import '../../../../core/network/result.dart';
import '../models/exam_result.dart';

/// Chi tiết một kết quả khám (deep-link cũ từ home/lịch hẹn). Danh sách kết quả nay đi
/// theo lần điều trị (feature treatments) nên `getResults` đã gỡ.
abstract class ResultsRepository {
  Future<Result<ExamResultDetail>> getResultDetail(String id);
}
