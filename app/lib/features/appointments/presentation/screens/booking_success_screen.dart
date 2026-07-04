import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/booking_draft.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key, required this.confirmation});
  final BookingConfirmation confirmation;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            children: [
              Container(
                width: 84,
                height: 84,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: AppColors.greenTint, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded,
                    size: 40, color: AppColors.primaryDark),
              ),
              const SizedBox(height: 18),
              Text('Đặt lịch thành công!', style: AppTypography.tabTitle),
              const SizedBox(height: 6),
              Text('Mã lịch hẹn của bạn',
                  style: AppTypography.caption.copyWith(fontSize: 15.5)),
              const SizedBox(height: 4),
              Text(
                confirmation.code,
                style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                    letterSpacing: 2),
              ),
              const SizedBox(height: 18),
              if (confirmation.whenLabel.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.greenTintSoft,
                    border: Border.all(color: AppColors.borderSoft),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: InfoRow(
                      label: 'Thời gian',
                      value: confirmation.whenLabel,
                      valueColor: AppColors.primaryDark),
                ),
              const Spacer(),
              AppButton(
                label: 'Xem lịch khám của tôi',
                onPressed: () => context.go(AppRoutes.appointments),
              ),
              AppButton(
                label: '+ Thêm vào lịch điện thoại',
                variant: AppButtonVariant.text,
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sẽ hỗ trợ ở bản sau.')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
