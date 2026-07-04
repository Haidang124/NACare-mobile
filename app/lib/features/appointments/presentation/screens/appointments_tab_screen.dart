import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/appointment.dart';
import '../providers/appointments_providers.dart';

final _showUpcomingProvider = StateProvider.autoDispose<bool>((ref) => true);

class AppointmentsTabScreen extends ConsumerWidget {
  const AppointmentsTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showUpcoming = ref.watch(_showUpcomingProvider);
    final listAsync = ref.watch(
        showUpcoming ? upcomingAppointmentsProvider : pastAppointmentsProvider);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Lịch khám', style: AppTypography.tabTitle),
                  const Spacer(),
                  AppButton(
                    label: '+ Đặt lịch',
                    expanded: false,
                    height: 40,
                    onPressed: () => context.push(AppRoutes.bookAppointment),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.borderCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                        child: _SegmentButton(
                            label: 'Sắp tới',
                            selected: showUpcoming,
                            onTap: () => ref
                                .read(_showUpcomingProvider.notifier)
                                .state = true)),
                    Expanded(
                        child: _SegmentButton(
                            label: 'Đã qua',
                            selected: !showUpcoming,
                            onTap: () => ref
                                .read(_showUpcomingProvider.notifier)
                                .state = false)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: AsyncValueView<List<Appointment>>(
                  value: listAsync,
                  isEmpty: (data) => data.isEmpty,
                  onRetry: () => ref.invalidate(showUpcoming
                      ? upcomingAppointmentsProvider
                      : pastAppointmentsProvider),
                  emptyBuilder: (_) => EmptyStateView(
                    icon: Icons.event_busy_outlined,
                    title: showUpcoming
                        ? 'Chưa có lịch hẹn sắp tới'
                        : 'Chưa có lịch sử khám',
                    message: showUpcoming ? 'Đặt lịch khám để bắt đầu.' : null,
                    actionLabel: showUpcoming ? 'Đặt lịch khám' : null,
                    onAction: showUpcoming
                        ? () => context.push(AppRoutes.bookAppointment)
                        : null,
                  ),
                  data: (context, items) => ListView.separated(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) =>
                        _AppointmentCard(appointment: items[i]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton(
      {required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.primaryDark : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment});
  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () {
        if (appointment.isPast &&
            appointment.status == AppointmentStatus.completed) {
          context.push(AppRoutes.resultDetailPath(appointment.id));
        } else {
          context.push(AppRoutes.appointmentDetailPath(appointment.id));
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusBadge(
                  label: appointment.status.label,
                  tone: appointment.status.tone),
              const SizedBox(width: 8),
              Text(appointment.code,
                  style: AppTypography.caption
                      .copyWith(fontSize: 13, color: AppColors.textTertiary)),
            ],
          ),
          const SizedBox(height: 8),
          Text(appointment.title,
              style: AppTypography.bodyBold.copyWith(fontSize: 16.5)),
          const SizedBox(height: 3),
          Text(appointment.doctorAndRoom,
              style: AppTypography.caption.copyWith(fontSize: 14.5)),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: AppColors.primaryDark),
              const SizedBox(width: 6),
              Text(
                appointment.whenLabel,
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryDark),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
