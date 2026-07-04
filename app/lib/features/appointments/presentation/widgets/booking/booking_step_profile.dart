import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_typography.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../../patient_profiles/data/models/patient_profile.dart';
import '../../../../patient_profiles/presentation/providers/patient_profiles_providers.dart';
import '../../providers/booking_controller.dart';
import 'booking_shared.dart';

/// Step 1: choose the patient profile for the visit.
class BookingStepProfile extends ConsumerWidget {
  const BookingStepProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profilesAsync = ref.watch(patientProfilesProvider);
    final selectedId = ref.watch(bookingControllerProvider).draft.profileId;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ai sẽ đi khám?',
            style: AppTypography.bodyBold.copyWith(fontSize: 16)),
        const SizedBox(height: 12),
        AsyncValueView<List<PatientProfile>>(
          value: profilesAsync,
          onRetry: () => ref.invalidate(patientProfilesProvider),
          data: (context, profiles) => Column(
            children: profiles.map((p) {
              final selected = p.id == selectedId;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: BookingSelectableTile(
                  selected: selected,
                  onTap: () => ref
                      .read(bookingControllerProvider.notifier)
                      .selectProfile(p.id, p.fullName),
                  leading: AppAvatar(
                      initials: p.initials,
                      background: p.avatarColor,
                      size: 46),
                  title: p.fullName,
                  subtitle: '${p.relationship} · ${p.birthYear}',
                  trailing: BookingRadio(selected: selected),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
