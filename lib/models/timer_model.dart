enum SessionType { work, shortBreak, longBreak }

class TimerState {
  final Duration duration;
  final int remainingSeconds;
  final bool isRunning;
  final SessionType sessionType;
  final int sessionCount;

  TimerState({
    required this.duration,
    required this.remainingSeconds,
    required this.isRunning,
    required this.sessionType,
    required this.sessionCount,
  });

  TimerState copyWith({
    Duration? duration,
    int? remainingSeconds,
    bool? isRunning,
    SessionType? sessionType,
    int? sessionCount,
  }) {
    return TimerState(
      duration: duration ?? this.duration,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      sessionType: sessionType ?? this.sessionType,
      sessionCount: sessionCount ?? this.sessionCount,
    );
  }
}
