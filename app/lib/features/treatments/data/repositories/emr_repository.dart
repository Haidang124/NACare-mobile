import '../../../../core/network/result.dart';
import '../models/emr_document.dart';
import '../models/emr_file.dart';

/// Tách UI khỏi nguồn dữ liệu EMR (phiếu + file PDF) của một lần điều trị.
abstract class EmrRepository {
  /// Danh sách phiếu EMR của lần điều trị; [type] lọc theo loại (vd 'Phiếu kết quả'), null = tất cả.
  Future<Result<List<EmrDocument>>> getDocuments({
    required String profileId,
    required String treatmentCode,
    String? type,
  });

  /// Tải file PDF của một phiếu EMR.
  Future<Result<EmrFile>> getDocumentFile({
    required String profileId,
    required String treatmentCode,
    required String documentId,
    required String fileName,
  });
}
