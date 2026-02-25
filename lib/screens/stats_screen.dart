import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/timer_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Statistics'),
      ),
      body: Consumer<TimerProvider>(
        builder: (context, provider, child) {
          final history = provider.history;
          final today = DateTime.now();
          
          final todaySessions = history.where((d) => 
            d.year == today.year && 
            d.month == today.month && 
            d.day == today.day
          ).length;

          final totalFocusMinutes = todaySessions * provider.workDuration;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildSummaryCard(context, todaySessions, totalFocusMinutes),
              const SizedBox(height: 30),
              Text(
                'Recent History',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (history.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text('No sessions recorded yet. Time to focus!'),
                  ),
                )
              else
                ...history.reversed.take(10).map((date) => ListTile(
                  leading: const Icon(Icons.check_circle, color: Colors.green),
                  title: const Text('Focus Session Completed'),
                  subtitle: Text(DateFormat('MMM dd, yyyy - hh:mm a').format(date)),
                )),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, int sessionCount, int minutes) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.surface,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Text(
              "Today's Progress",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, '$sessionCount', 'Sessions'),
                Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
                _buildStatItem(context, '$minutes', 'Minutes'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge,
        ),
      ],
    );
  }
}
