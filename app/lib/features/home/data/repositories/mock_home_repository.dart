import '../../../../core/network/mock_config.dart';
import '../../../../core/network/result.dart';
import '../models/home_dashboard.dart';
import 'home_repository.dart';

class MockHomeRepository implements HomeRepository {
  MockHomeRepository(this._config);

  final MockConfig _config;

  @override
  Future<Result<HomeDashboard>> getDashboard(
      {required String profileId}) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    if (_config.forceEmpty) return const Result.success(HomeDashboard());

    return const Result.success(
      HomeDashboard(
        todayAppointment: TodayAppointmentSummary(
          id: 'a1',
          timeLabel: 'HÔM NAY • 09:30',
          statusLabel: 'Đã xác nhận',
          title: 'Khám Tim mạch',
          doctorAndRoom: 'BS.CKI Trần Minh Đức · Phòng 305, Tầng 3',
        ),
        reminder: MedicationReminderSummary(
          title: 'Uống thuốc — 20:00',
          subtitle: 'Amlodipin 5mg · 1 viên sau ăn',
          remainingCount: 2,
        ),
        newResult: NewResultSummary(
          id: 'r1',
          title: 'Khám Nội tổng quát — 28/06',
          subtitle: 'Kết quả xét nghiệm đã sẵn sàng',
        ),
      ),
    );
  }
}
