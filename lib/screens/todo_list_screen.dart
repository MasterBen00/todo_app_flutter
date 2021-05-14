import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/model/task.dart';
import 'package:todo_app/provider/task_provider.dart';

import 'add_task.dart';

class TodoListScreen extends StatelessWidget {
  TodoListScreen({Key key}) : super(key: key);

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

    TaskProvider _taskProvider =
        Provider.of<TaskProvider>(context, listen: false);
    _taskProvider.getAllTasks();

    debugPrint('todolist screen building');

    final DateFormat _dateFormat = DateFormat('MMM dd,yyyy');

    Widget _buildTask(Task task) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Consumer<TaskProvider>(
          builder: (context, taskState, child) {
            return Column(
              children: [
                ListTile(
                  title: Text(
                    task.title,
                    style: TextStyle(
                        fontSize: 18,
                        decoration: task.status == 0
                            ? TextDecoration.none
                            : TextDecoration.lineThrough),
                  ),
                  subtitle: Text(
                      '${_dateFormat.format(task.date)} ${task.priority}',
                      style: TextStyle(
                          fontSize: 15,
                          decoration: task.status == 0
                              ? TextDecoration.none
                              : TextDecoration.lineThrough)),
                  trailing: Checkbox(
                      onChanged: (value) {
                        task.status = value ? 1 : 0;
                        taskState.updateTask(task);
                      },
                      activeColor: Theme.of(context).primaryColor,
                      value: task.status == 1 ? true : false),
                  onTap: () => {
                    _taskProvider.updateLocalTaskState(task),
                    _taskProvider.updateModeStatus(Status.editMode),
                    _taskProvider.priority = task.priority,
                    Navigator.push(context,
                        CupertinoPageRoute(builder: (_) => AddTaskScreen()))
                  },
                ),
                Divider()
              ],
            );
          },
        ),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () {
          _taskProvider.updateModeStatus(Status.createMode);
          _taskProvider.resetPriority();
          Navigator.push(
              context, CupertinoPageRoute(builder: (_) => AddTaskScreen()));
        },
        child: Icon(Icons.library_add, color: Colors.white54,),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskState, child) {
          if (taskState.dataFetchStatus == Status.dataNotFetched) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          final int completedTaskCount = taskState.taskList
              .where((task) => task.status == 1)
              .toList()
              .length;

          return ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(vertical: 100.0),
            itemCount: 1 + taskState.taskList.length,
            itemBuilder: (BuildContext context, int i) {
              if (i == 0) {
                return Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'My Tasks',
                        style: TextStyle(
                            fontSize: 40,
                            //color: Colors.black,
                            color: themeColor,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        '$completedTaskCount of ${taskState.taskList.length}',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey,
                            fontWeight: FontWeight.w600),
                      )
                    ],
                  ),
                );
              }
              return _buildTask(taskState.taskList[i - 1]);
            },
          );
        },
      ),
    );
  }
}
