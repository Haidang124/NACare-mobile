import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/mock_config.dart';
import '../../../patient_profiles/presentation/providers/patient_profiles_providers.dart';
import '../../data/models/home_dashboard.dart';
import '../../data/repositories/home_repository.dart';
import '../../data/repositories/mock_home_repository.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return MockHomeRepository(ref.watch(mockConfigProvider));
});

final homeDashboardProvider = FutureProvider<HomeDashboard>((ref) async {
  final profile = ref.watch(activeProfileProvider);
  final repo = ref.watch(homeRepositoryProvider);
  return (await repo.getDashboard(profileId: profile?.id ?? 'p1')).dataOrThrow;
});
