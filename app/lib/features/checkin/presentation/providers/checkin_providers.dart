import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/config_providers.dart';
import '../../../../core/network/api_providers.dart';
import '../../../../core/network/mock_config.dart';
import '../../../appointments/data/models/queue_status.dart';
import '../../data/repositories/api_checkin_repository.dart';
import '../../data/repositories/checkin_repository.dart';
import '../../data/repositories/mock_checkin_repository.dart';

final checkinRepositoryProvider = Provider<CheckinRepository>((ref) {
  if (ref.watch(useMockProvider)) {
    return MockCheckinRepository(ref.watch(mockConfigProvider));
  }
  return ApiCheckinRepository(ref.watch(dioProvider));
});

final activeCheckinAppointmentIdProvider = StateProvider<String>((ref) => 'a1');

final queueStatusProvider =
    FutureProvider.autoDispose<QueueStatus>((ref) async {
  final appointmentId = ref.watch(activeCheckinAppointmentIdProvider);
  return (await ref.watch(checkinRepositoryProvider).getQueueStatus(appointmentId))
      .dataOrThrow;
});
