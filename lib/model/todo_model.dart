import 'package:advance_todo/helper/database_helper.dart';
import 'package:flutter/material.dart';

class Todo {
  int? id;
  String title;
  String descriptionJson; // Store description as JSON string
  bool isDone;
  DateTime date;
  TimeOfDay time;
  Todo({
    this.id,
    required this.title,
    required this.descriptionJson,
    required this.isDone,
    required this.date,
    required this.time,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'descriptionJson': descriptionJson, // Save the description as a string
      'isDone': isDone ? 1 : 0,
      'date': date.toString(),
      'time': timeToString(time),
    };
  }

  // Function to convert a map to a Todo object
  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      descriptionJson: map['descriptionJson'],
      isDone: map['isDone'] == 1,
      date: DateTime.parse(map['date']),
      time: stringToTime(map['time']),
    );
  }
}
