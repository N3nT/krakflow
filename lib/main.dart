import 'package:flutter/material.dart';
import 'tasks_repository.dart';
import '/services/task_api_service.dart';
import '/services/task_local_database.dart';
import '/services/task_sync_service.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox("tasks");
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
  String selectedFilter = "wszystkie";
  @override
  Widget build(BuildContext context){
    //var taskCountDone = tasks.where((task) => task.done).length;

    // final tasks = tasks.where((task) {
    //   if (selectedFilter == "zrobione") return task.done;
    //   if (selectedFilter == "do zrobienia") return !task.done;
    //   return true;
    // }).toList();

    return Scaffold(

      appBar: AppBar(
        title: Text("KrakFlow"),
        actions: [
          //tasks.isEmpty ? null : ()
          IconButton(onPressed: (){
            showDialog(context: context, builder: (context){
              return AlertDialog(
                title: Text("Potwierdzenie"),
                content: Text("Czy na pewno chcesz usunac wszystkie zadania?"),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: Text("Anuluj")),
                  TextButton(onPressed: () {
                    setState(() {
                      return;
                      //tasks.clear();
                    });

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Wszystkie zadania zostały usunięte"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  },
                  child: Text("Usuń"),
                  ),
                ],
              );
            });
          }, icon: Icon(Icons.delete,
          color: Colors.red))
      //tasks.isEmpty ? Colors.grey : Colors.red))
        ],
      ),

      body:
      Padding(
          padding: EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text("Masz dziś 5 zadań"),
              SizedBox(height: 16),
            FilterBar(
              selectedFilter: selectedFilter,
              onFilterChanged: (value) {
                setState(() {
                  selectedFilter = value;
                });
              },
            ),

              SizedBox(height: 16),
              Text("Wykonano 5 zadanie",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
              ),

              SizedBox(height: 16),
              Text("Dzisiejsze zadania:",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              Expanded(
                  child: TaskListScreen()
              ),

            ],

          )
      ),
      floatingActionButton:
      FloatingActionButton(
        onPressed: () async {
          final Task? newTask = await Navigator.push(
              context,
              PageRouteBuilder(pageBuilder: (context, animation, secondaryAnimation) => AddTaskScreen(),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                final slideAnimation = Tween<Offset>(
                  begin: Offset(1.0, 0.0),
                  end: Offset.zero,
                ).chain(CurveTween(curve: Curves.ease));

                return SlideTransition(
                  position: animation.drive(slideAnimation),
                  child: child
                );
              },
              ),
          );

          if(newTask != null){
            setState(() {
              TaskLocalDatabase.addTask(newTask);
              //_TaskListScreen.loadTask();
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
  bool done;
  final ValueChanged<bool?>? onChange;
  final VoidCallback? onTap;

  TaskCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.priority,
    required this.icon,
    required this.done,
    this.onChange,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Checkbox(value: done, onChanged: onChange),
        title: Text(
          title,
          style: TextStyle(
            decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
            color: done ? Colors.grey : Colors.black
          )
        ),
        subtitle: Row(
          children: [
            Text("Termin: "),
            Text(subtitle),
            Text(" | priorytet: "),
            Text(
                priority,
                style: TextStyle(
                    color: Colors.red
                )
            )
          ],
        ),
        onTap: onTap,
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
                      id: DateTime.now().millisecondsSinceEpoch,
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

//editTaskScreen
class EditTaskScreen extends StatelessWidget {
  final Task task;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController deadLineController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();

  EditTaskScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    titleController.text = task.title;
    deadLineController.text = task.deadline;
    priorityController.text = task.priority;
    return Scaffold(
      appBar: AppBar(
        title: Text("Edytuj zadanie"),
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
                      final updatedTask = Task(
                        id: task.id,
                        title: titleController.text,
                        deadline: deadLineController.text,
                        done: task.done,
                        priority: priorityController.text,
                      );

                      Navigator.pop(context, updatedTask);
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

class FilterBar extends StatelessWidget {
  final String selectedFilter;
  final Function(String) onFilterChanged;

  const FilterBar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: () => onFilterChanged("wszystkie"),
          child: Text(
            "Wszystkie",
            style: TextStyle(
              fontWeight: selectedFilter == "wszystkie"
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),

        TextButton(
          onPressed: () => onFilterChanged("do zrobienia"),
          child: Text(
            "Do zrobienia",
            style: TextStyle(
              fontWeight: selectedFilter == "do zrobienia"
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),

        TextButton(
          onPressed: () => onFilterChanged("zrobione"),
          child: Text(
            "Zrobione",
            style: TextStyle(
              fontWeight: selectedFilter == "zrobione"
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreen();
}

class _TaskListScreen extends State<TaskListScreen> {
  late Future<List<Task>> tasksFuture;

  Future<List<Task>> loadTask() async {
    await TaskSyncService.loadInitialDataIfNeeded();
    return TaskLocalDatabase.getTasks();
  }

  @override
  void initState() {
    super.initState();
    tasksFuture = loadTask();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Task>>(
      future: tasksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if(snapshot.hasError){
          return Center(
            child: Text("Błąd ${snapshot.error}"),
          );
        }

        final tasks = snapshot.data ?? [];
        return ListView(
          children: tasks.map((task) {
            return TaskCard(
              title: task.title,
              subtitle: task.deadline,
              icon: task.done ? Icons.check_circle : Icons.radio_button_checked,
              priority: task.priority,
              done: task.done,
              onChange: (value) {
                  setState(() {
                  task.done = value!;
                });
            },
            onTap: () async {
            final Task? updatedTask = await Navigator.push(
            context,
            MaterialPageRoute(
            builder: (context) => EditTaskScreen(task: task)
            )
            );

            if (updatedTask != null) {
                await TaskLocalDatabase.updateTask(updatedTask);
                setState(() {
                tasksFuture = loadTask();
                });
              }
            },
            );
          }).toList(),
        );
      },
    );
  }
}