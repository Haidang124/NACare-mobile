import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// Must be read & accepted before entering the app, per Decree 13/2023/NĐ-CP
/// (ui-ux-app-benh-nhan.md — design principles, "sensitive medical data" section).
class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  bool _agreed = false;

  void _submit() {
    if (!_agreed) return;
    ref.read(sessionControllerProvider.notifier).completeLogin();
    ref.read(authFlowControllerProvider.notifier).reset();
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Đồng ý sử dụng dữ liệu', style: AppTypography.display),
              const SizedBox(height: 4),
              Text(
                'Theo Nghị định 13/2023/NĐ-CP về bảo vệ dữ liệu cá nhân',
                style: AppTypography.caption
                    .copyWith(fontSize: 14, color: AppColors.textTertiary),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderSoft),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: SingleChildScrollView(
                    child: RichText(
                      text: TextSpan(
                        style: AppTypography.body.copyWith(
                            fontSize: 16,
                            height: 1.65,
                            color: AppColors.textBody),
                        children: const [
                          TextSpan(
                            text: '1. Dữ liệu thu thập. ',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary),
                          ),
                          TextSpan(
                            text:
                                'Họ tên, ngày sinh, số điện thoại, CCCD, thông tin bảo hiểm và dữ liệu y tế '
                                'phát sinh trong quá trình khám chữa bệnh.\n\n',
                          ),
                          TextSpan(
                            text: '2. Mục đích. ',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary),
                          ),
                          TextSpan(
                            text:
                                'Liên kết hồ sơ bệnh án, đặt lịch khám, trả kết quả, nhắc dùng thuốc và '
                                'thông báo y tế.\n\n',
                          ),
                          TextSpan(
                            text: '3. Phạm vi chia sẻ. ',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary),
                          ),
                          TextSpan(
                            text:
                                'Dữ liệu chỉ dùng trong hệ thống của Bệnh viện Hữu Nghị Đa Khoa Nghệ An, '
                                'không chia sẻ cho bên thứ ba khi chưa có sự đồng ý.\n\n',
                          ),
                          TextSpan(
                            text: '4. Quyền của bạn. ',
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary),
                          ),
                          TextSpan(
                            text:
                                'Xem, chỉnh sửa, rút lại sự đồng ý và yêu cầu xóa dữ liệu bất kỳ lúc nào '
                                'trong mục Cá nhân → Bảo mật.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () => setState(() => _agreed = !_agreed),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        color: _agreed ? AppColors.primary : Colors.transparent,
                        border: Border.all(color: AppColors.primary, width: 2),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: _agreed
                          ? const Icon(Icons.check,
                              size: 16, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Tôi đã đọc và đồng ý cho phép xử lý dữ liệu cá nhân theo nội dung trên',
                        style: AppTypography.body.copyWith(
                            fontSize: 15,
                            height: 1.5,
                            color: AppColors.textBody),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Đồng ý và vào ứng dụng',
                onPressed: _agreed ? _submit : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
