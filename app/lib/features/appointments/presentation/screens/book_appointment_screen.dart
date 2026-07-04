import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/appointments_providers.dart';
import '../providers/booking_controller.dart';
import '../widgets/booking/booking_step_confirm.dart';
import '../widgets/booking/booking_step_date_time.dart';
import '../widgets/booking/booking_step_profile.dart';
import '../widgets/booking/booking_step_reason.dart';
import '../widgets/booking/booking_step_specialty.dart';

/// Shell for the 5-step booking screen (Flow B). Holds the scaffold + navigation logic;
/// each step's UI lives in `widgets/booking/booking_step_*.dart`.
class BookAppointmentScreen extends ConsumerStatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  ConsumerState<BookAppointmentScreen> createState() =>
      _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  bool _isSubmitting = false;
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _exit() async {
    final step = ref.read(bookingControllerProvider).step;
    if (step > 1) {
      final confirmed = await ConfirmDialog.show(
        context,
        title: 'Hủy đặt lịch?',
        message: 'Thông tin bạn đã chọn sẽ không được lưu.',
        confirmLabel: 'Hủy bỏ',
        destructive: true,
      );
      if (!confirmed) return;
    }
    ref.read(bookingControllerProvider.notifier).reset();
    if (mounted) context.pop();
  }

  void _back() {
    final movedBack = ref.read(bookingControllerProvider.notifier).goBack();
    if (!movedBack) {
      ref.read(bookingControllerProvider.notifier).reset();
      context.pop();
    }
  }

  Future<void> _next() async {
    final controller = ref.read(bookingControllerProvider.notifier);
    final isFinalStep =
        ref.read(bookingControllerProvider).step == BookingState.totalSteps;

    if (!isFinalStep) {
      controller.goNext();
      return;
    }

    setState(() => _isSubmitting = true);
    final draft = ref.read(bookingControllerProvider).draft;
    final result =
        await ref.read(appointmentsRepositoryProvider).submitBooking(draft);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.when(
      success: (confirmation) {
        controller.reset();
        ref.invalidate(upcomingAppointmentsProvider);
        context.pushReplacement(AppRoutes.bookAppointmentSuccess,
            extra: confirmation);
      },
      failure: (f) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(f.message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceBg,
      body: SafeArea(
        child: Column(
          children: [
            _BookingHeader(state: bookingState, onBack: _back, onExit: _exit),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: switch (bookingState.step) {
                  1 => const BookingStepProfile(),
                  2 => const BookingStepSpecialty(),
                  3 => const BookingStepDateTime(),
                  4 => BookingStepReason(controller: _reasonController),
                  _ => const BookingStepConfirm(),
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.borderCard)),
              ),
              child: AppButton(
                label: bookingState.step == BookingState.totalSteps
                    ? 'Xác nhận đặt lịch'
                    : 'Tiếp tục',
                isLoading: _isSubmitting,
                onPressed: bookingState.canGoNext ? _next : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Booking header: back/close button + step title + 5-segment progress bar.
class _BookingHeader extends StatelessWidget {
  const _BookingHeader(
      {required this.state, required this.onBack, required this.onExit});

  final BookingState state;
  final VoidCallback onBack;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.borderCard)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              AppIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onTap: onBack,
                  iconSize: 16),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Đặt lịch khám', style: AppTypography.titleSmall),
                    Text(
                      'Bước ${state.step}/${BookingState.totalSteps} — ${state.stepName}',
                      style: AppTypography.caption.copyWith(
                          fontSize: 13, color: AppColors.textTertiary),
                    ),
                  ],
                ),
              ),
              AppIconButton(
                  icon: Icons.close_rounded, onTap: onExit, iconSize: 16),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(BookingState.totalSteps, (i) {
              final active = i < state.step;
              return Expanded(
                child: Container(
                  height: 5,
                  margin: EdgeInsets.only(
                      right: i == BookingState.totalSteps - 1 ? 0 : 6),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.borderCard,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
