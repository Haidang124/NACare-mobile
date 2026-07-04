import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../patient_profiles/presentation/providers/patient_profiles_providers.dart';

class AddFamilyMemberSheet extends ConsumerStatefulWidget {
  const AddFamilyMemberSheet({super.key});

  static Future<void> open(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddFamilyMemberSheet(),
    );
  }

  @override
  ConsumerState<AddFamilyMemberSheet> createState() =>
      _AddFamilyMemberSheetState();
}

class _AddFamilyMemberSheetState extends ConsumerState<AddFamilyMemberSheet> {
  final _nameController = TextEditingController();
  final _yearController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final year = int.tryParse(_yearController.text.trim());
    if (name.isEmpty || year == null) return;

    setState(() => _isSubmitting = true);
    final result = await ref
        .read(patientProfilesRepositoryProvider)
        .addFamilyMember(fullName: name, birthYear: year);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    result.when(
      success: (_) {
        ref.invalidate(patientProfilesProvider);
        Navigator.of(context).pop();
      },
      failure: (f) => ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(f.message))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Thêm người thân', style: AppTypography.titleSmall),
              const SizedBox(height: 16),
              AppTextField(
                  label: 'HỌ VÀ TÊN',
                  hintText: 'Nguyễn Văn B',
                  controller: _nameController),
              const SizedBox(height: 14),
              AppTextField(
                label: 'NĂM SINH',
                hintText: 'VD: 1990',
                controller: _yearController,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                  label: 'Thêm hồ sơ',
                  isLoading: _isSubmitting,
                  onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}
