import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  List<Task> tasks= [
    Task(title: "Odkurzyc", deadline: "dzis", done: true, priority: "5"),
    Task(title: "pora na cs", deadline: "po odkurzaniu", done: false, priority: "15"),
    Task(title: "Wyslac zadanie", deadline: "jutro", done: false, priority: "25"),
    Task(title: "Wyslac cv", deadline: "w nastepnym tygodniu", done: false, priority: "35")
  ];

  @override
  Widget build(BuildContext context) {
    final taskCountDone = tasks.where((task) => task.done).length;
    return MaterialApp(

      home: Scaffold(

        appBar: AppBar(
          title: Text("KrakFlow"),
        ),

        body:
          Padding(
            padding: EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text("Masz dziś ${tasks.length} zadań"),

                SizedBox(height: 16),
                Text("Wykonano ${taskCountDone} zadanie",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
                ),

                SizedBox(height: 16),
                Text("Dzisiejsze zadania:",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),


                Expanded(
                    child:
                      ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return TaskCard(
                              title: task.title,
                              subtitle: task.deadline,
                              icon: task.done ? Icons.check_circle : Icons.radio_button_checked,
                              priority: task.priority);
                          }
                        )
                )

              ],

            )
          )
      )
    );
  }
}

class Task {
  final String title;
  final String deadline;
  final bool done;
  final String priority;
  Task({required this.title, required this.deadline, required this.done, required this.priority});
}

class TaskCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String priority;
  final IconData icon;

  const TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.priority,
    required this.icon
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Row(
          children: [
            Text("Termin: "),
            Text(subtitle),
            Text(" | priorytet: "),
            Text(priority)
          ],
        )
      ),
    );
  }
}