import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/config_providers.dart';
import '../../../../core/network/api_providers.dart';
import '../../../../core/network/mock_config.dart';
import '../../data/models/exam_result.dart';
import '../../data/repositories/api_results_repository.dart';
import '../../data/repositories/mock_results_repository.dart';
import '../../data/repositories/results_repository.dart';

final resultsRepositoryProvider = Provider<ResultsRepository>((ref) {
  if (ref.watch(useMockProvider)) {
    return MockResultsRepository(ref.watch(mockConfigProvider));
  }
  return ApiResultsRepository(ref.watch(dioProvider));
});

// Danh sách "kết quả khám" giờ hiển thị theo lần điều trị thật (feature treatments) —
// xem `ResultsTabScreen`. `examResultsProvider`/`getResults` (gọi `/patient/results`
// không có trên BE) đã gỡ. Chi tiết ExamResult vẫn dùng cho deep-link cũ (home/lịch hẹn).
final examResultDetailProvider = FutureProvider.autoDispose
    .family<ExamResultDetail, String>((ref, id) async {
  return (await ref.watch(resultsRepositoryProvider).getResultDetail(id))
      .dataOrThrow;
});
