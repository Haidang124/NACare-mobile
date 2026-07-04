import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/mock_config.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/auth_providers.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const _resendSeconds = 60;

  Timer? _timer;
  int _secondsLeft = _resendSeconds;
  bool _isVerifying = false;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsLeft = _resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _resend() async {
    if (_secondsLeft > 0) return;
    final phone = ref.read(authFlowControllerProvider).phone;
    await ref.read(authRepositoryProvider).sendOtp(phone);
    if (!mounted) return;
    _startCountdown();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Đã gửi lại mã OTP')));
  }

  Future<void> _onCompleted(String otp) async {
    setState(() {
      _isVerifying = true;
      _errorText = null;
    });

    final phone = ref.read(authFlowControllerProvider).phone;
    final result = await ref
        .read(authRepositoryProvider)
        .verifyOtp(phone: phone, otp: otp);

    if (!mounted) return;
    setState(() => _isVerifying = false);

    result.when(
      success: (match) {
        ref.read(authFlowControllerProvider.notifier).setMatch(match);
        context.push(AppRoutes.linkProfile);
      },
      failure: (f) => setState(() => _errorText = f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    final phone = ref.watch(authFlowControllerProvider).maskedPhone;

    return Scaffold(
      appBar:
          AppTopBar(title: '', onBack: () => context.pop(), showBorder: false),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nhập mã xác thực', style: AppTypography.display),
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: AppTypography.body.copyWith(fontSize: 16, height: 1.5),
                children: [
                  const TextSpan(text: 'Mã OTP 6 số đã gửi đến '),
                  TextSpan(
                    text: phone,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Center(
              child: OtpInput(
                length: 6,
                onChanged: (_) => setState(() => _errorText = null),
                onCompleted: _onCompleted,
              ),
            ),
            if (_errorText != null) ...[
              const SizedBox(height: 12),
              Center(
                child: Text(_errorText!,
                    style: AppTypography.caption
                        .copyWith(color: AppColors.error, fontSize: 14)),
              ),
            ],
            if (_isVerifying) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
            const SizedBox(height: 20),
            Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                children: [
                  Text('Chưa nhận được mã? ',
                      style: AppTypography.caption.copyWith(fontSize: 15)),
                  GestureDetector(
                    onTap: _resend,
                    child: Text(
                      _secondsLeft > 0
                          ? 'Gửi lại (${(_secondsLeft ~/ 60).toString().padLeft(2, '0')}:${(_secondsLeft % 60).toString().padLeft(2, '0')})'
                          : 'Gửi lại',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _secondsLeft > 0
                            ? AppColors.textMuted
                            : AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.greenTintSoft,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Text(
                'Mã demo: $kMockValidOtp (bản mock chưa nối SMS gateway thật).',
                style: AppTypography.caption
                    .copyWith(fontSize: 13, color: AppColors.primaryDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
