import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../patient_profiles/data/models/patient_profile.dart';
import '../../../patient_profiles/presentation/providers/patient_profiles_providers.dart';
import '../widgets/add_family_member_sheet.dart';

class _MenuEntry {
  const _MenuEntry(this.emoji, this.label, this.route);
  final String emoji;
  final String label;
  final String route;
}

// Emoji + labels match the mockup (the "Profile" menu).
const _menu = [
  _MenuEntry('🪪', 'Thông tin cá nhân & bảo hiểm', AppRoutes.personalInfo),
  _MenuEntry('💳', 'Thanh toán & lịch sử giao dịch', AppRoutes.payments),
  _MenuEntry('💉', 'Sổ tiêm chủng', AppRoutes.immunization),
  _MenuEntry('📈', 'Chỉ số sức khỏe', AppRoutes.healthMetrics),
  _MenuEntry('🔒', 'Bảo mật & thiết bị đăng nhập', AppRoutes.security),
  _MenuEntry('📋', 'Quản lý đồng ý dữ liệu', AppRoutes.consentManagement),
];

class ProfileTabScreen extends ConsumerWidget {
  const ProfileTabScreen({super.key});

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Đăng xuất?',
      message:
          'Bạn sẽ cần đăng nhập lại bằng số điện thoại để tiếp tục sử dụng.',
      confirmLabel: 'Đăng xuất',
      destructive: true,
    );
    if (!confirmed) return;
    await ref.read(sessionControllerProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(activeProfileProvider);
    final familyAsync = ref.watch(patientProfilesProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cá nhân', style: AppTypography.tabTitle),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    gradient: AppColors.heroCardGradient,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl)),
                child: Row(
                  children: [
                    AppAvatar(
                      initials: profile?.initials ?? '',
                      background: Colors.white,
                      foreground: AppColors.primaryDark,
                      size: 54,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(profile?.fullName ?? '...',
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                          const SizedBox(height: 2),
                          Text(
                            'Mã BN: ${profile?.patientCode ?? '-'} · BHYT ${profile?.insuranceValid ?? true ? 'còn hạn' : 'hết hạn'}',
                            style: TextStyle(
                                fontSize: 13.5,
                                color: Colors.white.withValues(alpha: 0.85)),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.personalInfo),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8)),
                        child: const Text('Sửa',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text('Hồ sơ người thân',
                      style: AppTypography.bodyBold.copyWith(fontSize: 16)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => AddFamilyMemberSheet.open(context),
                    child: const Text('+ Thêm',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 116,
                child: AsyncValueView<List<PatientProfile>>(
                  value: familyAsync,
                  onRetry: () => ref.invalidate(patientProfilesProvider),
                  data: (context, profiles) => ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: profiles.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, i) {
                      final p = profiles[i];
                      final selected = p.id ==
                          (ref.watch(activeProfileIdProvider) ??
                              profiles.first.id);
                      return GestureDetector(
                        onTap: () => ref
                            .read(activeProfileIdProvider.notifier)
                            .state = p.id,
                        child: Container(
                          width: 116,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.borderCard,
                                width: 1.5),
                          ),
                          child: Column(
                            children: [
                              AppAvatar(
                                  initials: p.initials,
                                  background: p.avatarColor,
                                  size: 42),
                              const SizedBox(height: 7),
                              Text(p.fullName,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.bodyBold
                                      .copyWith(fontSize: 13.5),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis),
                              Text(p.relationship,
                                  style: AppTypography.caption
                                      .copyWith(fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),
              AppCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: _menu.map((entry) {
                    final isLast = entry == _menu.last;
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.push(entry.route),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            border: isLast
                                ? null
                                : const Border(
                                    bottom: BorderSide(
                                        color: AppColors.borderDivider)),
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
                                child: Text(entry.emoji,
                                    style: const TextStyle(fontSize: 17)),
                              ),
                              const SizedBox(width: 13),
                              Expanded(
                                  child: Text(entry.label,
                                      style: AppTypography.bodyBold
                                          .copyWith(fontSize: 15.5))),
                              const Icon(Icons.chevron_right_rounded,
                                  color: AppColors.textChevron),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                label: 'Đăng xuất',
                variant: AppButtonVariant.destructive,
                height: 50,
                onPressed: () => _logout(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
