import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class TodoProvider with ChangeNotifier {
  List<Todo> _todos = [];
  String? _activeTodoId;
  bool _isLoading = true;

  TodoProvider() {
    _loadTodos();
  }

  List<Todo> get todos => _todos;
  String? get activeTodoId => _activeTodoId;
  bool get isLoading => _isLoading;

  Todo? get activeTodo => _activeTodoId != null 
      ? _todos.firstWhere((t) => t.id == _activeTodoId, orElse: () => _todos.first) 
      : null;

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todosJson = prefs.getString('todos');
    if (todosJson != null) {
      final List<dynamic> decoded = jsonDecode(todosJson);
      _todos = decoded.map((item) => Todo.fromJson(item)).toList();
    }
    _activeTodoId = prefs.getString('activeTodoId');
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_todos.map((todo) => todo.toJson()).toList());
    await prefs.setString('todos', encoded);
    if (_activeTodoId != null) {
      await prefs.setString('activeTodoId', _activeTodoId!);
    } else {
      await prefs.remove('activeTodoId');
    }
  }

  void setActiveTodo(String? id) {
    _activeTodoId = id;
    _saveTodos();
    notifyListeners();
  }

  void addTodo(Todo todo) {
    _todos.add(todo);
    _saveTodos();
    notifyListeners();
  }

  void updateTodo(Todo updatedTodo) {
    final index = _todos.indexWhere((t) => t.id == updatedTodo.id);
    if (index != -1) {
      _todos[index] = updatedTodo;
      _saveTodos();
      notifyListeners();
    }
  }

  void deleteTodo(String id) {
    _todos.removeWhere((t) => t.id == id);
    _saveTodos();
    notifyListeners();
  }

  void toggleTodo(String id) {
    final index = _todos.indexWhere((t) => t.id == id);
    if (index != -1) {
      _todos[index] = _todos[index].copyWith(isCompleted: !_todos[index].isCompleted);
      _saveTodos();
      notifyListeners();
    }
  }
}
