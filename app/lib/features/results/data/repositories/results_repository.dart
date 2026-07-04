import '../../../../core/network/result.dart';
import '../models/exam_result.dart';

abstract class ResultsRepository {
  Future<Result<List<ExamResultSummary>>> getResults();
  Future<Result<ExamResultDetail>> getResultDetail(String id);
}
