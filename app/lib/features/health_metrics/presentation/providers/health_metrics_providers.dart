import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/mock_config.dart';
import '../../../patient_profiles/presentation/providers/patient_profiles_providers.dart';
import '../../data/models/health_metric.dart';
import '../../data/repositories/health_metrics_repository.dart';
import '../../data/repositories/mock_health_metrics_repository.dart';

final healthMetricsRepositoryProvider =
    Provider<HealthMetricsRepository>((ref) {
  return MockHealthMetricsRepository(ref.watch(mockConfigProvider));
});

final metricsProvider =
    FutureProvider.autoDispose<List<MetricCard>>((ref) async {
  final profile = ref.watch(activeProfileProvider);
  return (await ref
          .watch(healthMetricsRepositoryProvider)
          .getMetrics(profile?.id ?? 'p1'))
      .dataOrThrow;
});

final bloodPressureTrendProvider =
    FutureProvider.autoDispose<List<BloodPressureSample>>((ref) async {
  final profile = ref.watch(activeProfileProvider);
  return (await ref
          .watch(healthMetricsRepositoryProvider)
          .getBloodPressureTrend(profile?.id ?? 'p1'))
      .dataOrThrow;
});
