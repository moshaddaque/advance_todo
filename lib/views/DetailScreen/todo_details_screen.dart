import 'dart:convert'; // For jsonDecode and jsonEncode

import 'package:advance_todo/widgets/icon_custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:intl/intl.dart';

import '../../helper/database_helper.dart';
import '../../model/todo_model.dart';

class TodoDetailScreen extends StatefulWidget {
  final Todo todo;

  const TodoDetailScreen({Key? key, required this.todo}) : super(key: key);

  @override
  _TodoDetailScreenState createState() => _TodoDetailScreenState();
}

class _TodoDetailScreenState extends State<TodoDetailScreen> {
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
    _titleController.text = widget.todo.title;
    _date = widget.todo.date;

    // Initialize the Quill controller with the description
    final quillDocument =
        quill.Document.fromJson(jsonDecode(widget.todo.descriptionJson));
    _quillController = quill.QuillController(
      document: quillDocument,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  Future<void> _updateTodo() async {
    final updatedTitle = _titleController.text;
    final updatedDescriptionDelta = _quillController.document.toDelta();
    final updatedDescriptionJson = jsonEncode(updatedDescriptionDelta);

    if (updatedTitle.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a task title')),
      );
      return;
    }

    // Update the todos with new values
    widget.todo.title = updatedTitle;
    widget.todo.descriptionJson = updatedDescriptionJson;
    widget.todo.date = _date;
    widget.todo.time = _selectedTime;

    await DatabaseHelper().updateTodo(widget.todo);

    Navigator.pop(context, true); // Return to the previous screen with a result
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo Details'),
        actions: [
          IconCustomButton(
            margin: 16,
            onTap: _updateTodo,
            icon: const Icon(
              Icons.save,
              color: Colors.green,
              size: 35,
            ),
          ),
          IconCustomButton(
            margin: 16,
            onTap: () async {
              await DatabaseHelper().deleteTodo(widget.todo.id!);
              Navigator.pop(context, true);
            },
            icon: const Icon(
              Icons.delete,
              color: Colors.redAccent,
              size: 35,
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
                controller: _quillController), // Toolbar for rich text options
          ],
        ),
      ),
    );
  }
}
