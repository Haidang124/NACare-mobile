import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/result.dart';
import '../../../../core/widgets/widgets.dart';
import '../providers/emr_providers.dart';

/// Xem file PDF của một phiếu EMR trong app (render bằng flutter_pdfview từ bytes tải về).
class EmrPdfScreen extends ConsumerWidget {
  const EmrPdfScreen({
    super.key,
    required this.treatmentCode,
    required this.documentId,
    required this.documentName,
  });

  final String treatmentCode;
  final String documentId;
  final String documentName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (
      treatmentCode: treatmentCode,
      documentId: documentId,
      fileName: '$documentName.pdf',
    );
    final fileAsync = ref.watch(emrFileProvider(key));

    return Scaffold(
      appBar: AppTopBar(title: documentName, onBack: () => context.pop()),
      body: fileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) {
          final failure = error is AppFailure ? error : AppFailure.server();
          return ErrorStateView(
            message: failure.message,
            onRetry:
                failure.retryable ? () => ref.invalidate(emrFileProvider(key)) : null,
          );
        },
        data: (file) => PDFView(
          pdfData: file.bytes,
          swipeHorizontal: false,
          fitPolicy: FitPolicy.WIDTH,
          onError: (_) {},
        ),
      ),
    );
  }
}
