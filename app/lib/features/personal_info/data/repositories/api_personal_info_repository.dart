import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/result.dart';
import '../models/personal_info.dart';
import 'personal_info_repository.dart';

/// Bản thật của [PersonalInfoRepository] — module Patients của BE (đọc HIS qua BE).
///   GET /patient/profiles/{profileId}/personal-info
///
/// BE trả `PersonalInfoDto(fullName, dateOfBirth?, gender, phoneNumber?, nationalId?,
/// address?, insuranceNumber?, email?, isComplete)` — data-shaped; app tự dựng các dòng
/// nhãn/giá trị. Một số mục UI cần mà BE chưa có (nơi ĐKKCB, hạn BHYT, tiền sử bệnh) để trống.
class ApiPersonalInfoRepository implements PersonalInfoRepository {
  ApiPersonalInfoRepository(this._dio);

  final Dio _dio;

  @override
  Future<Result<PersonalInfo>> getPersonalInfo(String profileId) => apiCall(
        () => _dio.get('/patient/profiles/$profileId/personal-info'),
        (json) => _map((json as Map).cast<String, dynamic>()),
      );

  PersonalInfo _map(Map<String, dynamic> j) {
    final admin = <AdminInfoItem>[
      AdminInfoItem(label: 'Họ và tên', value: (j['fullName'] as String?) ?? ''),
      AdminInfoItem(label: 'Ngày sinh', value: _formatDob(j['dateOfBirth'] as String?)),
      AdminInfoItem(label: 'Giới tính', value: _mapGender(j['gender'])),
      AdminInfoItem(label: 'CCCD', value: (j['nationalId'] as String?) ?? '—'),
      AdminInfoItem(label: 'Số điện thoại', value: (j['phoneNumber'] as String?) ?? '—'),
    ];
    final address = j['address'] as String?;
    if (address != null && address.isNotEmpty) {
      admin.add(AdminInfoItem(label: 'Địa chỉ', value: address));
    }
    final email = j['email'] as String?;
    if (email != null && email.isNotEmpty) {
      admin.add(AdminInfoItem(label: 'Email', value: email));
    }

    final insuranceNumber = (j['insuranceNumber'] as String?) ?? '';
    return PersonalInfo(
      adminItems: admin,
      insurance: InsuranceCard(
        number: insuranceNumber,
        registeredHospital: '', // TODO: BE chưa trả nơi đăng ký KCB.
        validUntil: '', // TODO: BE chưa trả hạn thẻ BHYT.
        isValid: insuranceNumber.isNotEmpty,
      ),
      // TODO: BE PersonalInfoDto chưa có tiền sử bệnh / dị ứng / nhóm máu.
      medical: const MedicalBackground(
        allergies: [],
        chronicConditions: '',
        bloodType: '',
      ),
    );
  }

  /// DateOnly của BE serialize dạng "yyyy-MM-dd"; format sang dd/MM/yyyy (không lệ thuộc timezone).
  String _formatDob(String? iso) {
    if (iso == null || iso.isEmpty) return '—';
    final d = DateTime.tryParse(iso);
    if (d == null) return iso;
    return DateFormat('dd/MM/yyyy').format(d);
  }

  /// Enum giới tính (Unknown/Male/Female/Other) — BE có thể trả số hoặc chuỗi.
  String _mapGender(dynamic v) {
    if (v is int) {
      return switch (v) { 1 => 'Nam', 2 => 'Nữ', 3 => 'Khác', _ => '—' };
    }
    return switch (v?.toString().toLowerCase()) {
      'male' => 'Nam',
      'female' => 'Nữ',
      'other' => 'Khác',
      _ => '—',
    };
  }
}
