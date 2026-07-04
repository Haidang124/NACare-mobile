import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/avatar/app_avatar.dart';
import '../../data/models/patient_profile.dart';
import '../providers/patient_profiles_providers.dart';

/// Bottom sheet for choosing a family member's profile — Flow F in ui-ux-app-benh-nhan.md.
class ProfileSwitcherSheet extends ConsumerWidget {
  const ProfileSwitcherSheet({super.key});

  static Future<void> open(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const ProfileSwitcherSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(patientProfilesProvider);
    final activeId = ref.watch(activeProfileIdProvider);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.borderMedium,
                  borderRadius: BorderRadius.circular(99),
                )),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Chọn hồ sơ', style: AppTypography.titleSmall),
            ),
            const SizedBox(height: 14),
            profilesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              ),
              error: (_, __) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Text('Không tải được danh sách hồ sơ.'),
              ),
              data: (profiles) => Column(
                children: profiles
                    .map((p) => _ProfileTile(
                          profile: p,
                          selected: p.id == activeId ||
                              (activeId == null && p.isSelf),
                          onTap: () {
                            ref.read(activeProfileIdProvider.notifier).state =
                                p.id;
                            Navigator.of(context).pop();
                          },
                        ))
                    .toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(
                      color: AppColors.borderDashed,
                      width: 1.5,
                      style: BorderStyle.solid),
                ),
                child: const Text('+ Thêm người thân'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile(
      {required this.profile, required this.selected, required this.onTap});

  final PatientProfile profile;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected ? AppColors.greenTintSoft : Colors.white,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                  color: selected ? AppColors.primary : AppColors.borderCard,
                  width: 1.5),
            ),
            child: Row(
              children: [
                AppAvatar(
                    initials: profile.initials,
                    background: profile.avatarColor,
                    size: 44),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(profile.fullName, style: AppTypography.bodyBold),
                      Text(profile.relationship,
                          style:
                              AppTypography.caption.copyWith(fontSize: 13.5)),
                    ],
                  ),
                ),
                if (selected)
                  const Icon(Icons.check_circle,
                      color: AppColors.primary, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
