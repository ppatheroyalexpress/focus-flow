import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/timer_model.dart';
import '../utils/sound_player.dart';

class TimerProvider with ChangeNotifier {
  late TimerState _state;
  Timer? _timer;
  final SoundPlayer _soundPlayer = SoundPlayer();

  // History
  List<DateTime> _history = [];

  // Settings
  int workDuration = 25;
  int shortBreakDuration = 5;
  int longBreakDuration = 15;
  int sessionsBeforeLongBreak = 4;
  bool isSoundEnabled = true;
  bool autoStartBreaks = false;
  bool isStrictMode = false;

  Timer? _emergencyTimer;
  double emergencyProgress = 0.0;

  TimerProvider() {
    _state = TimerState(
      duration: Duration(minutes: workDuration),
      remainingSeconds: workDuration * 60,
      isRunning: false,
      sessionType: SessionType.work,
      sessionCount: 0,
    );
    _loadSettings();
  }

  TimerState get state => _state;
  List<DateTime> get history => _history;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    workDuration = prefs.getInt('workDuration') ?? 25;
    shortBreakDuration = prefs.getInt('shortBreakDuration') ?? 5;
    longBreakDuration = prefs.getInt('longBreakDuration') ?? 15;
    isSoundEnabled = prefs.getBool('isSoundEnabled') ?? true;
    autoStartBreaks = prefs.getBool('autoStartBreaks') ?? false;
    isStrictMode = prefs.getBool('isStrictMode') ?? false;
    
    final savedCount = prefs.getInt('sessionCount') ?? 0;
    
    // Load History
    final historyStrings = prefs.getStringList('sessionHistory') ?? [];
    _history = historyStrings.map((s) => DateTime.parse(s)).toList();

    _state = _state.copyWith(
      duration: Duration(minutes: _getDurationForType(_state.sessionType)),
      remainingSeconds: _getDurationForType(_state.sessionType) * 60,
      sessionCount: savedCount,
    );
    notifyListeners();
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('workDuration', workDuration);
    await prefs.setInt('shortBreakDuration', shortBreakDuration);
    await prefs.setInt('longBreakDuration', longBreakDuration);
    await prefs.setBool('isSoundEnabled', isSoundEnabled);
    await prefs.setBool('autoStartBreaks', autoStartBreaks);
    await prefs.setBool('isStrictMode', isStrictMode);
    await prefs.setInt('sessionCount', _state.sessionCount);
    
    // Save History
    final historyStrings = _history.map((d) => d.toIso8601String()).toList();
    await prefs.setStringList('sessionHistory', historyStrings);
  }

  void updateSettings({
    int? newWork,
    int? newShort,
    int? newLong,
    bool? newSound,
    bool? newAutoStart,
    bool? newStrictMode,
  }) {
    if (newWork != null) workDuration = newWork;
    if (newShort != null) shortBreakDuration = newShort;
    if (newLong != null) longBreakDuration = newLong;
    if (newSound != null) isSoundEnabled = newSound;
    if (newAutoStart != null) autoStartBreaks = newAutoStart;
    if (newStrictMode != null) isStrictMode = newStrictMode;

    // Reset current timer if duration for current session type changed
    final currentTypeDuration = _getDurationForType(_state.sessionType);
    _state = _state.copyWith(
      duration: Duration(minutes: currentTypeDuration),
      remainingSeconds: currentTypeDuration * 60,
      isRunning: false,
    );
    _timer?.cancel();
    
    _saveSettings();
    notifyListeners();
  }

  void startTimer() {
    if (_state.isRunning) return;

    _state = _state.copyWith(isRunning: true);
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_state.remainingSeconds > 0) {
        _state = _state.copyWith(remainingSeconds: _state.remainingSeconds - 1);
        notifyListeners();
      } else {
        completeSession();
      }
    });
  }

  void pauseTimer() {
    if (isStrictMode && _state.sessionType == SessionType.work && _state.isRunning) {
      // In strict mode, cannot pause during work sessions
      return;
    }
    _timer?.cancel();
    _state = _state.copyWith(isRunning: false);
    notifyListeners();
  }

  void resetTimer() {
    if (isStrictMode && _state.sessionType == SessionType.work && _state.isRunning) {
      // In strict mode, cannot reset during work sessions
      return;
    }
    _timer?.cancel();
    final durationMinutes = _getDurationForType(_state.sessionType);
    _state = _state.copyWith(
      remainingSeconds: durationMinutes * 60,
      isRunning: false,
    );
    notifyListeners();
  }

  Future<void> completeSession() async {
    _timer?.cancel();
    _state = _state.copyWith(isRunning: false);
    
    // Play notification sound
    if (isSoundEnabled) {
      _soundPlayer.playSessionComplete();
    }

    // Increment session count and history if it was a work session
    int newSessionCount = _state.sessionCount;
    if (_state.sessionType == SessionType.work) {
      newSessionCount++;
      _history.add(DateTime.now());
    }

    _state = _state.copyWith(sessionCount: newSessionCount);
    await _saveSettings();
    notifyListeners();
    
    // Move to next session
    moveToNextSession();
    
    // Auto-start next session if it's a break and autoStartBreaks is true
    if (autoStartBreaks && _state.sessionType != SessionType.work) {
      startTimer();
    }
  }

  void moveToNextSession() {
    SessionType nextType;
    
    if (_state.sessionType == SessionType.work) {
      if (_state.sessionCount % sessionsBeforeLongBreak == 0 && _state.sessionCount > 0) {
        nextType = SessionType.longBreak;
      } else {
        nextType = SessionType.shortBreak;
      }
    } else {
      nextType = SessionType.work;
    }

    int durationMinutes = _getDurationForType(nextType);
    
    _state = _state.copyWith(
      sessionType: nextType,
      duration: Duration(minutes: durationMinutes),
      remainingSeconds: durationMinutes * 60,
      isRunning: false,
    );
    notifyListeners();
  }

  int _getDurationForType(SessionType type) {
    switch (type) {
      case SessionType.work:
        return workDuration;
      case SessionType.shortBreak:
        return shortBreakDuration;
      case SessionType.longBreak:
        return longBreakDuration;
    }
  }

  void startEmergencyExit() {
    _emergencyTimer?.cancel();
    emergencyProgress = 0.0;
    _emergencyTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      emergencyProgress += 0.02; // 100ms * 50 = 5000ms
      if (emergencyProgress >= 1.0) {
        emergencyProgress = 1.0;
        _emergencyTimer?.cancel();
      }
      notifyListeners();
    });
  }

  void confirmEmergencyExit() {
    _forceExitStrictMode();
    cancelEmergencyExit();
  }

  void cancelEmergencyExit() {
    _emergencyTimer?.cancel();
    emergencyProgress = 0.0;
    notifyListeners();
  }

  void _forceExitStrictMode() {
    _timer?.cancel();
    final durationMinutes = _getDurationForType(_state.sessionType);
    _state = _state.copyWith(
      remainingSeconds: durationMinutes * 60,
      isRunning: false,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emergencyTimer?.cancel();
    _soundPlayer.dispose();
    super.dispose();
  }
}
