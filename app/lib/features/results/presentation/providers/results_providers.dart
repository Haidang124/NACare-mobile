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

final examResultsProvider =
    FutureProvider.autoDispose<List<ExamResultSummary>>((ref) async {
  return (await ref.watch(resultsRepositoryProvider).getResults()).dataOrThrow;
});

final examResultDetailProvider = FutureProvider.autoDispose
    .family<ExamResultDetail, String>((ref, id) async {
  return (await ref.watch(resultsRepositoryProvider).getResultDetail(id))
      .dataOrThrow;
});
