import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/booking_draft.dart';
import '../../data/models/specialty.dart';

/// Drives the 5 booking steps (Flow B). Lives in presentation because this is pure
/// UI navigation state (not domain data) — the selectable data (specialty, doctor,
/// date/time) still comes from [appointmentsRepositoryProvider].
class BookingState {
  const BookingState({this.step = 1, this.draft = const BookingDraft()});

  final int step;
  final BookingDraft draft;

  static const int totalSteps = 5;

  static const _stepNames = [
    'Chọn hồ sơ',
    'Chọn chuyên khoa',
    'Chọn ngày giờ',
    'Lý do khám',
    'Xác nhận'
  ];
  String get stepName => _stepNames[step - 1];

  bool get canGoNext => switch (step) {
        1 => draft.hasProfile,
        2 => draft.hasSpecialty,
        3 => draft.hasDateTime,
        _ => true,
      };

  BookingState copyWith({int? step, BookingDraft? draft}) {
    return BookingState(step: step ?? this.step, draft: draft ?? this.draft);
  }
}

class BookingController extends Notifier<BookingState> {
  @override
  BookingState build() => const BookingState();

  void selectProfile(String id, String name) {
    state = state.copyWith(
        draft: state.draft.copyWith(profileId: id, profileName: name));
  }

  void selectSpecialty(Specialty specialty) {
    state = state.copyWith(draft: state.draft.copyWith(specialty: specialty));
  }

  void selectDoctor(Doctor doctor) {
    state = state.copyWith(draft: state.draft.copyWith(doctor: doctor));
  }

  void selectDate(BookingDateOption date) {
    state = state.copyWith(
        draft: state.draft.copyWith(date: date, clearTime: true));
  }

  void selectTime(BookingTimeOption time) {
    state = state.copyWith(draft: state.draft.copyWith(time: time));
  }

  void setReason(String reason) {
    state = state.copyWith(draft: state.draft.copyWith(reason: reason));
  }

  bool goNext() {
    if (!state.canGoNext) return false;
    if (state.step < BookingState.totalSteps) {
      state = state.copyWith(step: state.step + 1);
      return false;
    }
    return true; // last step -> tell the screen to call submitBooking
  }

  /// true if it stepped back past step 1 (the screen exits the flow when false).
  bool goBack() {
    if (state.step <= 1) return false;
    state = state.copyWith(step: state.step - 1);
    return true;
  }

  void reset() => state = const BookingState();
}

final bookingControllerProvider =
    NotifierProvider<BookingController, BookingState>(BookingController.new);
