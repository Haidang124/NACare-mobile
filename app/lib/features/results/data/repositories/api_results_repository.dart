import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/result.dart';
import '../../../../core/utils/formatting.dart';
import '../models/exam_result.dart';
import 'results_repository.dart';

/// Bản thật của [ResultsRepository] — module Results của BE (đọc kết quả khám/LIS qua BE).
///   GET /patient/results        → danh sách kết quả
///   GET /patient/results/{id}   → chi tiết một kết quả
///
/// BE trả `ResultDto(id, resultDateUtc, title, doctorName?, summary?, measurements[])`.
class ApiResultsRepository implements ResultsRepository {
  ApiResultsRepository(this._dio);

  final Dio _dio;

  @override
  Future<Result<List<ExamResultSummary>>> getResults() => apiCall(
        () => _dio.get('/patient/results'),
        (json) => (json as List)
            .map((e) => _mapSummary((e as Map).cast<String, dynamic>()))
            .toList(),
      );

  @override
  Future<Result<ExamResultDetail>> getResultDetail(String id) => apiCall(
        () => _dio.get('/patient/results/$id'),
        (json) => _mapDetail((json as Map).cast<String, dynamic>()),
      );

  ExamResultSummary _mapSummary(Map<String, dynamic> j) {
    final dateUtc = DateTime.parse(j['resultDateUtc'] as String);
    return ExamResultSummary(
      id: j['id'].toString(),
      date: vnDate(dateUtc),
      // BE chưa có cờ "mới" → tạm coi là mới nếu trong 7 ngày.
      isNew: DateTime.now().difference(dateUtc.toLocal()).inDays < 7,
      title: (j['title'] as String?) ?? '',
      doctor: (j['doctorName'] as String?) ?? '',
      tags: const [], // TODO: BE chưa có tags (có thể suy từ measurements bất thường).
    );
  }

  ExamResultDetail _mapDetail(Map<String, dynamic> j) {
    final labs = ((j['measurements'] as List?) ?? const [])
        .map((e) => _mapLab((e as Map).cast<String, dynamic>()))
        .toList();
    return ExamResultDetail(
      id: j['id'].toString(),
      title: (j['title'] as String?) ?? '',
      date: vnDate(DateTime.parse(j['resultDateUtc'] as String)),
      doctor: (j['doctorName'] as String?) ?? '',
      diagnosis: (j['summary'] as String?) ?? '',
      advice: '', // TODO: BE ResultDto chưa có trường lời dặn.
      labs: labs,
      attachmentName: '', // TODO: BE chưa trả tệp đính kèm.
      attachmentSize: '',
    );
  }

  LabValue _mapLab(Map<String, dynamic> j) => LabValue(
        name: (j['name'] as String?) ?? '',
        value: (j['value'] as String?) ?? '',
        unit: (j['unit'] as String?) ?? '',
        reference: (j['referenceRange'] as String?) ?? '',
        outOfRange: (j['outOfRange'] as bool?) ?? false,
      );
}
