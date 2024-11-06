import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/todo_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'todo.db'),
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE todos(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            descriptionJson TEXT,
            isDone INTEGER,
            date TEXT,
            time TEXT
          )
          ''',
        );
      },
      version: 1,
    );
  }

  // insert todos
  Future<int> insertTodo(Todo todo) async {
    final db = await database;
    return await db.insert(
      'todos',
      todo.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // retrieve data
  Future<List<Todo>> getTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todos');

    return List.generate(maps.length, (i) {
      return Todo(
        id: maps[i]['id'],
        title: maps[i]['title'],
        descriptionJson: maps[i]['descriptionJson'], // Store the JSON string
        isDone: maps[i]['isDone'] == 1,
        date: DateTime.parse(maps[i]['date']),
        time: stringToTime(maps[i]['time']),
      );
    });
  }

  Future<int> updateTodo(Todo todo) async {
    final db = await database;
    return await db
        .update('todos', todo.toMap(), where: 'id = ?', whereArgs: [todo.id]);
  }

  Future<int> deleteTodo(int id) async {
    final db = await database;
    return await db.delete('todos', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllTodos() async {
    final db = await database;
    return await db.delete('todos');
  }
}

//===============================================

// Convert TimeOfDay to a string (HH:mm format)
String timeToString(TimeOfDay time) {
  final now = DateTime.now();
  final dateTime =
      DateTime(now.year, now.month, now.day, time.hour, time.minute);
  return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
}

// Convert a string (HH:mm format) back to TimeOfDay
TimeOfDay stringToTime(String timeString) {
  final format = timeString.split(":");
  return TimeOfDay(hour: int.parse(format[0]), minute: int.parse(format[1]));
}
