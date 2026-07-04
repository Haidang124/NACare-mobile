import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/security_settings.dart';
import '../providers/security_providers.dart';

class ConsentManagementScreen extends ConsumerWidget {
  const ConsentManagementScreen({super.key});

  Future<void> _toggle(WidgetRef ref, ConsentItem item, bool enabled) async {
    if (item.locked) return;
    await ref.read(securityRepositoryProvider).setConsent(item.id, enabled);
    ref.invalidate(consentItemsProvider);
  }

  Future<void> _requestDeletion(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Yêu cầu xóa dữ liệu?',
      message: 'Tài khoản và dữ liệu cá nhân sẽ bị xóa vĩnh viễn khỏi hệ thống '
          '(trừ hồ sơ bệnh án bắt buộc lưu trữ theo luật). Hành động này không thể hoàn tác.',
      confirmLabel: 'Gửi yêu cầu',
      destructive: true,
    );
    if (!confirmed) return;
    final result =
        await ref.read(securityRepositoryProvider).requestDataDeletion();
    if (!context.mounted) return;
    result.when(
      success: (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Đã gửi yêu cầu xóa dữ liệu. Bệnh viện sẽ liên hệ xác nhận.')),
      ),
      failure: (f) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(f.message))),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consentsAsync = ref.watch(consentItemsProvider);

    return Scaffold(
      appBar: AppTopBar(
          title: 'Quản lý đồng ý dữ liệu', onBack: () => context.pop()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theo Nghị định 13/2023/NĐ-CP, bạn có quyền kiểm soát dữ liệu cá nhân của mình. '
              'Bật/tắt từng mục đích xử lý bên dưới.',
              style: AppTypography.caption.copyWith(fontSize: 14, height: 1.55),
            ),
            const SizedBox(height: 16),
            AsyncValueView<List<ConsentItem>>(
              value: consentsAsync,
              onRetry: () => ref.invalidate(consentItemsProvider),
              data: (context, items) => AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: List.generate(items.length, (i) {
                    final item = items[i];
                    final isLast = i == items.length - 1;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 13),
                      decoration: BoxDecoration(
                        border: isLast
                            ? null
                            : const Border(
                                bottom:
                                    BorderSide(color: AppColors.borderDivider)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.label,
                                    style: AppTypography.bodyBold
                                        .copyWith(fontSize: 15)),
                                Text(item.sub,
                                    style: AppTypography.caption.copyWith(
                                        fontSize: 13,
                                        color: AppColors.textMuted,
                                        height: 1.4)),
                              ],
                            ),
                          ),
                          Switch(
                            value: item.enabled,
                            activeTrackColor: AppColors.primary,
                            onChanged: item.locked
                                ? null
                                : (v) => _toggle(ref, item, v),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                color: AppColors.errorTint,
                border: Border.all(color: AppColors.errorBorder),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Yêu cầu xóa dữ liệu',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.error)),
                  const SizedBox(height: 4),
                  Text(
                    'Xóa vĩnh viễn tài khoản và dữ liệu cá nhân khỏi hệ thống. Không áp dụng cho hồ sơ '
                    'bệnh án bắt buộc lưu trữ theo luật.',
                    style: TextStyle(
                        fontSize: 13.5,
                        color: AppColors.error.withValues(alpha: 0.85),
                        height: 1.5),
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: 'Gửi yêu cầu xóa',
                    variant: AppButtonVariant.destructive,
                    height: 44,
                    onPressed: () => _requestDeletion(context, ref),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
