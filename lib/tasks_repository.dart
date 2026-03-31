class Task {
  final String title;
  final String deadline;
  final bool done;
  final String priority;
  Task({required this.title, required this.deadline, required this.done, required this.priority});
}
class TasksRepository {
  static List<Task> tasks= [
    Task(title: "Odkurzyc", deadline: "dzis", done: true, priority: "5"),
    Task(title: "pora na cs", deadline: "po odkurzaniu", done: false, priority: "15"),
    Task(title: "Wyslac zadanie", deadline: "jutro", done: false, priority: "25"),
    Task(title: "Wyslac cv", deadline: "w nastepnym tygodniu", done: false, priority: "35")
  ];
}
