import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/config_providers.dart';
import '../../../../core/network/api_providers.dart';
import '../../../../core/network/mock_config.dart';
import '../../data/models/security_settings.dart';
import '../../data/repositories/api_security_repository.dart';
import '../../data/repositories/mock_security_repository.dart';
import '../../data/repositories/security_repository.dart';

final securityRepositoryProvider = Provider<SecurityRepository>((ref) {
  if (!ref.watch(useMockProvider)) {
    return ApiSecurityRepository(ref.watch(dioProvider));
  }
  return MockSecurityRepository(ref.watch(mockConfigProvider));
});

final securityTogglesProvider =
    FutureProvider.autoDispose<List<SecurityToggle>>((ref) async {
  return (await ref.watch(securityRepositoryProvider).getToggles()).dataOrThrow;
});

final loggedInDevicesProvider =
    FutureProvider.autoDispose<List<LoggedInDevice>>((ref) async {
  return (await ref.watch(securityRepositoryProvider).getDevices()).dataOrThrow;
});

final consentItemsProvider =
    FutureProvider.autoDispose<List<ConsentItem>>((ref) async {
  return (await ref.watch(securityRepositoryProvider).getConsentItems())
      .dataOrThrow;
});
