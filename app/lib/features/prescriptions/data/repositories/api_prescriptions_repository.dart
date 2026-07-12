import 'package:dio/dio.dart';
import 'package:intl/intl.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/result.dart';
import '../models/prescription.dart';
import 'prescriptions_repository.dart';

class ApiPrescriptionsRepository implements PrescriptionsRepository {
  ApiPrescriptionsRepository(this._dio);

  final Dio _dio;

  @override
  Future<Result<Prescription>> getPrescription(String resultId) => apiCall(
        () => _dio.get('/patient/results/$resultId/prescription'),
        (json) => _mapPrescription((json as Map).cast<String, dynamic>()),
      );

  @override
  Future<Result<List<MedicationDose>>> getTodayDoses() => apiCall(
        () => _dio.get('/patient/medication/doses/today'),
        (json) => (json as List)
            .map((e) => _mapDose((e as Map).cast<String, dynamic>()))
            .toList(),
      );

  @override
  Future<Result<void>> markDoseTaken(String doseId, bool taken) => apiCallVoid(
        () => _dio.post(
          '/patient/medication/doses/$doseId/taken',
          data: {'taken': taken},
        ),
      );

  Prescription _mapPrescription(Map<String, dynamic> json) {
    final items = ((json['items'] as List?) ?? const [])
        .map((e) => (e as Map).cast<String, dynamic>())
        .toList();
    final medications = items.map(_mapMedication).toList();
    final durationDays = medications
        .map((m) => _firstNumber(m.days))
        .fold<int>(0, (max, value) => value > max ? value : max);

    return Prescription(
      // BE currently returns prescription items only; result date stays on ResultDto.
      examDate: '',
      durationDays: durationDays,
      medications: medications,
    );
  }

  Medication _mapMedication(Map<String, dynamic> json) {
    final dosage = (json['dosage'] as String?) ?? '';
    final frequency = (json['frequency'] as String?) ?? '';
    final duration = (json['duration'] as String?) ?? '';
    return Medication(
      name: (json['drugName'] as String?) ?? '',
      strength: dosage,
      days: duration.toUpperCase(),
      times: frequency.isEmpty ? const [] : [frequency],
      note: (json['note'] as String?) ?? '',
    );
  }

  MedicationDose _mapDose(Map<String, dynamic> json) {
    final doseAt = DateTime.parse(json['doseAtUtc'] as String).toLocal();
    final dosage = (json['dosage'] as String?) ?? '';
    return MedicationDose(
      id: json['doseId'].toString(),
      time: DateFormat('HH:mm').format(doseAt),
      name: (json['drugName'] as String?) ?? '',
      note: dosage,
      taken: (json['taken'] as bool?) ?? false,
    );
  }

  int _firstNumber(String text) {
    final match = RegExp(r'\d+').firstMatch(text);
    return match == null ? 0 : int.tryParse(match.group(0)!) ?? 0;
  }
}
