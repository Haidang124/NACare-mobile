import '../../../../core/network/result.dart';
import '../../../appointments/data/models/queue_status.dart';

abstract class CheckinRepository {
  Future<Result<void>> checkin(String appointmentId);
  Future<Result<QueueStatus>> getQueueStatus(String appointmentId);
}
