import 'dart:convert';
import 'dart:typed_data';

import '../../../../core/network/mock_config.dart';
import '../../../../core/network/result.dart';
import '../models/emr_document.dart';
import '../models/emr_file.dart';
import 'emr_repository.dart';

/// Dữ liệu mẫu cho phiếu EMR + một file PDF hợp lệ (tự dựng, đủ xref để renderer native
/// đọc được) để demo màn xem phiếu khi chưa nối BE.
class MockEmrRepository implements EmrRepository {
  MockEmrRepository(this._config);

  final MockConfig _config;

  @override
  Future<Result<List<EmrDocument>>> getDocuments({
    required String profileId,
    required String treatmentCode,
    String? type,
  }) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    if (_config.forceEmpty) return const Result.success([]);
    return const Result.success([
      EmrDocument(
        documentId: 'doc-1',
        code: 'PKQ-001',
        name: 'Phiếu kết quả xét nghiệm máu',
        typeName: 'Phiếu kết quả',
        fileType: 'pdf',
        date: '12/09/2026',
      ),
      EmrDocument(
        documentId: 'doc-2',
        code: 'DT-001',
        name: 'Đơn thuốc ngoại trú',
        typeName: 'Đơn thuốc',
        fileType: 'pdf',
        date: '12/09/2026',
      ),
    ]);
  }

  @override
  Future<Result<EmrFile>> getDocumentFile({
    required String profileId,
    required String treatmentCode,
    required String documentId,
    required String fileName,
  }) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    return Result.success(
      EmrFile(fileName: fileName, bytes: _demoPdf()),
    );
  }

  /// Dựng một PDF 1 trang tối giản nhưng **đúng chuẩn** (header + 5 object + bảng xref
  /// tính đúng offset + trailer). Toàn bộ nội dung là ASCII nên `String.length` == số byte.
  Uint8List _demoPdf() {
    const streamContent =
        'BT /F1 18 Tf 40 150 Td (NAHealth - phieu ket qua) Tj '
        '0 -28 Td (Ban PDF demo - chua noi BE) Tj ET';
    final objects = <String>[
      '<< /Type /Catalog /Pages 2 0 R >>',
      '<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
      '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 250] '
          '/Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>',
      '<< /Length ${streamContent.length} >>\nstream\n$streamContent\nendstream',
      '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>',
    ];

    final buffer = StringBuffer('%PDF-1.4\n');
    final offsets = <int>[];
    for (var i = 0; i < objects.length; i++) {
      offsets.add(buffer.length);
      buffer.write('${i + 1} 0 obj\n${objects[i]}\nendobj\n');
    }

    final xrefOffset = buffer.length;
    buffer.write('xref\n0 ${objects.length + 1}\n');
    buffer.write('0000000000 65535 f \n');
    for (final off in offsets) {
      buffer.write('${off.toString().padLeft(10, '0')} 00000 n \n');
    }
    buffer
      ..write('trailer\n<< /Size ${objects.length + 1} /Root 1 0 R >>\n')
      ..write('startxref\n$xrefOffset\n%%EOF');

    return Uint8List.fromList(ascii.encode(buffer.toString()));
  }
}
