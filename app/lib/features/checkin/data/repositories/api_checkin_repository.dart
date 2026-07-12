import 'package:dio/dio.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/result.dart';
import '../../../appointments/data/models/queue_status.dart';
import 'checkin_repository.dart';

class ApiCheckinRepository implements CheckinRepository {
  ApiCheckinRepository(this._dio);

  final Dio _dio;

  @override
  Future<Result<void>> checkin(String appointmentId) => apiCallVoid(
        () => _dio.post('/patient/appointments/$appointmentId/checkin'),
      );

  @override
  Future<Result<QueueStatus>> getQueueStatus(String appointmentId) => apiCall(
        () => _dio.get('/patient/appointments/$appointmentId/queue'),
        (json) => _mapQueue((json as Map).cast<String, dynamic>()),
      );

  QueueStatus _mapQueue(Map<String, dynamic> json) {
    final currentlyServing = (json['currentNumber'] as num?)?.toInt() ?? 0;
    final myNumber = (json['myNumber'] as num?)?.toInt() ?? 0;
    final journey = ((json['steps'] as List?) ?? const [])
        .map((e) => _mapStep((e as Map).cast<String, dynamic>()))
        .toList();

    return QueueStatus(
      myNumber: myNumber,
      currentlyServing: currentlyServing,
      room: _inferRoom(journey),
      estimatedWaitMinutes:
          (myNumber > currentlyServing ? myNumber - currentlyServing : 0) * 5,
      journey: journey,
    );
  }

  JourneyStep _mapStep(Map<String, dynamic> json) {
    final state = _mapStepState(json['state']);
    return JourneyStep(
      title: (json['name'] as String?) ?? '',
      subtitle: switch (state) {
        JourneyStepState.done => 'Đã hoàn thành',
        JourneyStepState.current => 'Đang thực hiện',
        JourneyStepState.upcoming => 'Sắp tới',
      },
      state: state,
    );
  }

  JourneyStepState _mapStepState(dynamic value) {
    if (value is int) {
      const order = [
        JourneyStepState.done,
        JourneyStepState.current,
        JourneyStepState.upcoming,
      ];
      return (value >= 0 && value < order.length)
          ? order[value]
          : JourneyStepState.upcoming;
    }
    return switch (value?.toString().toLowerCase()) {
      'done' => JourneyStepState.done,
      'current' => JourneyStepState.current,
      _ => JourneyStepState.upcoming,
    };
  }

  String _inferRoom(List<JourneyStep> steps) {
    String? current;
    for (final step in steps) {
      if (step.state == JourneyStepState.current) {
        current = step.title;
        break;
      }
    }
    if (current == null) {
      return '--';
    }

    final match = RegExp(r'(?:phòng|room)\s*([A-Za-z0-9-]+)',
            caseSensitive: false)
        .firstMatch(current);
    return match?.group(1) ?? '--';
  }
}
