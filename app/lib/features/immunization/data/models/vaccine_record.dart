enum VaccineEventState { done, upcoming }

class VaccineEvent {
  const VaccineEvent(
      {required this.name, required this.info, required this.state});
  final String name;
  final String info;
  final VaccineEventState state;
}

class UpcomingVaccine {
  const UpcomingVaccine({required this.name, required this.expectedDate});
  final String name;
  final String expectedDate;
}

class ImmunizationRecord {
  const ImmunizationRecord({this.upcoming, required this.history});
  final UpcomingVaccine? upcoming;
  final List<VaccineEvent> history;
}
