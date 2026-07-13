import 'package:flutter/foundation.dart';

/// Một hồ sơ bệnh nhân HIS tìm được qua `POST /patient/his-search` (theo CCCD, kèm
/// họ tên/ngày sinh nếu có). Dữ liệu đã được BE **che bớt** (tên/SĐT masked) vì bệnh
/// nhân chưa xác nhận đây là mình — map từ `HisPatientCandidateDto` (Flow A, bước 3).
@immutable
class LinkedPatientMatch {
  const LinkedPatientMatch({
    required this.hisPatientCode,
    required this.maskedName,
    required this.maskedBirthYear,
    required this.gender,
    required this.maskedPhone,
    required this.matchLevel,
    required this.initials,
  });

  /// Mã bệnh nhân HIS — khoá để gọi `POST /patient/link-profile`.
  final String hisPatientCode;
  final String maskedName;

  /// Năm sinh (đã che) hoặc '—' nếu BE không trả.
  final String maskedBirthYear;
  final String gender;

  /// SĐT đã che, dùng để bệnh nhân đối chiếu ("có phải số của tôi không").
  final String maskedPhone;

  /// Độ khớp do BE chấm ("Exact"/"Partial"...) — hiện chỉ để hiển thị/ưu tiên.
  final String matchLevel;
  final String initials;
}
