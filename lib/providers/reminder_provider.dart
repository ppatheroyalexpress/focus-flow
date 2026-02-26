import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/notification_service.dart';

class ReminderProvider with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  int _reminderInterval = 15; // default 15 min
  bool _isEnabled = false;

  int get reminderInterval => _reminderInterval;
  bool get isEnabled => _isEnabled;

  ReminderProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _reminderInterval = prefs.getInt('reminderInterval') ?? 15;
    _isEnabled = prefs.getBool('remindersEnabled') ?? false;
    notifyListeners();
  }

  Future<void> toggleReminders(bool value) async {
    _isEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remindersEnabled', value);
    
    if (value) {
      _scheduleReminders();
    } else {
      await _notificationService.cancelAll();
    }
    notifyListeners();
  }

  Future<void> setInterval(int minutes) async {
    _reminderInterval = minutes;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminderInterval', minutes);
    
    if (_isEnabled) {
      _scheduleReminders();
    }
    notifyListeners();
  }

  void _scheduleReminders() {
    _notificationService.cancelAll();
    // For demo purposes, we schedule a few reminders throughout the day
    // In a real app, this might be based on user's active hours
    _notificationService.scheduleDailyReminder(1, 'Focus Time!', 'Take $_reminderInterval minutes to focus on your tasks.', 9, 0);
    _notificationService.scheduleDailyReminder(2, 'Mid-day Check!', 'How is your progress? Start a session.', 14, 0);
    _notificationService.scheduleDailyReminder(3, 'Final Push!', 'Wrap up your day with one last focus session.', 17, 0);
  }
}
