import 'package:advance_todo/helper/database_helper.dart';
import 'package:advance_todo/views/DetailScreen/todo_details_screen.dart';
import 'package:advance_todo/views/TodoEditorScreen/todo_editor_screen.dart';
import 'package:advance_todo/widgets/icon_custom_button.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/todo_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Todo>> _todoList;

  @override
  void initState() {
    super.initState();
    refreshTodoList();
  }

  refreshTodoList() {
    setState(() {
      _todoList = DatabaseHelper().getTodos(); // Fetch tasks from SQLite
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo App'),
        actions: [
          IconCustomButton(
            onTap: () async {
              await DatabaseHelper().deleteAllTodos(); // Delete all tasks
              refreshTodoList();
            },
            margin: 16,
            icon: const Icon(
              Icons.delete_forever,
              color: Colors.redAccent,
              size: 35,
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Todo>>(
        future: _todoList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tasks available'));
          } else {
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 20,
                crossAxisSpacing: 5,
                childAspectRatio: 1.1,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final todo = snapshot.data![index];
                return InkWell(
                  onTap: () async {
                    final result = await Navigator.of(context).push(
                      PageRouteBuilder(
                        transitionDuration: const Duration(milliseconds: 400),
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            TodoDetailScreen(todo: todo),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0);
                          const end = Offset.zero;
                          const curve = Curves.ease;
                          final tween = Tween(begin: begin, end: end);
                          final curvedAnimation = CurvedAnimation(
                            parent: animation,
                            curve: curve,
                          );
                          return SlideTransition(
                            position: tween.animate(curvedAnimation),
                            child: child,
                          );
                        },
                      ),
                    );
                    // Check if result is true and call refreshTodoList
                    if (result == true) {
                      refreshTodoList();
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(left: 16, right: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.black12,
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          todo.title,
                          maxLines: 2,
                          textAlign: TextAlign.start,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            decoration:
                                todo.isDone ? TextDecoration.lineThrough : null,
                            fontSize: 23,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Text(timeToString(todo.time)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat("MMM dd, yyyy").format(todo.date) ??
                                  "",
                              style: const TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            Transform.scale(
                              scale: 1.4,
                              child: Checkbox(
                                value: todo.isDone,
                                checkColor: Colors.green,
                                side: const BorderSide(
                                  color: Colors.black12,
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5)),
                                onChanged: (bool? value) {
                                  setState(() {
                                    todo.isDone = value ?? false;
                                    DatabaseHelper().updateTodo(todo);
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.black12),
          borderRadius: BorderRadius.circular(16),
        ),
        onPressed: () async {
          final result = await Navigator.of(context).push(
            PageRouteBuilder(
              transitionDuration: const Duration(milliseconds: 500),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  const TodoEditor(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
            ),
          );

          if (result == true) {
            refreshTodoList(); // Refresh after adding a new task
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
