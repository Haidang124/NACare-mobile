import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/mock_config.dart';
import '../../../appointments/data/models/queue_status.dart';
import '../../data/repositories/checkin_repository.dart';
import '../../data/repositories/mock_checkin_repository.dart';

final checkinRepositoryProvider = Provider<CheckinRepository>((ref) {
  return MockCheckinRepository(ref.watch(mockConfigProvider));
});

final queueStatusProvider =
    FutureProvider.autoDispose<QueueStatus>((ref) async {
  return (await ref.watch(checkinRepositoryProvider).getQueueStatus('a1'))
      .dataOrThrow;
});
