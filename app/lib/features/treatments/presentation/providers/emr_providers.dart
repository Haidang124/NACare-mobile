import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/config_providers.dart';
import '../../../../core/network/api_providers.dart';
import '../../../../core/network/mock_config.dart';
import '../../../../core/network/result.dart';
import '../../../patient_profiles/presentation/providers/patient_profiles_providers.dart';
import '../../data/models/emr_document.dart';
import '../../data/models/emr_file.dart';
import '../../data/repositories/api_emr_repository.dart';
import '../../data/repositories/emr_repository.dart';
import '../../data/repositories/mock_emr_repository.dart';

/// Mock ↔ API thật theo cờ [useMockProvider].
final emrRepositoryProvider = Provider<EmrRepository>((ref) {
  if (ref.watch(useMockProvider)) {
    return MockEmrRepository(ref.watch(mockConfigProvider));
  }
  return ApiEmrRepository(ref.watch(dioProvider));
});

/// Danh sách phiếu EMR của một lần điều trị (khoá theo treatmentCode).
/// autoDispose để rời màn là giải phóng; đọc profileId từ hồ sơ đang chọn.
final treatmentDocumentsProvider = FutureProvider.autoDispose
    .family<List<EmrDocument>, String>((ref, treatmentCode) async {
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const [];
  return (await ref.watch(emrRepositoryProvider).getDocuments(
            profileId: profile.id,
            treatmentCode: treatmentCode,
          ))
      .dataOrThrow;
});

/// Khoá tải file PDF: cần cả treatmentCode + documentId + tên hiển thị (đặt tên file tải về).
typedef EmrFileKey = ({String treatmentCode, String documentId, String fileName});

/// Tải file PDF của một phiếu EMR (khoá theo [EmrFileKey]).
final emrFileProvider =
    FutureProvider.autoDispose.family<EmrFile, EmrFileKey>((ref, key) async {
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) {
    throw const AppFailure('Chưa có hồ sơ. Vui lòng liên kết hồ sơ bệnh nhân.',
        retryable: false);
  }
  return (await ref.watch(emrRepositoryProvider).getDocumentFile(
            profileId: profile.id,
            treatmentCode: key.treatmentCode,
            documentId: key.documentId,
            fileName: key.fileName,
          ))
      .dataOrThrow;
});
