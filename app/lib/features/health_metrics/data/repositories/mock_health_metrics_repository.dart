import '../../../../core/network/mock_config.dart';
import '../../../../core/network/result.dart';
import '../models/health_metric.dart';
import 'health_metrics_repository.dart';

class MockHealthMetricsRepository implements HealthMetricsRepository {
  MockHealthMetricsRepository(this._config);

  final MockConfig _config;

  @override
  Future<Result<List<MetricCard>>> getMetrics(String profileId) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    // Matches the mockup: BP 138/86 (slightly high), BG 6.2 (monitor), weight 68 (stable), HR 74 (normal).
    return const Result.success([
      MetricCard(
          icon: '🩸',
          label: 'Huyết áp',
          value: '138/86',
          unit: 'mmHg',
          trend: '▲ Hơi cao',
          trendPositive: false),
      MetricCard(
          icon: '🍬',
          label: 'Đường huyết',
          value: '6.2',
          unit: 'mmol/L',
          trend: '▲ Theo dõi',
          trendPositive: false),
      MetricCard(
          icon: '⚖️',
          label: 'Cân nặng',
          value: '68',
          unit: 'kg',
          trend: '▬ Ổn định',
          trendPositive: true),
      MetricCard(
          icon: '❤️',
          label: 'Nhịp tim',
          value: '74',
          unit: 'bpm',
          trend: '▬ Bình thường',
          trendPositive: true),
    ]);
  }

  @override
  Future<Result<List<BloodPressureSample>>> getBloodPressureTrend(
      String profileId) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    // Matches the mockup: Thu (0.80) and Sun (0.85) are high-BP days (pink bars).
    const days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    const heights = [0.62, 0.70, 0.55, 0.80, 0.68, 0.75, 0.85];
    const highDays = {'T5', 'CN'};
    return Result.success(List.generate(
      days.length,
      (i) => BloodPressureSample(
          day: days[i],
          heightFraction: heights[i],
          isHigh: highDays.contains(days[i])),
    ));
  }
}
