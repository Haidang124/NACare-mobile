import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/mock_config.dart';
import '../../../patient_profiles/presentation/providers/patient_profiles_providers.dart';
import '../../data/models/personal_info.dart';
import '../../data/repositories/mock_personal_info_repository.dart';
import '../../data/repositories/personal_info_repository.dart';

final personalInfoRepositoryProvider = Provider<PersonalInfoRepository>((ref) {
  return MockPersonalInfoRepository(ref.watch(mockConfigProvider));
});

final personalInfoProvider =
    FutureProvider.autoDispose<PersonalInfo>((ref) async {
  final profile = ref.watch(activeProfileProvider);
  return (await ref
          .watch(personalInfoRepositoryProvider)
          .getPersonalInfo(profile?.id ?? 'p1'))
      .dataOrThrow;
});
