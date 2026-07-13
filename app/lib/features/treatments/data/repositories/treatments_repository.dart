import '../../../../core/network/result.dart';
import '../models/treatment.dart';

/// Tách UI khỏi nguồn dữ liệu lần điều trị — presentation chỉ phụ thuộc interface này,
/// không biết phía sau là mock hay HIS (qua BE).
abstract class TreatmentsRepository {
  /// Danh sách lần điều trị của hồ sơ theo [year] (mặc định cả năm), tuỳ chọn lọc [month].
  Future<Result<List<Treatment>>> getTreatments({
    required String profileId,
    required int year,
    int? month,
  });
}
