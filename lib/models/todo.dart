enum TodoPriority { low, medium, high }

class Todo {
  final String id;
  final String title;
  final DateTime? dueDate;
  final TodoPriority priority;
  final String notes;
  final bool isCompleted;

  Todo({
    required this.id,
    required this.title,
    this.dueDate,
    this.priority = TodoPriority.low,
    this.notes = '',
    this.isCompleted = false,
  });

  Todo copyWith({
    String? title,
    DateTime? dueDate,
    TodoPriority? priority,
    String? notes,
    bool? isCompleted,
  }) {
    return Todo(
      id: id,
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      notes: notes ?? this.notes,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dueDate': dueDate?.toIso8601String(),
      'priority': priority.index,
      'notes': notes,
      'isCompleted': isCompleted,
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      priority: TodoPriority.values[json['priority'] ?? 0],
      notes: json['notes'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
