import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/result.dart';
import '../../../../core/utils/formatting.dart';
import '../models/emr_document.dart';
import '../models/emr_file.dart';
import 'emr_repository.dart';

/// Bản thật của [EmrRepository] — module Patients của BE (đọc EMR qua HIS).
///   GET /patient/profiles/{profileId}/treatments/{treatmentCode}/documents?type={type}
///   GET /patient/profiles/{profileId}/treatments/{treatmentCode}/documents/{documentId}/file
///
/// File endpoint trả **binary** `application/pdf` (không phải JSON) ⇒ request bằng
/// `responseType: bytes`. Danh sách trả `EmrDocumentDto(documentId, documentCode?,
/// documentName, documentTypeName?, fileType?, documentDate?)`.
class ApiEmrRepository implements EmrRepository {
  ApiEmrRepository(this._dio);

  final Dio _dio;

  @override
  Future<Result<List<EmrDocument>>> getDocuments({
    required String profileId,
    required String treatmentCode,
    String? type,
  }) =>
      apiCall(
        () => _dio.get(
          '/patient/profiles/$profileId/treatments/$treatmentCode/documents',
          queryParameters: {if (type != null && type.isNotEmpty) 'type': type},
        ),
        (json) => (json as List)
            .map((e) => _map((e as Map).cast<String, dynamic>()))
            .toList(),
      );

  @override
  Future<Result<EmrFile>> getDocumentFile({
    required String profileId,
    required String treatmentCode,
    required String documentId,
    required String fileName,
  }) =>
      apiCall(
        () => _dio.get(
          '/patient/profiles/$profileId/treatments/$treatmentCode/documents/$documentId/file',
          options: Options(responseType: ResponseType.bytes),
        ),
        (data) => EmrFile(fileName: fileName, bytes: _toBytes(data)),
      );

  EmrDocument _map(Map<String, dynamic> j) {
    final dateRaw = j['documentDate'] as String?;
    final date = dateRaw == null ? null : DateTime.tryParse(dateRaw);
    return EmrDocument(
      documentId: j['documentId'].toString(),
      code: (j['documentCode'] as String?) ?? '',
      name: (j['documentName'] as String?) ?? 'Phiếu EMR',
      typeName: (j['documentTypeName'] as String?) ?? '',
      fileType: (j['fileType'] as String?) ?? '',
      date: date == null ? '—' : vnDate(date),
    );
  }

  Uint8List _toBytes(dynamic data) {
    if (data is Uint8List) return data;
    if (data is List<int>) return Uint8List.fromList(data);
    return Uint8List.fromList((data as List).cast<int>());
  }
}
