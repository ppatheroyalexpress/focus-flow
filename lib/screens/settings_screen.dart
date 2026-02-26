import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../providers/white_noise_provider.dart';
import '../providers/reminder_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<TimerProvider>(
        builder: (context, provider, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildSectionTitle(context, 'Timer Durations'),
              _buildSettingItem(
                title: 'Focus Duration',
                subtitle: '${provider.workDuration} minutes',
                child: Slider(
                  value: provider.workDuration.toDouble(),
                  min: 5,
                  max: 60,
                  divisions: 11,
                  label: '${provider.workDuration}',
                  onChanged: (value) => provider.updateSettings(newWork: value.toInt()),
                ),
              ),
              _buildSettingItem(
                title: 'Short Break Duration',
                subtitle: '${provider.shortBreakDuration} minutes',
                child: Slider(
                  value: provider.shortBreakDuration.toDouble(),
                  min: 1,
                  max: 15,
                  divisions: 14,
                  label: '${provider.shortBreakDuration}',
                  onChanged: (value) => provider.updateSettings(newShort: value.toInt()),
                ),
              ),
              _buildSettingItem(
                title: 'Long Break Duration',
                subtitle: '${provider.longBreakDuration} minutes',
                child: Slider(
                  value: provider.longBreakDuration.toDouble(),
                  min: 5,
                  max: 45,
                  divisions: 8,
                  label: '${provider.longBreakDuration}',
                  onChanged: (value) => provider.updateSettings(newLong: value.toInt()),
                ),
              ),
              const Divider(),
              _buildSectionTitle(context, 'Behavior & Audio'),
              SwitchListTile(
                title: const Text('Sound Notifications'),
                subtitle: const Text('Play sound when a session ends'),
                value: provider.isSoundEnabled,
                onChanged: (value) => provider.updateSettings(newSound: value),
              ),
              SwitchListTile(
                title: const Text('Auto-start Breaks'),
                subtitle: const Text('Start break timer automatically'),
                value: provider.autoStartBreaks,
                onChanged: (value) => provider.updateSettings(newAutoStart: value),
              ),
              SwitchListTile(
                title: const Text('Strict Mode'),
                subtitle: const Text('Disable pausing/skipping during focus'),
                value: provider.isStrictMode,
                onChanged: (value) => provider.updateSettings(newStrictMode: value),
              ),
              const Divider(),
              _buildSectionTitle(context, 'White Noise'),
              Consumer<WhiteNoiseProvider>(
                builder: (context, noiseProvider, child) {
                  return Column(
                    children: [
                      _buildSettingItem(
                        title: 'Background Sound',
                        subtitle: 'Plays looping sound during focus',
                        child: DropdownButtonFormField<WhiteNoiseType>(
                          value: noiseProvider.currentType,
                          decoration: const InputDecoration(border: OutlineInputBorder()),
                          items: WhiteNoiseType.values.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type.name[0].toUpperCase() + type.name.substring(1)),
                            );
                          }).toList(),
                          onChanged: (val) => noiseProvider.setSound(val!),
                        ),
                      ),
                      if (noiseProvider.currentType != WhiteNoiseType.none)
                        _buildSettingItem(
                          title: 'Sound Volume',
                          subtitle: '${(noiseProvider.volume * 100).toInt()}%',
                          child: Slider(
                            value: noiseProvider.volume,
                            min: 0,
                            max: 1,
                            onChanged: (val) => noiseProvider.setVolume(val),
                          ),
                        ),
                    ],
                  );
                },
              ),
              const Divider(),
              _buildSectionTitle(context, 'Daily Reminders'),
              Consumer<ReminderProvider>(
                builder: (context, reminderProvider, child) {
                  return Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Enable Reminders'),
                        subtitle: const Text('Get daily prompts to stay focused'),
                        value: reminderProvider.isEnabled,
                        onChanged: (value) => reminderProvider.toggleReminders(value),
                      ),
                      if (reminderProvider.isEnabled)
                        _buildSettingItem(
                          title: 'Reminder Interval',
                          subtitle: 'Receive a prompt every ${reminderProvider.reminderInterval} minutes of inactivity (Simulated)',
                          child: DropdownButtonFormField<int>(
                            value: reminderProvider.reminderInterval,
                            decoration: const InputDecoration(border: OutlineInputBorder()),
                            items: [5, 15, 30].map((min) {
                              return DropdownMenuItem(
                                value: min,
                                child: Text('$min Minutes'),
                              );
                            }).toList(),
                            onChanged: (val) => reminderProvider.setInterval(val!),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildSettingItem({required String title, required String subtitle, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Text(title),
          subtitle: Text(subtitle),
          contentPadding: EdgeInsets.zero,
        ),
        child,
        const SizedBox(height: 16),
      ],
    );
  }
}
