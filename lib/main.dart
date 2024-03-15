import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO Persistence',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: TodoScreen(),
    );
  }
}

class Todo {
  String title;
  bool completed;

  Todo({
    required this.title,
    this.completed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'completed': completed,
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      title: json['title'],
      completed: json['completed'],
    );
  }
}

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  List<Todo> todos = [];

  @override
  void initState() {
    super.initState();
    loadTodos();
  }

  Future<void> loadTodos() async {
    try {
      final file = await _localFile;
      String contents = await file.readAsString();
      setState(() {
        todos = (json.decode(contents) as List)
            .map((todo) => Todo.fromJson(todo))
            .toList();
      });
    } catch (e) {
      print("Error loading todos: $e");
    }
  }

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/todos.json');
  }

  Future<void> saveTodos() async {
    final file = await _localFile;
    await file.writeAsString(json.encode(todos));
  }

  void addTodo(String title) {
    setState(() {
      todos.add(Todo(title: title));
      saveTodos();
    });
  }

  void toggleTodoComplete(int index) {
    setState(() {
      todos[index].completed = !todos[index].completed;
      saveTodos();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text('TODO Persistence'),
      ),
      body: Column(
        children: [
          TodoForm(addTodo: addTodo),
          Expanded(
            child: TodoList(
              todos: todos,
              onTodoToggle: toggleTodoComplete,
            ),
          ),
        ],
      ),
    );
  }
}

class TodoForm extends StatefulWidget {
  final Function(String) addTodo;

  TodoForm({required this.addTodo});

  @override
  _TodoFormState createState() => _TodoFormState();
}

class _TodoFormState extends State<TodoForm> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(labelText: 'TODO Title'),
            ),
          ),
          SizedBox(width: 8.0),
          ElevatedButton(
            onPressed: () {
              if (_controller.text.isNotEmpty) {
                widget.addTodo(_controller.text);
                _controller.clear();
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class TodoList extends StatelessWidget {
  final List<Todo> todos;
  final Function(int) onTodoToggle;

  TodoList({required this.todos, required this.onTodoToggle});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(todos[index].title),
          leading: Checkbox(
            value: todos[index].completed,
            onChanged: (bool? isChecked) {
              onTodoToggle(index);
            },
          ),
        );
      },
    );
  }
}
