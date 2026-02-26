import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../providers/todo_provider.dart';
import '../providers/white_noise_provider.dart';
import '../models/timer_model.dart';
import '../models/todo.dart';
import 'settings_screen.dart';
import 'stats_screen.dart';
import 'todo_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _getSessionName(SessionType type) {
    switch (type) {
      case SessionType.work:
        return 'Focus Time';
      case SessionType.shortBreak:
        return 'Short Break';
      case SessionType.longBreak:
        return 'Long Break';
    }
  }

  Color _getSessionColor(SessionType type) {
    switch (type) {
      case SessionType.work:
        return Colors.redAccent;
      case SessionType.shortBreak:
        return Colors.greenAccent;
      case SessionType.longBreak:
        return Colors.blueAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pomodoro Timer'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.checklist),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const TodoScreen()),
              );
            },
            tooltip: 'To-Do List',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const StatsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<TimerProvider>(
        builder: (context, timerProvider, child) {
          final state = timerProvider.state;
          
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Text(
                    _getSessionName(state.sessionType),
                    key: ValueKey(state.sessionType),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: _getSessionColor(state.sessionType),
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Session ${state.sessionCount + 1}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 20),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: _getSessionColor(state.sessionType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: _getSessionColor(state.sessionType).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Consumer<TodoProvider>(
                    builder: (context, todoProvider, child) {
                      final activeTodo = todoProvider.activeTodo;
                      return InkWell(
                        onTap: () => _showTaskSelection(context, todoProvider),
                        borderRadius: BorderRadius.circular(30),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              activeTodo != null ? Icons.check_circle : Icons.radio_button_unchecked,
                              size: 20,
                              color: _getSessionColor(state.sessionType),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              activeTodo?.title ?? 'What are you working on?',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Selector<TimerProvider, int>(
                  selector: (_, provider) => provider.state.remainingSeconds,
                  builder: (context, seconds, child) {
                    return Text(
                      _formatTime(seconds),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 84,
                            fontWeight: FontWeight.bold,
                            color: _getSessionColor(state.sessionType),
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                    );
                  },
                ),
                const SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!state.isRunning)
                      ElevatedButton.icon(
                        onPressed: () {
                          timerProvider.startTimer();
                          context.read<WhiteNoiseProvider>().resumeSound();
                        },
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Start'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () {
                          timerProvider.pauseTimer();
                          context.read<WhiteNoiseProvider>().pauseSound();
                        },
                        icon: const Icon(Icons.pause),
                        label: const Text('Pause'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    const SizedBox(width: 20),
                    OutlinedButton.icon(
                      onPressed: () {
                        timerProvider.resetTimer();
                        context.read<WhiteNoiseProvider>().pauseSound();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                    ),
                  ],
                ),
                if (timerProvider.isStrictMode && state.isRunning && state.sessionType == SessionType.work) ...[
                  const SizedBox(height: 40),
                  Column(
                    children: [
                      GestureDetector(
                        onLongPressStart: (_) => timerProvider.startEmergencyExit(),
                        onLongPressEnd: (_) => timerProvider.cancelEmergencyExit(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Emergency Exit (Hold 5s)',
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      if (timerProvider.emergencyProgress > 0) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 200,
                          child: LinearProgressIndicator(
                            value: timerProvider.emergencyProgress,
                            color: Colors.red,
                            backgroundColor: Colors.red.withOpacity(0.1),
                          ),
                        ),
                        if (timerProvider.emergencyProgress >= 1.0) ...[
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _showEmergencyConfirmation(context, timerProvider),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                            child: const Text('Confirm Emergency Exit'),
                          ),
                        ],
                      ],
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _showTaskSelection(BuildContext context, TodoProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Task', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              if (provider.todos.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No tasks available. Go to To-Do list to add some.'),
                ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: provider.todos.length,
                  itemBuilder: (context, index) {
                    final todo = provider.todos[index];
                    return ListTile(
                      title: Text(todo.title),
                      selected: provider.activeTodoId == todo.id,
                      onTap: () {
                        provider.setActiveTodo(todo.id);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              if (provider.activeTodoId != null)
                TextButton(
                  onPressed: () {
                    provider.setActiveTodo(null);
                    Navigator.pop(context);
                  },
                  child: const Text('Clear Selection', style: TextStyle(color: Colors.red)),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showEmergencyConfirmation(BuildContext context, TimerProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Emergency Exit'),
        content: const Text('Are you sure you want to exit? Your focus session will be reset.'),
        actions: [
          TextButton(
            onPressed: () {
              provider.cancelEmergencyExit();
              Navigator.pop(context);
            },
            child: const Text('Stay'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.confirmEmergencyExit();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Exit Now'),
          ),
        ],
      ),
    );
  }
}
