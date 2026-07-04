import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/linked_patient_match.dart';
import '../providers/auth_providers.dart';

/// Flow A step 3 (ui-ux-app-benh-nhan.md): one profile found → confirm; none found
/// → create a new profile. (The "multiple duplicate profiles" branch is deferred to a
/// later go-live, noted in docs/architecture/04-viec-con-lai.md).
class LinkProfileScreen extends ConsumerStatefulWidget {
  const LinkProfileScreen({super.key});

  @override
  ConsumerState<LinkProfileScreen> createState() => _LinkProfileScreenState();
}

class _LinkProfileScreenState extends ConsumerState<LinkProfileScreen> {
  bool _isSubmitting = false;
  final _nameController = TextEditingController();
  final _yearController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _confirmLink() async {
    setState(() => _isSubmitting = true);
    final result = await ref.read(authRepositoryProvider).linkProfile();
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    result.when(
      success: (_) => context.push(AppRoutes.pinSetup),
      failure: (f) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(f.message))),
    );
  }

  Future<void> _confirmCreateNew() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isSubmitting = true);
    final result = await ref.read(authRepositoryProvider).createNewProfile();
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    result.when(
      success: (_) => context.push(AppRoutes.pinSetup),
      failure: (f) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(f.message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final match = ref.watch(authFlowControllerProvider).match;
    final isNewProfile = ref.watch(authFlowControllerProvider).isNewProfile;

    return Scaffold(
      appBar:
          AppTopBar(title: '', onBack: () => context.pop(), showBorder: false),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: (match != null && !isNewProfile)
            ? _foundView(match)
            : _createNewView(),
      ),
    );
  }

  Widget _foundView(LinkedPatientMatch match) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tìm thấy hồ sơ của bạn', style: AppTypography.display),
        const SizedBox(height: 8),
        Text(
          'Hệ thống tìm thấy 1 hồ sơ bệnh nhân trùng số điện thoại tại bệnh viện.',
          style: AppTypography.body.copyWith(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.greenTintSoft,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            border: Border.all(color: AppColors.greenBorder, width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppAvatar(initials: match.initials, size: 52),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(match.maskedName,
                            style: AppTypography.titleSmall
                                .copyWith(fontSize: 18)),
                        const SizedBox(height: 2),
                        Text('Mã BN: ${match.patientCode}',
                            style:
                                AppTypography.caption.copyWith(fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 32, color: AppColors.greenBorder),
              InfoRow(label: 'Năm sinh', value: match.maskedBirthYear),
              InfoRow(label: 'Giới tính', value: match.gender),
              InfoRow(label: 'Lần khám gần nhất', value: match.lastVisit),
            ],
          ),
        ),
        const Spacer(),
        AppButton(
          label: 'Đây là tôi — liên kết hồ sơ',
          isLoading: _isSubmitting,
          onPressed: _confirmLink,
        ),
        AppButton(
          label: 'Không phải tôi — tạo hồ sơ mới',
          variant: AppButtonVariant.text,
          onPressed: () => ref
              .read(authFlowControllerProvider.notifier)
              .chooseCreateNewProfile(),
        ),
      ],
    );
  }

  Widget _createNewView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tạo hồ sơ bệnh nhân mới', style: AppTypography.display),
        const SizedBox(height: 8),
        Text(
          'Không tìm thấy hồ sơ trùng số điện thoại. Nhập thông tin cơ bản để tạo hồ sơ.',
          style: AppTypography.body.copyWith(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 24),
        AppTextField(
            label: 'HỌ VÀ TÊN',
            hintText: 'Nguyễn Văn A',
            controller: _nameController),
        const SizedBox(height: 16),
        AppTextField(
          label: 'NĂM SINH',
          hintText: 'VD: 1990',
          controller: _yearController,
          keyboardType: TextInputType.number,
        ),
        const Spacer(),
        AppButton(
          label: 'Tạo hồ sơ',
          isLoading: _isSubmitting,
          onPressed:
              _nameController.text.trim().isEmpty ? null : _confirmCreateNew,
        ),
      ],
    );
  }
}
