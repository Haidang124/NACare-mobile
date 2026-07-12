import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_env.dart';

/// Single source of truth for the runtime environment.
final appEnvProvider = Provider<AppEnv>((ref) => AppEnv.fromDartDefine());

/// Công tắc mock ↔ real. Mỗi `*_providers.dart` của feature đọc cờ này để chọn
/// giữa `Mock*Repository` và `Api*Repository` — chỉ đổi ở đúng một dòng.
final useMockProvider = Provider<bool>((ref) => ref.watch(appEnvProvider).useMock);
