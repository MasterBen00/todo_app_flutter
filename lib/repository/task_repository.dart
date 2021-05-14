import 'dart:convert';

import 'package:http/http.dart';
import 'package:todo_app/model/task.dart';
import 'package:todo_app/util/api_util.dart';

class TaskRepository {
  Future<List<Task>> getAllTasks() async {
    Response response = await get(
        Uri.http(ApiUrl.apiBaseUrl, ApiUrl.fetchAllUrl),
        headers: {'Content-Type': 'application/json'});

    var extractedResponse = json.decode(response.body);

    List<Task> taskList = [];

    for (int i = 0; i < extractedResponse.length; i++) {
      taskList.add(Task.fromMap(extractedResponse[i]));
    }

    return taskList;
  }

  updateTask(Task task) async {
    var queryParameters = {'id': task.id};
    Response response = await patch(
        Uri.http(ApiUrl.apiBaseUrl, ApiUrl.editUrl, queryParameters),
        body: jsonEncode(task.toMap()),
        headers: {'Content-Type': 'application/json'});

    return json.decode(response.body);
  }

  createTask(Task task) async {
    Response response = await post(
        Uri.http(ApiUrl.apiBaseUrl, ApiUrl.createUrl),
        body: jsonEncode(task.toMap()),
        headers: {'Content-Type': 'application/json'});

    return json.decode(response.body);
  }

  void deleteTask(String id) async {
    var queryParameters = {'id': id};
    Response response = await delete(
        Uri.http(ApiUrl.apiBaseUrl, ApiUrl.deleteUrl, queryParameters),
        headers: {'Content-Type': 'application/json'});

    print(response);
  }
}

TaskRepository taskRepository = TaskRepository();
