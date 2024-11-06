import 'dart:convert'; // For encoding and decoding JSON

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:intl/intl.dart';

import '../../helper/database_helper.dart';
import '../../model/todo_model.dart';

class TodoEditor extends StatefulWidget {
  final Todo? todo; // Nullable to distinguish between new and existing tasks

  const TodoEditor({super.key, this.todo});

  @override
  _TodoEditorState createState() => _TodoEditorState();
}

class _TodoEditorState extends State<TodoEditor> {
  final TextEditingController _titleController = TextEditingController();
  late quill.QuillController _quillController;
  DateTime _date = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  //
  _pickDate() async {
    DateTime? pickDate = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2022),
      lastDate: DateTime(2030),
    );

    if (pickDate != null && pickDate != _date) {
      setState(() {
        _date = pickDate;
      });
    }
  }

  // Function to show the Time Picker
  Future<void> _pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime, // Set initial time to the current time
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    _quillController = quill.QuillController.basic();
  }

  Future<void> _saveTodo() async {
    final title = _titleController.text;
    final descriptionDelta = _quillController.document.toDelta();
    final descriptionJson = jsonEncode(descriptionDelta);

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    // Creating a new task
    final newTodo = Todo(
      title: title,
      descriptionJson: descriptionJson,
      isDone: false, // Task is not done by default
      date: _date != null ? _date! : DateTime.now(),
      time: _selectedTime,
    );
    await DatabaseHelper().insertTodo(newTodo);

    Navigator.pop(context, true); // Return to the previous screen with a result
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Task'),
        actions: [
          InkWell(
            onTap: _saveTodo,
            child: Container(
              padding: const EdgeInsets.all(5),
              margin: const EdgeInsets.only(right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    blurStyle: BlurStyle.outer,
                    offset: Offset(1, 1),
                    blurRadius: 1,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: const Icon(
                Icons.save,
                color: Colors.green,
                size: 35,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Title:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: 'Title',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(
                    width: 1,
                    color: Colors.black12,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    width: 1,
                    color: Colors.black12,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    width: 1,
                    color: Colors.black12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  width: 1,
                  color: Colors.black12,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _date != null
                              ? 'Select Date: ${DateFormat("MMM dd, yyyy").format(_date!)}'
                              : 'Select Date: ',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                blurStyle: BlurStyle.outer,
                                offset: Offset(1, 1),
                                blurRadius: 1,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.calendar_month,
                            size: 35,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Selected Time: ${_selectedTime.format(context)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: _pickTime,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                blurStyle: BlurStyle.outer,
                                offset: Offset(1, 1),
                                blurRadius: 1,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.access_time,
                            size: 35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Description:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    width: 1,
                    color: Colors.black12,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: quill.QuillEditor.basic(
                  controller: _quillController,
                  configurations: const quill.QuillEditorConfigurations(
                    placeholder: "Description",
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            quill.QuillToolbar.simple(
                controller: _quillController), // Rich text toolbar
          ],
        ),
      ),
    );
  }
}
