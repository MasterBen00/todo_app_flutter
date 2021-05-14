class Task {
  String id;
  String title;
  DateTime date;
  String priority;
  int status;

  Task({this.title, this.date, this.priority, this.status});

  Task.withId({this.id, this.title, this.date, this.priority, this.status});

  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['title'] = title;
    map['date'] = date.millisecondsSinceEpoch;
    map['priority'] = taskHelper.getPriorityAsValue(priority);
    map['status'] = status.toString();

    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task.withId(
        id: map['id'],
        title: map['title'],
        date: DateTime.fromMillisecondsSinceEpoch(map['date']),
        priority: taskHelper.getPriorityAsString(map['priority']),
        status: map['status']);
  }
}

class TaskHelper {
  String getPriorityAsString(int priority) {
    if (priority == 1) {
      return "Low";
    } else if (priority == 2) {
      return "Medium";
    } else if (priority == 3) {
      return "High";
    } else {
      return null;
    }
  }

  String getPriorityAsValue(String priority) {
    if (priority == "Low") {
      return "1";
    } else if (priority == "Medium") {
      return "2";
    } else if (priority == "High") {
      return "3";
    } else {
      return null;
    }
  }
}

TaskHelper taskHelper = TaskHelper();
