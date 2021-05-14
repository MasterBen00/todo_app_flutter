import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/model/task.dart';
import 'package:todo_app/repository/task_repository.dart';

enum Status { dataFetched, dataNotFetched, editMode, createMode }

class TaskProvider extends ChangeNotifier {
  List<Task> taskList = [];
  String priority;
  Task task;

  Status _dataFetchStatus = Status.dataNotFetched;

  Status get dataFetchStatus => _dataFetchStatus;

  Status _modeStatus = Status.createMode;

  Status get modeStatus => _modeStatus;

  void updateModeStatus(Status mode) {
    _modeStatus = mode;
  }

  void getAllTasks() async {
    taskList = await taskRepository.getAllTasks();

    _dataFetchStatus = Status.dataFetched;
    notifyListeners();
  }

  void createTask(Task task) async {
    var response = await taskRepository.createTask(task);
  }

  void updateTask(Task task) async {
    var response = await taskRepository.updateTask(task);
    notifyListeners();
  }

  void updateLocalTaskState(Task newTask) async {
    this.task = newTask;
    notifyListeners();
  }

  Map<String, dynamic> localTaskData = {
    'id': null,
    'title': null,
    'priority': null,
    'date': null,
    'status': null
  };

  void updateLocalTaskData() {}

  void updatePriority(String value) {
    priority = value;
    notifyListeners();
  }

  void resetPriority() {
    priority = null;
    //notifyListeners();
  }

  void deleteTask(String id) async {
    taskRepository.deleteTask(id);
  }
}
