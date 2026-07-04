import '../../../../core/network/result.dart';
import '../models/home_dashboard.dart';

abstract class HomeRepository {
  Future<Result<HomeDashboard>> getDashboard({required String profileId});
}
