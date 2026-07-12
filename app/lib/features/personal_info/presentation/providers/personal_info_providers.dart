import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/config_providers.dart';
import '../../../../core/network/api_providers.dart';
import '../../../../core/network/mock_config.dart';
import '../../../patient_profiles/presentation/providers/patient_profiles_providers.dart';
import '../../data/models/personal_info.dart';
import '../../data/repositories/api_personal_info_repository.dart';
import '../../data/repositories/mock_personal_info_repository.dart';
import '../../data/repositories/personal_info_repository.dart';

final personalInfoRepositoryProvider = Provider<PersonalInfoRepository>((ref) {
  if (ref.watch(useMockProvider)) {
    return MockPersonalInfoRepository(ref.watch(mockConfigProvider));
  }
  return ApiPersonalInfoRepository(ref.watch(dioProvider));
});

final personalInfoProvider =
    FutureProvider.autoDispose<PersonalInfo>((ref) async {
  final profile = ref.watch(activeProfileProvider);
  return (await ref
          .watch(personalInfoRepositoryProvider)
          .getPersonalInfo(profile?.id ?? 'p1'))
      .dataOrThrow;
});
