import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';

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
