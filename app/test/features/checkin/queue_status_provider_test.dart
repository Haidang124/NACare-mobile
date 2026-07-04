// Reference example for the provider-test convention (see docs/architecture/05, "Test").
//
// The mock-repository design lets us test provider logic WITHOUT a backend and WITHOUT
// building UI: just override `xxxRepositoryProvider` with a fake repo and read the
// provider through a `ProviderContainer`. This is the biggest payoff of always routing
// the UI through an interface + provider — copy this file as a template for other features.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nahealth_app/core/network/result.dart';
import 'package:nahealth_app/features/appointments/data/models/queue_status.dart';
import 'package:nahealth_app/features/checkin/data/repositories/checkin_repository.dart';
import 'package:nahealth_app/features/checkin/presentation/providers/checkin_providers.dart';

/// Fake repo returning fixed data — no delay, no randomness — so tests run fast and
/// deterministically (unlike Mock*Repository, which adds fake delay/randomness for demos).
class _FakeCheckinRepository implements CheckinRepository {
  _FakeCheckinRepository(this._status);

  final QueueStatus _status;

  @override
  Future<Result<void>> checkin(String appointmentId) async =>
      const Result.success(null);

  @override
  Future<Result<QueueStatus>> getQueueStatus(String appointmentId) async =>
      Result.success(_status);
}

void main() {
  test('queueStatusProvider returns data from the overridden repository',
      () async {
    const expected = QueueStatus(
      myNumber: 7,
      currentlyServing: 5,
      room: '101',
      estimatedWaitMinutes: 10,
      journey: [],
    );

    final container = ProviderContainer(
      overrides: [
        checkinRepositoryProvider
            .overrideWithValue(_FakeCheckinRepository(expected)),
      ],
    );
    addTearDown(container.dispose);

    final result = await container.read(queueStatusProvider.future);

    expect(result.myNumber, 7);
    expect(result.room, '101');
  });
}
