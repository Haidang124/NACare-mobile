import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/keys.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _controller = TextEditingController();
  bool _isSubmitting = false;
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isValid => _controller.text.trim().length >= 9;

  Future<void> _submit() async {
    if (!_isValid || _isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _errorText = null;
    });

    final phone = _controller.text.trim();
    final result = await ref.read(authRepositoryProvider).sendOtp(phone);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.when(
      success: (debugOtp) {
        ref.read(authFlowControllerProvider.notifier).setPhone(phone);
        // Lưu mã BE lộ ra (nếu có) để màn OTP hiện gợi ý.
        ref.read(authFlowControllerProvider.notifier).setDebugOtp(debugOtp);
        context.push(AppRoutes.otp);
      },
      failure: (f) => setState(() => _errorText = f.message),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 26),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                        color: Colors.white, shape: BoxShape.circle),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset('assets/images/logo.jpg',
                        fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Đăng nhập / Đăng ký',
                            style: AppTypography.title
                                .copyWith(color: Colors.white, fontSize: 21)),
                        const SizedBox(height: 2),
                        Text(
                          'Dùng số điện thoại đã đăng ký khám',
                          style: AppTypography.body.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SỐ ĐIỆN THOẠI',
                        style:
                            AppTypography.bodySecondary.copyWith(fontSize: 14)),
                    const SizedBox(height: 8),
                    Container(
                      height: 58,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceInput,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(
                          color: _errorText != null
                              ? AppColors.error
                              : AppColors.borderMedium,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Text('+84',
                              style: AppTypography.bodyBold
                                  .copyWith(fontSize: 18)),
                          const SizedBox(width: 10),
                          Container(
                              width: 1,
                              height: 24,
                              color: AppColors.borderMedium),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              key: AppKeys.loginPhoneField,
                              controller: _controller,
                              autofocus: true,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              style: AppTypography.bodyBold
                                  .copyWith(fontSize: 20, letterSpacing: 1),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                filled: false,
                              ),
                              onChanged: (_) =>
                                  setState(() => _errorText = null),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorText ??
                          'Chúng tôi sẽ gửi mã OTP 6 số qua SMS để xác thực.',
                      style: AppTypography.caption.copyWith(
                        fontSize: 13,
                        color: _errorText != null
                            ? AppColors.error
                            : AppColors.textTertiary,
                      ),
                    ),
                    const Spacer(),
                    AppButton(
                      key: AppKeys.loginSubmit,
                      label: 'Nhận mã OTP',
                      isLoading: _isSubmitting,
                      onPressed: _isValid ? _submit : null,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
