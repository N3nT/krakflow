import 'package:flutter/material.dart';
import 'tasks_repository.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MainScreen()
    );
  }
}

// MainScreen
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  var taskCountDone = TasksRepository.tasks.where((task) => task.done).length;
  @override
  Widget build(BuildContext context){
    return Scaffold(

      appBar: AppBar(
        title: Text("KrakFlow"),
      ),

      body:
      Padding(
          padding: EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text("Masz dziś ${TasksRepository.tasks.length} zadań"),

              SizedBox(height: 16),
              Text("Wykonano $taskCountDone zadanie",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
              ),

              SizedBox(height: 16),
              Text("Dzisiejsze zadania:",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              Expanded(
                  child:
                  ListView.builder(
                      itemCount: TasksRepository.tasks.length,
                      itemBuilder: (context, index) {
                        final task = TasksRepository.tasks[index];
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
      ),
      floatingActionButton:
      FloatingActionButton(
        onPressed: () async {
          final Task? newTask = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AddTaskScreen()
              ),
          );

          if(newTask != null){
            setState(() {
              TasksRepository.tasks.add(newTask);
            });
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

// TaskCard
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

// AddTaskScreen
class AddTaskScreen extends StatelessWidget {

  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadLineController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dodaj nowe zadanie"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: "Tytuł zadania",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: deadLineController,
              decoration: InputDecoration(
                labelText: "Termin zadania",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: priorityController,
              decoration: InputDecoration(
                labelText: "Priorytet zadania",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                  onPressed: () {
                    final newTask = Task(
                      title: titleController.text,
                      deadline: deadLineController.text,
                      done: false,
                      priority: priorityController.text,
                    );
                    
                    Navigator.pop(context, newTask);
                  },
                  child: Text("Zapisz")
              ),
            ),
          ],
        )
      ),
    );
  }
}