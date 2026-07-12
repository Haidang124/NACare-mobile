import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/config_providers.dart';
import 'api_client.dart';
import 'auth_events.dart';
import 'token_store.dart';

/// [Dio] dùng chung, ráp từ env + token store.
///
/// Tầng composition: khi 401 (bản stub) nó phát [unauthorizedSignalProvider]; auth
/// feature lắng nghe tín hiệu đó để logout. Nhờ đi qua signal, provider này không
/// import feature auth ⇒ không có vòng import khi `ApiAuthRepository` cần `dioProvider`.
final dioProvider = Provider<Dio>((ref) {
  final env = ref.watch(appEnvProvider);
  final tokens = ref.watch(tokenStoreProvider);
  return buildDio(
    env: env,
    tokens: tokens,
    onUnauthorized: () =>
        ref.read(unauthorizedSignalProvider.notifier).state++,
  );
});
