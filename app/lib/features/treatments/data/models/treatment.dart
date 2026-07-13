import 'package:flutter/foundation.dart';

/// Một lần điều trị / lượt khám (encounter) của hồ sơ, map từ `TreatmentDto` của BE
/// (đọc từ HIS). `treatmentCode` là khoá để mở danh sách phiếu EMR ở bước sau.
@immutable
class Treatment {
  const Treatment({
    required this.treatmentCode,
    required this.date,
    required this.inTime,
    required this.icdCode,
    required this.icdName,
    required this.typeName,
    required this.department,
    required this.reason,
  });

  final String treatmentCode;

  /// Ngày vào (đã format dd/MM/yyyy) hoặc '—' nếu HIS không trả.
  final String date;

  /// Thời điểm vào gốc — để sắp xếp/nhóm; null nếu HIS không trả.
  final DateTime? inTime;

  final String icdCode;
  final String icdName;
  final String typeName;
  final String department;
  final String reason;

  /// Tiêu đề hiển thị: ưu tiên chẩn đoán (ICD), rồi loại điều trị, rồi lý do khám.
  String get title {
    if (icdName.isNotEmpty) return icdName;
    if (typeName.isNotEmpty) return typeName;
    if (reason.isNotEmpty) return reason;
    return 'Lần điều trị $treatmentCode';
  }
}
