import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../appointments/data/models/queue_status.dart';
import '../providers/checkin_providers.dart';

class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueAsync = ref.watch(queueStatusProvider);

    return Scaffold(
      appBar: AppTopBar(
        title: 'Hàng chờ của tôi',
        onBack: () => context.go(AppRoutes.home),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
          decoration: BoxDecoration(
              color: AppColors.greenTint,
              borderRadius: BorderRadius.circular(6)),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PulsingDot(),
              SizedBox(width: 5),
              Text('Trực tiếp',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primaryDark)),
            ],
          ),
        ),
      ),
      body: AsyncValueView<QueueStatus>(
        value: queueAsync,
        onRetry: () => ref.invalidate(queueStatusProvider),
        data: (context, queue) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.heroCardGradient,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
                ),
                child: Column(
                  children: [
                    Text(
                      'SỐ CỦA BẠN',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withValues(alpha: 0.85),
                          letterSpacing: 1),
                    ),
                    Text('${queue.myNumber}', style: AppTypography.numberHero),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _QueueStat(
                            label: 'Đang gọi',
                            value: '${queue.currentlyServing}'),
                        Container(
                            width: 1,
                            height: 30,
                            color: Colors.white.withValues(alpha: 0.25)),
                        _QueueStat(label: 'Phòng', value: queue.room),
                        Container(
                            width: 1,
                            height: 30,
                            color: Colors.white.withValues(alpha: 0.25)),
                        _QueueStat(
                            label: 'Chờ ~',
                            value: '${queue.estimatedWaitMinutes}′'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                decoration: BoxDecoration(
                  color: AppColors.accentTint,
                  border: Border.all(color: AppColors.accentBorder),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Text(
                  '🔔 Bạn sẽ nhận thông báo khi còn cách 3 số. Có thể ngồi chờ tại sảnh tầng 3.',
                  style: AppTypography.caption.copyWith(
                      fontSize: 14.5, color: AppColors.accentText, height: 1.5),
                ),
              ),
              const SizedBox(height: 20),
              Text('Hành trình khám hôm nay',
                  style: AppTypography.bodyBold.copyWith(fontSize: 16)),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  children: List.generate(queue.journey.length, (i) {
                    final step = queue.journey[i];
                    final isLast = i == queue.journey.length - 1;
                    return _JourneyRow(step: step, showLine: !isLast);
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QueueStat extends StatelessWidget {
  const _QueueStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 12.5, color: Colors.white.withValues(alpha: 0.8))),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white)),
      ],
    );
  }
}

class _PulsingDot extends StatefulWidget {
  const _PulsingDot();

  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.4, end: 1.0).animate(_controller),
      child: const SizedBox(
        width: 7,
        height: 7,
        child: DecoratedBox(
            decoration: BoxDecoration(
                color: AppColors.primary, shape: BoxShape.circle)),
      ),
    );
  }
}

class _JourneyRow extends StatelessWidget {
  const _JourneyRow({required this.step, required this.showLine});
  final JourneyStep step;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    final (dotBg, dotBorder, dotFg, titleColor, mark) = switch (step.state) {
      JourneyStepState.done => (
          AppColors.primary,
          AppColors.primary,
          Colors.white,
          AppColors.textPrimary,
          '✓'
        ),
      JourneyStepState.current => (
          Colors.white,
          AppColors.primary,
          AppColors.primaryDark,
          AppColors.primaryDark,
          null
        ),
      JourneyStepState.upcoming => (
          Colors.white,
          AppColors.borderMedium,
          AppColors.textMuted,
          AppColors.textTertiary,
          null
        ),
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: dotBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: dotBorder, width: 2)),
                child: mark != null
                    ? Text(mark,
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: dotFg))
                    : Icon(Icons.circle, size: 8, color: dotFg),
              ),
              if (showLine)
                Expanded(
                    child: Container(width: 2, color: AppColors.timelineLine)),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(step.title,
                      style: TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: titleColor)),
                  const SizedBox(height: 2),
                  Text(step.subtitle,
                      style: AppTypography.caption.copyWith(fontSize: 13.5)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
