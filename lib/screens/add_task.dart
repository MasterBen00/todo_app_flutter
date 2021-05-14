import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/model/task.dart';
import 'package:todo_app/provider/task_provider.dart';
import 'package:todo_app/screens/todo_list_screen.dart';

// ignore: must_be_immutable
class AddTaskScreen extends StatelessWidget {
  final _dateController = TextEditingController();
  final _titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');

  final List<String> _priorities = ['Low', 'Medium', 'High'];
  String _priority;
  var brightness = SchedulerBinding.instance.window.platformBrightness;

  @override
  Widget build(BuildContext context) {
    bool darkModeOn = brightness == Brightness.dark;
    // var brightness = MediaQuery.of(context).platformBrightness;
    // bool darkModeOn = brightness == Brightness.dark;
    //
    // var themeColor = darkModeOn ? Colors.white : Colors.black;
    //var themeColor = Colors.white;
    var themeColor = darkModeOn ? Colors.white : Colors.black;

    debugPrint('add task screen building');
    TaskProvider _taskProvider =
        Provider.of<TaskProvider>(context, listen: false);

    _handleDatePicker() async {
      final DateTime date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100));

      if (date != null && date != DateTime.now()) {
        _taskProvider.localTaskData['date'] = date;
        _dateController.text = _dateFormat.format(date);
      }
    }

    _submit() {
      if (_formKey.currentState.validate()) {
        _formKey.currentState.save();

        //insert the task to our user's database
        Task newTask = Task(
            title: _titleController.text,
            date: _taskProvider.localTaskData['date'],
            priority: _priority);
        if (_taskProvider.modeStatus == Status.createMode) {
          newTask.status = 0;
          _taskProvider.createTask(newTask);
        } else {
          //update the task
          newTask.id = _taskProvider.task.id;
          newTask.status = _taskProvider.task.status;
          _taskProvider.updateTask(newTask);
        }
        _taskProvider.resetLocalTaskData();
        Navigator.pushAndRemoveUntil(
            context,
            CupertinoPageRoute(builder: (_) => TodoListScreen()),
            (route) => false);
      }
    }

    _delete() {
      _taskProvider.deleteTask(_taskProvider.task.id);
      Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (_) => TodoListScreen()),
          (route) => false);
    }

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 75),
            child: Consumer<TaskProvider>(
              builder: (context, taskState, child) {
                debugPrint("add task consumer building");
                if (taskState.modeStatus == Status.editMode) {
                  _titleController.text = taskState.task.title;
                  taskState.localTaskData['date'] = taskState.task.date;
                  _dateController.text =
                      _dateFormat.format(taskState.task.date);
                  _priority = taskState.task.priority;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 30,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                        taskState.modeStatus == Status.createMode
                            ? 'Add Task'
                            : 'Update Task',
                        style: TextStyle(
                            color: themeColor,
                            fontSize: 40,
                            fontWeight: FontWeight.bold)),
                    SizedBox(
                      height: 10,
                    ),
                    Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                              ),
                              child: TextFormField(
                                controller: _titleController,
                                style: TextStyle(fontSize: 18),
                                decoration: InputDecoration(
                                    labelText: 'Title',
                                    labelStyle: TextStyle(fontSize: 18),
                                    border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(10))),
                                validator: (input) =>
                                    input == null || input.trim().isEmpty
                                        ? "Please enter a task."
                                        : null,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20,
                              ),
                              child: TextFormField(
                                readOnly: true,
                                controller: _dateController,
                                onTap: _handleDatePicker,
                                style: TextStyle(fontSize: 18),
                                decoration: InputDecoration(
                                  labelText: 'Date',
                                  labelStyle: TextStyle(fontSize: 18),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 20.0,
                              ),
                              child: DropdownButtonFormField(
                                isDense: true,
                                icon: Icon(Icons.arrow_drop_down),
                                iconSize: 22.0,
                                iconEnabledColor:
                                    Theme.of(context).primaryColor,
                                items: _priorities.map((String priority) {
                                  return DropdownMenuItem(
                                    value: priority,
                                    child: Text(
                                      priority,
                                      style: TextStyle(
                                          color: themeColor, fontSize: 18.0),
                                    ),
                                  );
                                }).toList(),
                                style: TextStyle(fontSize: 18.0),
                                decoration: InputDecoration(
                                  labelText: 'Priority',
                                  labelStyle: TextStyle(fontSize: 18.0),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                ),
                                validator: (input) => _priority == null
                                    ? 'Please select a priority level.'
                                    : null,
                                onChanged: (value) {
                                  _priority = value;
                                },
                                value: _priority,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 15.0),
                              height: 50.0,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  //color: Colors.brown,
                                  borderRadius: BorderRadius.circular(30)),
                              child: TextButton(
                                onPressed: _submit,
                                style: TextButton.styleFrom(
                                  primary: Colors.pink,
                                ),
                                child: Text(
                                  taskState.modeStatus == Status.createMode
                                      ? "Add"
                                      : 'Update',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            taskState.modeStatus == Status.createMode
                                ? SizedBox.shrink()
                                : Container(
                                    margin: EdgeInsets.symmetric(vertical: 0),
                                    height: 50,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(30)),
                                    child: TextButton(
                                      onPressed: _delete,
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                          ],
                        ))
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
