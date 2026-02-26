import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
      ),
      body: Consumer<TodoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.todos.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No tasks yet. Add one!',
                    style: TextStyle(color: Colors.grey[600], fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: provider.todos.length,
            itemBuilder: (context, index) {
              final todo = provider.todos[index];
              return AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: 1.0,
                child: _TodoTile(todo: todo),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTodoDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AddTodoSheet(),
    );
  }
}

class _TodoTile extends StatelessWidget {
  final Todo todo;

  const _TodoTile({required this.todo});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TodoProvider>(context, listen: false);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showTodoDetails(context, todo),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Transform.scale(
                    scale: 1.2,
                    child: Checkbox(
                      value: todo.isCompleted,
                      shape: const CircleBorder(),
                      activeColor: _getSessionColor(Provider.of<TimerProvider>(context, listen: false).state.sessionType),
                      onChanged: (_) => provider.toggleTodo(todo.id),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          todo.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                            color: todo.isCompleted ? Colors.grey : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            _buildPriorityBadge(todo.priority),
                            if (todo.dueDate != null) ...[
                              const SizedBox(width: 8),
                              Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM d').format(todo.dueDate!),
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                            if (todo.notes.isNotEmpty) ...[
                              const SizedBox(width: 8),
                              Icon(Icons.notes, size: 12, color: Colors.grey[600]),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.red[300], size: 20),
                    onPressed: () => provider.deleteTodo(todo.id),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getSessionColor(SessionType type) {
    switch (type) {
      case SessionType.work: return Colors.redAccent;
      case SessionType.shortBreak: return Colors.greenAccent;
      case SessionType.longBreak: return Colors.blueAccent;
    }
  }

  Widget _buildPriorityBadge(TodoPriority priority) {
    Color color;
    String label;
    switch (priority) {
      case TodoPriority.high:
        color = Colors.red;
        label = 'High';
        break;
      case TodoPriority.medium:
        color = Colors.orange;
        label = 'Medium';
        break;
      case TodoPriority.low:
        color = Colors.green;
        label = 'Low';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showTodoDetails(BuildContext context, Todo todo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(todo.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todo.dueDate != null)
              Text('Due: ${DateFormat('MMM d, yyyy').format(todo.dueDate!)}'),
            Text('Priority: ${todo.priority.name.toUpperCase()}'),
            const Divider(),
            const Text('Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(todo.notes.isEmpty ? 'No notes' : todo.notes),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}

class _AddTodoSheet extends StatefulWidget {
  const _AddTodoSheet();

  @override
  State<_AddTodoSheet> createState() => _AddTodoSheetState();
}

class _AddTodoSheetState extends State<_AddTodoSheet> {
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _selectedDate;
  TodoPriority _priority = TodoPriority.low;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Add New Task', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
            autofocus: true,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(labelText: 'Notes', border: OutlineInputBorder()),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_selectedDate == null
                      ? 'Set Due Date'
                      : DateFormat('MMM d').format(_selectedDate!)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<TodoPriority>(
                  value: _priority,
                  decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 10)),
                  items: TodoPriority.values.map((p) {
                    return DropdownMenuItem(value: p, child: Text(p.name.toUpperCase()));
                  }).toList(),
                  onChanged: (val) => setState(() => _priority = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty) {
                final newTodo = Todo(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _titleController.text,
                  notes: _notesController.text,
                  dueDate: _selectedDate,
                  priority: _priority,
                );
                Provider.of<TodoProvider>(context, listen: false).addTodo(newTodo);
                Navigator.pop(context);
              }
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Add Task'),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }
}
