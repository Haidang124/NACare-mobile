import '../../../../core/network/mock_config.dart';
import '../../../../core/network/result.dart';
import '../../../appointments/data/models/queue_status.dart';
import 'checkin_repository.dart';

class MockCheckinRepository implements CheckinRepository {
  MockCheckinRepository(this._config);

  final MockConfig _config;

  @override
  Future<Result<void>> checkin(String appointmentId) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    return const Result.success(null);
  }

  @override
  Future<Result<QueueStatus>> getQueueStatus(String appointmentId) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    return const Result.success(
      QueueStatus(
        myNumber: 24,
        currentlyServing: 18,
        room: '305',
        estimatedWaitMinutes: 30,
        journey: [
          JourneyStep(
              title: 'Tiếp nhận & check-in',
              subtitle: 'Hoàn thành lúc 08:52',
              state: JourneyStepState.done),
          JourneyStep(
              title: 'Khám Tim mạch — Phòng 305',
              subtitle: 'Đang chờ · số 24',
              state: JourneyStepState.current),
          JourneyStep(
              title: 'Xét nghiệm (nếu có chỉ định)',
              subtitle: 'Khu B, tầng 2',
              state: JourneyStepState.upcoming),
          JourneyStep(
              title: 'Thanh toán & nhận thuốc',
              subtitle: 'Quầy thu ngân tầng 1',
              state: JourneyStepState.upcoming),
        ],
      ),
    );
  }
}
