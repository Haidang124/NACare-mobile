import 'package:flutter/foundation.dart';

/// Một phiếu EMR của lần điều trị (phiếu kết quả, đơn thuốc…), map từ `EmrDocumentDto`.
/// `documentId` là khoá để tải file PDF.
@immutable
class EmrDocument {
  const EmrDocument({
    required this.documentId,
    required this.code,
    required this.name,
    required this.typeName,
    required this.fileType,
    required this.date,
  });

  final String documentId;
  final String code;
  final String name;
  final String typeName;

  /// Định dạng file (thường 'pdf') hoặc rỗng nếu HIS không trả.
  final String fileType;

  /// Ngày phiếu (đã format dd/MM/yyyy) hoặc '—'.
  final String date;
}
