import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../patient_profiles/presentation/providers/patient_profiles_providers.dart';
import '../../data/models/linked_patient_match.dart';
import '../providers/auth_providers.dart';

/// Flow A bước 3 (ui-ux-app-benh-nhan.md): nhập CCCD (kèm họ tên nếu cần) để tra hồ sơ
/// bệnh nhân HIS qua `POST /patient/his-search`, chọn đúng hồ sơ của mình rồi liên kết
/// (`POST /patient/link-profile`). Không tìm thấy ⇒ có thể bỏ qua, liên kết sau.
class LinkProfileScreen extends ConsumerStatefulWidget {
  const LinkProfileScreen({super.key});

  @override
  ConsumerState<LinkProfileScreen> createState() => _LinkProfileScreenState();
}

class _LinkProfileScreenState extends ConsumerState<LinkProfileScreen> {
  final _cccdController = TextEditingController();
  final _nameController = TextEditingController();

  bool _isSearching = false;
  bool _isLinking = false;
  bool _searched = false;
  List<LinkedPatientMatch> _candidates = const [];
  String? _selectedCode;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _cccdController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _cccdController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  bool get _canSearch =>
      _cccdController.text.trim().length >= 9 && !_isSearching;

  Future<void> _search() async {
    if (!_canSearch) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isSearching = true;
      _errorText = null;
    });

    final result = await ref.read(authRepositoryProvider).searchHisProfiles(
          citizenId: _cccdController.text.trim(),
          fullName: _nameController.text.trim().isEmpty
              ? null
              : _nameController.text.trim(),
        );

    if (!mounted) return;
    setState(() => _isSearching = false);
    result.when(
      success: (list) => setState(() {
        _searched = true;
        _candidates = list;
        _selectedCode = list.isNotEmpty ? list.first.hisPatientCode : null;
      }),
      failure: (f) => setState(() => _errorText = f.message),
    );
  }

  Future<void> _link() async {
    final code = _selectedCode;
    if (code == null || _isLinking) return;
    setState(() => _isLinking = true);

    final result = await ref.read(authRepositoryProvider).linkProfile(code);

    if (!mounted) return;
    setState(() => _isLinking = false);
    result.when(
      success: (profileId) {
        // Hồ sơ vừa liên kết trở thành hồ sơ đang xem; nạp lại danh sách để nó xuất hiện.
        ref.read(activeProfileIdProvider.notifier).state = profileId;
        ref.invalidate(patientProfilesProvider);
        context.push(AppRoutes.pinSetup);
      },
      failure: (f) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(f.message))),
    );
  }

  /// Bỏ qua liên kết (không tìm thấy hoặc để làm sau) — vẫn vào app, liên kết sau ở tab Hồ sơ.
  void _skip() => context.push(AppRoutes.pinSetup);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppTopBar(title: '', onBack: () => context.pop(), showBorder: false),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        child: !_searched
            ? _searchView()
            : (_candidates.isEmpty ? _notFoundView() : _candidatesView()),
      ),
    );
  }

  // ── Bước nhập CCCD ──
  Widget _searchView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Liên kết hồ sơ bệnh nhân', style: AppTypography.display),
        const SizedBox(height: 8),
        Text(
          'Nhập số CCCD để tìm hồ sơ của bạn đã có tại bệnh viện. '
          'Thêm họ tên nếu muốn kết quả chính xác hơn.',
          style: AppTypography.body.copyWith(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 24),
        AppTextField(
          label: 'SỐ CCCD',
          hintText: 'VD: 040200013346',
          controller: _cccdController,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'HỌ VÀ TÊN (tuỳ chọn)',
          hintText: 'Nguyễn Văn A',
          controller: _nameController,
        ),
        if (_errorText != null) ...[
          const SizedBox(height: 12),
          Text(_errorText!,
              style: AppTypography.caption
                  .copyWith(color: AppColors.error, fontSize: 14)),
        ],
        const Spacer(),
        AppButton(
          label: 'Tìm hồ sơ',
          isLoading: _isSearching,
          onPressed: _canSearch ? _search : null,
        ),
        AppButton(
          label: 'Bỏ qua, liên kết sau',
          variant: AppButtonVariant.text,
          onPressed: _skip,
        ),
      ],
    );
  }

  // ── Kết quả: chọn hồ sơ để liên kết ──
  Widget _candidatesView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tìm thấy hồ sơ của bạn', style: AppTypography.display),
        const SizedBox(height: 8),
        Text(
          _candidates.length == 1
              ? 'Hệ thống tìm thấy 1 hồ sơ khớp. Kiểm tra và xác nhận đây là bạn.'
              : 'Tìm thấy ${_candidates.length} hồ sơ khớp. Chọn đúng hồ sơ của bạn.',
          style: AppTypography.body.copyWith(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 20),
        Expanded(
          child: ListView.separated(
            itemCount: _candidates.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _candidateCard(_candidates[i]),
          ),
        ),
        const SizedBox(height: 8),
        AppButton(
          label: 'Đây là tôi — liên kết hồ sơ',
          isLoading: _isLinking,
          onPressed: _selectedCode == null ? null : _link,
        ),
        AppButton(
          label: 'Không phải — tìm lại',
          variant: AppButtonVariant.text,
          onPressed: () => setState(() {
            _searched = false;
            _candidates = const [];
            _selectedCode = null;
          }),
        ),
      ],
    );
  }

  Widget _candidateCard(LinkedPatientMatch m) {
    final selected = m.hisPatientCode == _selectedCode;
    return GestureDetector(
      onTap: () => setState(() => _selectedCode = m.hisPatientCode),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: selected ? AppColors.greenTintSoft : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.borderSoft,
            width: selected ? 2 : 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppAvatar(initials: m.initials, size: 52),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(m.maskedName,
                          style:
                              AppTypography.titleSmall.copyWith(fontSize: 18)),
                      const SizedBox(height: 2),
                      Text('Mã BN: ${m.hisPatientCode}',
                          style: AppTypography.caption.copyWith(fontSize: 14)),
                    ],
                  ),
                ),
                if (selected)
                  const Icon(Icons.check_circle,
                      color: AppColors.primary, size: 26),
              ],
            ),
            const Divider(height: 28, color: AppColors.greenBorder),
            InfoRow(label: 'Năm sinh', value: m.maskedBirthYear),
            InfoRow(label: 'Giới tính', value: m.gender),
            InfoRow(label: 'Số điện thoại', value: m.maskedPhone),
          ],
        ),
      ),
    );
  }

  // ── Không tìm thấy ──
  Widget _notFoundView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Không tìm thấy hồ sơ', style: AppTypography.display),
        const SizedBox(height: 8),
        Text(
          'Không có hồ sơ bệnh nhân nào khớp CCCD vừa nhập. Bạn có thể tìm lại '
          'hoặc bỏ qua và liên kết sau ở mục Hồ sơ.',
          style: AppTypography.body.copyWith(fontSize: 16, height: 1.5),
        ),
        const Spacer(),
        AppButton(
          label: 'Tìm lại',
          onPressed: () => setState(() {
            _searched = false;
            _candidates = const [];
          }),
        ),
        AppButton(
          label: 'Bỏ qua, liên kết sau',
          variant: AppButtonVariant.text,
          onPressed: _skip,
        ),
      ],
    );
  }
}
