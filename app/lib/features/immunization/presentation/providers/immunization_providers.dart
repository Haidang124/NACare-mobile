import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/mock_config.dart';
import '../../../patient_profiles/presentation/providers/patient_profiles_providers.dart';
import '../../data/models/vaccine_record.dart';
import '../../data/repositories/immunization_repository.dart';
import '../../data/repositories/mock_immunization_repository.dart';

final immunizationRepositoryProvider = Provider<ImmunizationRepository>((ref) {
  return MockImmunizationRepository(ref.watch(mockConfigProvider));
});

final immunizationRecordProvider =
    FutureProvider.autoDispose<ImmunizationRecord>((ref) async {
  final profile = ref.watch(activeProfileProvider);
  return (await ref
          .watch(immunizationRepositoryProvider)
          .getRecord(profile?.id ?? 'p1'))
      .dataOrThrow;
});
