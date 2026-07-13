import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/result.dart';
import '../../../../core/utils/formatting.dart';
import '../models/treatment.dart';
import 'treatments_repository.dart';

/// Bản thật của [TreatmentsRepository] — module Patients của BE (đọc HIS, cache Postgres).
///   GET /patient/profiles/{profileId}/treatments?year={year}&month={month}
///
/// BE trả `TreatmentDto(treatmentCode, inTime?, icdCode?, icdName?, treatmentTypeName?,
/// departmentName?, reason?)`. Lưu ý (memory treatment-cache): năm hiện tại có thể trả `[]`
/// nếu HIS chưa có dữ liệu — UI xử lý bằng empty state.
class ApiTreatmentsRepository implements TreatmentsRepository {
  ApiTreatmentsRepository(this._dio);

  final Dio _dio;

  @override
  Future<Result<List<Treatment>>> getTreatments({
    required String profileId,
    required int year,
    int? month,
  }) =>
      apiCall(
        () => _dio.get(
          '/patient/profiles/$profileId/treatments',
          queryParameters: {
            'year': year,
            if (month != null) 'month': month,
          },
        ),
        (json) => (json as List)
            .map((e) => _map((e as Map).cast<String, dynamic>()))
            .toList(),
      );

  Treatment _map(Map<String, dynamic> j) {
    final inTimeRaw = j['inTime'] as String?;
    final inTime = inTimeRaw == null ? null : DateTime.tryParse(inTimeRaw);
    return Treatment(
      treatmentCode: j['treatmentCode'].toString(),
      date: inTime == null ? '—' : vnDate(inTime),
      inTime: inTime,
      icdCode: (j['icdCode'] as String?) ?? '',
      icdName: (j['icdName'] as String?) ?? '',
      typeName: (j['treatmentTypeName'] as String?) ?? '',
      department: (j['departmentName'] as String?) ?? '',
      reason: (j['reason'] as String?) ?? '',
    );
  }
}
