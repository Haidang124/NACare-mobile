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
import '../widgets/document_icon.dart';

/// Danh sách phiếu KẾT QUẢ của một lần điều trị (đã lọc `type = "Phiếu kết quả"` từ BE, gồm
/// kết quả XN, điện tim, siêu âm…). Chạm một phiếu để mở PDF. Nhận [treatmentCode] +
/// [treatmentTitle] (hiển thị) từ route.
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
        title: 'Kết quả khám',
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
              title: 'Chưa có kết quả',
              message: 'Lần điều trị này chưa có phiếu kết quả nào.',
            ),
            data: (context, items) {
              final groups = _groupDocuments(items);
              return ListView.separated(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: groups.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) => _DocumentGroupCard(
                  group: groups[i],
                  treatmentCode: treatmentCode,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

List<_DocumentGroup> _groupDocuments(List<EmrDocument> docs) {
  final byName = <String, List<EmrDocument>>{};
  for (final doc in docs) {
    final title = _documentGroupTitle(doc);
    final key = title.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    byName.putIfAbsent(key, () => []).add(doc);
  }

  return byName.values.map((items) => _DocumentGroup(items)).toList()
    ..sort((a, b) => a.title.compareTo(b.title));
}

String _documentGroupTitle(EmrDocument doc) {
  final name = doc.name.trim();
  if (!_looksLikePdfFileName(name)) return name;

  final typeName = doc.typeName.trim();
  if (typeName.isNotEmpty) return typeName;

  return kPatientDocumentType;
}

bool _looksLikePdfFileName(String value) {
  final lower = value.toLowerCase();
  if (!lower.endsWith('.pdf')) return false;
  return RegExp(r'^[\d_\-a-z]+\.pdf$').hasMatch(lower);
}

String _documentItemTitle(EmrDocument doc, String groupTitle) {
  final name = doc.name.trim();
  if (name.isNotEmpty && name != groupTitle) return name;
  if (doc.code.trim().isNotEmpty) return doc.code.trim();
  return doc.date != '—' ? doc.date : 'Phiếu kết quả';
}

class _DocumentGroup {
  _DocumentGroup(this.documents);

  final List<EmrDocument> documents;

  EmrDocument get first => documents.first;
  String get title => _documentGroupTitle(first);
  String get iconLabel => [
        title,
        ...documents.map((doc) => doc.name),
        ...documents.map((doc) => doc.typeName),
        ...documents.map((doc) => doc.code),
      ].join(' ');
  String get subtitle {
    final dates = documents
        .map((doc) => doc.date)
        .where((date) => date.isNotEmpty && date != '—')
        .toSet()
        .toList();
    if (documents.length == 1) return dates.isEmpty ? first.code : dates.first;
    if (dates.length == 1) return '${documents.length} phiếu · ${dates.first}';
    return '${documents.length} phiếu';
  }
}

class _DocumentGroupCard extends StatefulWidget {
  const _DocumentGroupCard({
    required this.group,
    required this.treatmentCode,
  });

  final _DocumentGroup group;
  final String treatmentCode;

  @override
  State<_DocumentGroupCard> createState() => _DocumentGroupCardState();
}

class _DocumentGroupCardState extends State<_DocumentGroupCard> {
  bool _expanded = false;
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final group = widget.group;
    final visibleCount =
        _showAll || group.documents.length <= 5 ? group.documents.length : 5;

    return AppCard(
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            onTap: () => setState(() {
              _expanded = !_expanded;
              if (!_expanded) _showAll = false;
            }),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.greenTint,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Icon(documentIconFor(group.iconLabel),
                        color: AppColors.primaryDark),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(group.title,
                            style: AppTypography.bodyBold
                                .copyWith(fontSize: 15.5)),
                        const SizedBox(height: 3),
                        Text(group.subtitle,
                            style:
                                AppTypography.caption.copyWith(fontSize: 13.5)),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textTertiary,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 12),
            const Divider(height: 1, color: AppColors.borderDivider),
            ListView.separated(
              padding: const EdgeInsets.only(top: 8),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: visibleCount,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) => _DocumentChildRow(
                doc: group.documents[i],
                groupTitle: group.title,
                treatmentCode: widget.treatmentCode,
              ),
            ),
            if (group.documents.length > 5) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => setState(() => _showAll = !_showAll),
                  child: Text(
                    _showAll
                        ? 'Thu gọn'
                        : 'Xem thêm ${group.documents.length - 5} phiếu',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _DocumentChildRow extends StatelessWidget {
  const _DocumentChildRow({
    required this.doc,
    required this.groupTitle,
    required this.treatmentCode,
  });

  final EmrDocument doc;
  final String groupTitle;
  final String treatmentCode;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      onTap: () => context.push(
        AppRoutes.emrDocumentPath(treatmentCode, doc.documentId),
        extra: doc.name,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const SizedBox(width: 4),
            const Icon(Icons.picture_as_pdf_outlined,
                size: 20, color: AppColors.primaryDark),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _documentItemTitle(doc, groupTitle),
                    style: AppTypography.body.copyWith(fontSize: 14.5),
                  ),
                  if (doc.date != '—') ...[
                    const SizedBox(height: 2),
                    Text(
                      doc.date,
                      style: AppTypography.caption.copyWith(fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                size: 20, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }
}
