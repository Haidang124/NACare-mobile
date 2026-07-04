import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/personal_info.dart';
import '../providers/personal_info_providers.dart';

class PersonalInfoScreen extends ConsumerWidget {
  const PersonalInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final infoAsync = ref.watch(personalInfoProvider);

    return Scaffold(
      appBar:
          AppTopBar(title: 'Thông tin cá nhân', onBack: () => context.pop()),
      body: Column(
        children: [
          Expanded(
            child: AsyncValueView<PersonalInfo>(
              value: infoAsync,
              onRetry: () => ref.invalidate(personalInfoProvider),
              data: (context, info) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('HÀNH CHÍNH', style: AppTypography.eyebrow),
                    const SizedBox(height: 10),
                    AppCard(
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: List.generate(info.adminItems.length, (i) {
                          final item = info.adminItems[i];
                          final isLast = i == info.adminItems.length - 1;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 13),
                            decoration: BoxDecoration(
                              border: isLast
                                  ? null
                                  : const Border(
                                      bottom: BorderSide(
                                          color: AppColors.borderDivider)),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    child: Text(item.label,
                                        style: AppTypography.caption
                                            .copyWith(fontSize: 14))),
                                Text(item.value,
                                    style: AppTypography.bodyBold
                                        .copyWith(fontSize: 15)),
                              ],
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('BẢO HIỂM Y TẾ', style: AppTypography.eyebrow),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: AppColors.heroCardGradient,
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusXl),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text('THẺ BHYT',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white
                                          .withValues(alpha: 0.85))),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(6)),
                                child: Text(
                                  info.insurance.isValid
                                      ? 'Còn hạn'
                                      : 'Hết hạn',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            info.insurance.number,
                            style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 2),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Nơi ĐK KCB',
                                        style: TextStyle(
                                            fontSize: 13.5,
                                            color: Colors.white
                                                .withValues(alpha: 0.8))),
                                    const SizedBox(height: 2),
                                    Text(info.insurance.registeredHospital,
                                        style: const TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Hạn dùng',
                                      style: TextStyle(
                                          fontSize: 13.5,
                                          color: Colors.white
                                              .withValues(alpha: 0.8))),
                                  const SizedBox(height: 2),
                                  Text(info.insurance.validUntil,
                                      style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text('TIỀN SỬ & DỊ ỨNG', style: AppTypography.eyebrow),
                    const SizedBox(height: 10),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            children: info.medical.allergies
                                .map((a) => Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                          color: AppColors.errorTint,
                                          borderRadius:
                                              BorderRadius.circular(7)),
                                      child: Text('⚠ Dị ứng: $a',
                                          style: const TextStyle(
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.error)),
                                    ))
                                .toList(),
                          ),
                          const SizedBox(height: 10),
                          RichText(
                            text: TextSpan(
                              style: AppTypography.body.copyWith(
                                  fontSize: 14.5,
                                  color: AppColors.textBody,
                                  height: 1.5),
                              children: [
                                const TextSpan(
                                    text: 'Bệnh nền: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary)),
                                TextSpan(
                                    text:
                                        '${info.medical.chronicConditions}. '),
                                const TextSpan(
                                    text: 'Nhóm máu: ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.textPrimary)),
                                TextSpan(text: info.medical.bloodType),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.borderCard))),
            child: AppButton(
              label: 'Chỉnh sửa thông tin',
              height: 52,
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Chỉnh sửa thông tin sẽ hỗ trợ ở bản sau.')),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
