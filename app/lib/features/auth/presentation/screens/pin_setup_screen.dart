import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/auth_providers.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  bool _isSubmitting = false;

  Future<void> _submit(String pin) async {
    setState(() => _isSubmitting = true);
    final result = await ref.read(authRepositoryProvider).setPin(pin);
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    result.when(
      success: (_) => context.push(AppRoutes.consent),
      failure: (f) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(f.message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
          child: Column(
            children: [
              Text('Thiết lập mã PIN',
                  style: AppTypography.display, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'Bảo vệ dữ liệu y tế của bạn bằng mã PIN 4 số',
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 32),
              if (_isSubmitting)
                const CircularProgressIndicator()
              else
                PinInput(length: 4, onChanged: (_) {}, onCompleted: _submit),
              const SizedBox(height: 26),
              GestureDetector(
                onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Sinh trắc học sẽ hỗ trợ ở bản sau.')),
                ),
                child: Text(
                  '☝ Bật Face ID / vân tay sau khi tạo PIN',
                  style: AppTypography.bodySecondary
                      .copyWith(color: AppColors.primary, fontSize: 15),
                ),
              ),
              const Spacer(),
              AppButton(
                label: 'Bỏ qua',
                variant: AppButtonVariant.text,
                expanded: false,
                height: 44,
                onPressed: () => context.push(AppRoutes.consent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
