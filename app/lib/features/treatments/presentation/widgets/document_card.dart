import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/widgets.dart';
import '../../data/models/emr_document.dart';
import 'document_icon.dart';

/// Thẻ một phiếu EMR — chạm để mở file PDF. Dùng chung cho màn danh sách phiếu theo loại.
class DocumentCard extends StatelessWidget {
  const DocumentCard({
    super.key,
    required this.doc,
    required this.treatmentCode,
  });

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
            child: Icon(documentIconFor(doc.name),
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
                  doc.date != '—' ? doc.date : doc.code,
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
