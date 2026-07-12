import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/result.dart';
import '../../../../core/utils/formatting.dart';
import '../models/patient_profile.dart';
import 'patient_profiles_repository.dart';

/// Bản thật của [PatientProfilesRepository] — module Patients của BE.
///   GET  /patient/profiles          → danh sách hồ sơ (bản thân + người thân)
///   POST /patient/profiles/family   → thêm hồ sơ người thân
///
/// BE trả `ProfileDto(id, hisPatientCode?, relationshipType, linkStatus, fullName?, birthYear?)`.
class ApiPatientProfilesRepository implements PatientProfilesRepository {
  ApiPatientProfilesRepository(this._dio);

  final Dio _dio;

  @override
  Future<Result<List<PatientProfile>>> getProfiles() => apiCall(
        () => _dio.get('/patient/profiles'),
        (json) => (json as List)
            .map((e) => _mapProfile((e as Map).cast<String, dynamic>()))
            .toList(),
      );

  @override
  Future<Result<void>> addFamilyMember({
    required String fullName,
    required int birthYear,
  }) =>
      apiCallVoid(
        () => _dio.post('/patient/profiles/family', data: {
          'name': fullName,
          'birthYear': birthYear,
          'relationship': 'Family',
        }),
      );

  PatientProfile _mapProfile(Map<String, dynamic> j) {
    final rel = (j['relationshipType'] as String?) ?? 'Family';
    final isSelf = rel.toLowerCase() == 'self';
    final name = (j['fullName'] as String?) ?? '(Chưa có tên)';
    final id = j['id'].toString();
    return PatientProfile(
      id: id,
      fullName: name,
      initials: initialsFrom(name),
      // BE chỉ phân biệt Self/Family; quan hệ chi tiết (Vợ/Cháu...) sẽ tinh chỉnh sau.
      relationship: isSelf ? 'Tôi' : 'Người thân',
      birthYear: (j['birthYear'] as num?)?.toInt() ?? 0,
      avatarColor: avatarColorFor(id),
      patientCode: (j['hisPatientCode'] as String?) ?? '',
      isSelf: isSelf,
      // TODO: BE ProfileDto chưa có trạng thái BHYT → tạm coi hợp lệ.
    );
  }
}
