import '../../../../core/network/result.dart';
import '../models/health_metric.dart';

abstract class HealthMetricsRepository {
  Future<Result<List<MetricCard>>> getMetrics(String profileId);
  Future<Result<List<BloodPressureSample>>> getBloodPressureTrend(
      String profileId);
}
