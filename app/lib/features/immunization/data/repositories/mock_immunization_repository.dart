import '../../../../core/network/mock_config.dart';
import '../../../../core/network/result.dart';
import '../models/vaccine_record.dart';
import 'immunization_repository.dart';

class MockImmunizationRepository implements ImmunizationRepository {
  MockImmunizationRepository(this._config);

  final MockConfig _config;

  @override
  Future<Result<ImmunizationRecord>> getRecord(String profileId) async {
    await _config.simulateDelay();
    if (_config.shouldFail) return Result.failure(AppFailure.server());
    if (_config.forceEmpty) {
      return const Result.success(ImmunizationRecord(history: []));
    }

    // Matches the mockup: an upcoming seasonal-flu banner + 4 doses already given.
    return const Result.success(
      ImmunizationRecord(
        upcoming: UpcomingVaccine(name: 'Cúm mùa', expectedDate: '15/07/2026'),
        history: [
          VaccineEvent(
              name: 'Cúm mùa (mũi 2025)',
              info: 'Đã tiêm · 10/2025 · Vaxigrip',
              state: VaccineEventState.done),
          VaccineEvent(
              name: 'Uốn ván (Td)',
              info: 'Đã tiêm · 03/2024',
              state: VaccineEventState.done),
          VaccineEvent(
              name: 'Covid-19 mũi 4',
              info: 'Đã tiêm · 11/2023 · Pfizer',
              state: VaccineEventState.done),
          VaccineEvent(
              name: 'Viêm gan B',
              info: 'Đủ 3 mũi · 2019',
              state: VaccineEventState.done),
        ],
      ),
    );
  }
}
