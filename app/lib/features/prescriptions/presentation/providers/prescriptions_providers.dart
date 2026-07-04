import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/mock_config.dart';
import '../../data/models/prescription.dart';
import '../../data/repositories/mock_prescriptions_repository.dart';
import '../../data/repositories/prescriptions_repository.dart';

final prescriptionsRepositoryProvider =
    Provider<PrescriptionsRepository>((ref) {
  return MockPrescriptionsRepository(ref.watch(mockConfigProvider));
});

final prescriptionProvider = FutureProvider.autoDispose
    .family<Prescription, String>((ref, resultId) async {
  return (await ref
          .watch(prescriptionsRepositoryProvider)
          .getPrescription(resultId))
      .dataOrThrow;
});

final todayDosesProvider =
    FutureProvider.autoDispose<List<MedicationDose>>((ref) async {
  return (await ref.watch(prescriptionsRepositoryProvider).getTodayDoses())
      .dataOrThrow;
});
