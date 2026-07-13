import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/emr_document.dart';
import '../providers/emr_providers.dart';

/// Danh sách phiếu EMR của một lần điều trị (kết quả khám, đơn thuốc…). Chạm một phiếu
/// để mở file PDF. Nhận [treatmentCode] + [treatmentTitle] (hiển thị) từ route.
class TreatmentDocumentsScreen extends ConsumerWidget {
  const TreatmentDocumentsScreen({
    super.key,
    required this.treatmentCode,
    this.treatmentTitle,
  });

  final String treatmentCode;
  final String? treatmentTitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(treatmentDocumentsProvider(treatmentCode));

    return Scaffold(
      appBar: AppTopBar(
        title: 'Phiếu điều trị',
        subtitle: treatmentTitle,
        onBack: () => context.pop(),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 0),
          child: AsyncValueView<List<EmrDocument>>(
            value: docsAsync,
            isEmpty: (data) => data.isEmpty,
            onRetry: () =>
                ref.invalidate(treatmentDocumentsProvider(treatmentCode)),
            emptyBuilder: (_) => const EmptyStateView(
              icon: Icons.folder_open_outlined,
              title: 'Chưa có phiếu',
              message: 'Lần điều trị này chưa có phiếu EMR nào.',
            ),
            data: (context, items) => ListView.separated(
              padding: const EdgeInsets.only(bottom: 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _DocumentCard(
                doc: items[i],
                treatmentCode: treatmentCode,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.doc, required this.treatmentCode});

  final EmrDocument doc;
  final String treatmentCode;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => context.push(
        AppRoutes.emrDocumentPath(treatmentCode, doc.documentId),
        extra: doc.name,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.greenTint,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(Icons.picture_as_pdf_outlined,
                color: AppColors.primaryDark),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doc.name,
                    style: AppTypography.bodyBold.copyWith(fontSize: 15.5)),
                const SizedBox(height: 3),
                Text(
                  [
                    if (doc.typeName.isNotEmpty) doc.typeName,
                    if (doc.date != '—') doc.date,
                  ].join(' · '),
                  style: AppTypography.caption.copyWith(fontSize: 13.5),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textTertiary),
        ],
      ),
    );
  }
}
