class JourneyStep {
  const JourneyStep({
    required this.title,
    required this.subtitle,
    required this.state,
  });

  final String title;
  final String subtitle;
  final JourneyStepState state;
}

enum JourneyStepState { done, current, upcoming }

class QueueStatus {
  const QueueStatus({
    required this.myNumber,
    required this.currentlyServing,
    required this.room,
    required this.estimatedWaitMinutes,
    required this.journey,
  });

  final int myNumber;
  final int currentlyServing;
  final String room;
  final int estimatedWaitMinutes;
  final List<JourneyStep> journey;
}
