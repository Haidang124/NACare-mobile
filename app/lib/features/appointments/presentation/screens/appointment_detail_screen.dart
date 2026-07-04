import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/currency.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/appointment.dart';
import '../providers/appointments_providers.dart';

class AppointmentDetailScreen extends ConsumerWidget {
  const AppointmentDetailScreen({super.key, required this.id});
  final String id;

  Future<void> _cancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Hủy lịch hẹn?',
      message: 'Bạn sẽ cần đặt lịch lại nếu muốn khám vào lúc khác.',
      confirmLabel: 'Hủy lịch',
      destructive: true,
    );
    if (!confirmed) return;
    final result =
        await ref.read(appointmentsRepositoryProvider).cancelAppointment(id);
    if (!context.mounted) return;
    result.when(
      success: (_) {
        ref.invalidate(upcomingAppointmentsProvider);
        ref.invalidate(appointmentDetailProvider(id));
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Đã hủy lịch hẹn')));
        context.pop();
      },
      failure: (f) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(f.message))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(appointmentDetailProvider(id));

    return Scaffold(
      appBar:
          AppTopBar(title: 'Chi tiết lịch hẹn', onBack: () => context.pop()),
      body: AsyncValueView<Appointment>(
        value: detailAsync,
        onRetry: () => ref.invalidate(appointmentDetailProvider(id)),
        data: (context, appt) {
          final isCancellable = appt.status == AppointmentStatus.today ||
              appt.status == AppointmentStatus.upcoming;
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                StatusBadge(
                                    label: appt.status.label,
                                    tone: appt.status.tone),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(appt.title,
                                style: AppTypography.titleSmall
                                    .copyWith(fontSize: 19)),
                            const Divider(height: 28),
                            InfoRow(label: 'Mã lịch hẹn', value: appt.code),
                            InfoRow(label: 'Bác sĩ', value: appt.doctorName),
                            InfoRow(label: 'Phòng khám', value: appt.room),
                            InfoRow(
                              label: 'Phí dự kiến',
                              value: appt.feeVnd > 0
                                  ? formatVnd(appt.feeVnd)
                                  : '-',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.iconBgSoft2,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: Text(
                          '📍 Đến quầy tiếp nhận tầng 1 hoặc dùng QR check-in khi tới bệnh viện. '
                          'Mang theo CCCD và thẻ BHYT.',
                          style: AppTypography.caption.copyWith(
                              fontSize: 14.5,
                              color: AppColors.textBody,
                              height: 1.55),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (isCancellable)
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border:
                        Border(top: BorderSide(color: AppColors.borderCard)),
                  ),
                  child: Column(
                    children: [
                      AppButton(
                        label: 'Check-in bằng QR',
                        height: 52,
                        onPressed: () => context.push(AppRoutes.checkin),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              label: 'Đổi lịch',
                              height: 46,
                              variant: AppButtonVariant.secondary,
                              onPressed: () =>
                                  context.push(AppRoutes.bookAppointment),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: AppButton(
                              label: 'Hủy lịch',
                              height: 46,
                              variant: AppButtonVariant.destructive,
                              onPressed: () => _cancel(context, ref),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
