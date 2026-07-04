class MetricCard {
  const MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.trend,
    required this.trendPositive,
  });

  final String icon;
  final String label;
  final String value;
  final String unit;
  final String trend;
  final bool trendPositive;
}

/// One bar in the 7-day blood-pressure chart — [heightFraction] 0..1 sets the bar height.
class BloodPressureSample {
  const BloodPressureSample(
      {required this.day, required this.heightFraction, required this.isHigh});
  final String day;
  final double heightFraction;
  final bool isHigh;
}
