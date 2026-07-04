import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/checkin_providers.dart';
import '../widgets/placeholder_qr.dart';

class CheckinScreen extends ConsumerStatefulWidget {
  const CheckinScreen({super.key});

  @override
  ConsumerState<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends ConsumerState<CheckinScreen> {
  bool _isCheckingIn = false;

  Future<void> _confirmCheckin() async {
    setState(() => _isCheckingIn = true);
    final result = await ref.read(checkinRepositoryProvider).checkin('a1');
    if (!mounted) return;
    setState(() => _isCheckingIn = false);
    result.when(
      success: (_) => context.pushReplacement(AppRoutes.queue),
      failure: (f) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(f.message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            children: [
              Row(
                children: [
                  AppIconButton.onDark(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => context.pop()),
                  const SizedBox(width: 12),
                  Text('Check-in',
                      style: AppTypography.titleSmall
                          .copyWith(color: Colors.white)),
                ],
              ),
              const SizedBox(height: 22),
              Text(
                'Đưa mã QR này cho quầy tiếp nhận\nhoặc quét tại kiosk tự động',
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 15,
                    height: 1.5),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXxl),
                ),
                child: const PlaceholderQr(size: 220),
              ),
              const SizedBox(height: 18),
              Text('Mã dự phòng nếu quét lỗi',
                  style: AppTypography.caption.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14)),
              const SizedBox(height: 4),
              const Text(
                '8 2 4 6 1 9',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 5),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isCheckingIn ? null : _confirmCheckin,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryDark),
                  child: _isCheckingIn
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.4, color: AppColors.primaryDark),
                        )
                      : const Text('Tôi đã check-in — xem số thứ tự'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
