import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/security_settings.dart';
import '../providers/security_providers.dart';

class SecurityScreen extends ConsumerWidget {
  const SecurityScreen({super.key});

  Future<void> _toggle(WidgetRef ref, String id, bool enabled) async {
    await ref.read(securityRepositoryProvider).setToggle(id, enabled);
    ref.invalidate(securityTogglesProvider);
  }

  Future<void> _logoutDevice(
      BuildContext context, WidgetRef ref, LoggedInDevice device) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Đăng xuất thiết bị này?',
      message: '${device.name} sẽ bị đăng xuất khỏi tài khoản của bạn.',
      confirmLabel: 'Đăng xuất',
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(securityRepositoryProvider).logoutDevice(device.id);
    ref.invalidate(loggedInDevicesProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final togglesAsync = ref.watch(securityTogglesProvider);
    final devicesAsync = ref.watch(loggedInDevicesProvider);

    return Scaffold(
      appBar: AppTopBar(title: 'Bảo mật', onBack: () => context.pop()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AsyncValueView<List<SecurityToggle>>(
              value: togglesAsync,
              onRetry: () => ref.invalidate(securityTogglesProvider),
              data: (context, toggles) => AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: List.generate(toggles.length, (i) {
                    final t = toggles[i];
                    final isLast = i == toggles.length - 1;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: isLast
                            ? null
                            : const Border(
                                bottom:
                                    BorderSide(color: AppColors.borderDivider)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: AppColors.iconBgSoft2,
                                borderRadius: BorderRadius.circular(11)),
                            child: Text(t.icon,
                                style: const TextStyle(fontSize: 17)),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(t.label,
                                    style: AppTypography.bodyBold
                                        .copyWith(fontSize: 15)),
                                Text(t.sub,
                                    style: AppTypography.caption.copyWith(
                                        fontSize: 13,
                                        color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                          Switch(
                            value: t.enabled,
                            activeTrackColor: AppColors.primary,
                            onChanged: (v) => _toggle(ref, t.id, v),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 20),
            AppCard(
              onTap: () => context.push(AppRoutes.consentManagement),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: AppColors.iconBgSoft2,
                        borderRadius: BorderRadius.circular(11)),
                    child: const Icon(Icons.fact_check_outlined,
                        size: 17, color: AppColors.primaryDark),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                      child: Text('Quản lý đồng ý dữ liệu',
                          style:
                              AppTypography.bodyBold.copyWith(fontSize: 15.5))),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textChevron),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('THIẾT BỊ ĐĂNG NHẬP', style: AppTypography.eyebrow),
            const SizedBox(height: 10),
            AsyncValueView<List<LoggedInDevice>>(
              value: devicesAsync,
              onRetry: () => ref.invalidate(loggedInDevicesProvider),
              data: (context, devices) => AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: List.generate(devices.length, (i) {
                    final d = devices[i];
                    final isLast = i == devices.length - 1;
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
                          Container(
                            width: 38,
                            height: 38,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                                color: AppColors.iconBgSoft2,
                                borderRadius: BorderRadius.circular(11)),
                            child: Text(d.icon,
                                style: const TextStyle(fontSize: 18)),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(d.name,
                                    style: AppTypography.bodyBold
                                        .copyWith(fontSize: 15)),
                                Text(d.info,
                                    style: AppTypography.caption.copyWith(
                                        fontSize: 13,
                                        color: AppColors.textMuted)),
                              ],
                            ),
                          ),
                          if (!d.isCurrent)
                            GestureDetector(
                              onTap: () => _logoutDevice(context, ref, d),
                              child: const Text('Đăng xuất',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.error)),
                            ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
