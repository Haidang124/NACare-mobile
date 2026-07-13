import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/config_providers.dart';
import '../../../../core/network/api_providers.dart';
import '../../../../core/network/mock_config.dart';
import '../../../patient_profiles/presentation/providers/patient_profiles_providers.dart';
import '../../data/models/treatment.dart';
import '../../data/repositories/api_treatments_repository.dart';
import '../../data/repositories/mock_treatments_repository.dart';
import '../../data/repositories/treatments_repository.dart';

/// Mock ↔ API thật theo cờ [useMockProvider]; màn/list phía dưới không đổi.
final treatmentsRepositoryProvider = Provider<TreatmentsRepository>((ref) {
  if (ref.watch(useMockProvider)) {
    return MockTreatmentsRepository(ref.watch(mockConfigProvider));
  }
  return ApiTreatmentsRepository(ref.watch(dioProvider));
});

/// Năm đang lọc — mặc định năm hiện tại. Đổi từ hàng chip trên màn.
final treatmentsYearProvider =
    StateProvider<int>((ref) => DateTime.now().year);

/// Danh sách lần điều trị của hồ sơ đang chọn theo năm đang lọc.
/// autoDispose để đổi hồ sơ/năm là nạp lại; chưa có hồ sơ ⇒ rỗng (chưa liên kết HIS).
final treatmentsProvider =
    FutureProvider.autoDispose<List<Treatment>>((ref) async {
  final profile = ref.watch(activeProfileProvider);
  if (profile == null) return const [];
  final year = ref.watch(treatmentsYearProvider);
  return (await ref
          .watch(treatmentsRepositoryProvider)
          .getTreatments(profileId: profile.id, year: year))
      .dataOrThrow;
});
