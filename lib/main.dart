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
  String selectedFilter = "wszystkie";
  @override
  Widget build(BuildContext context){
    var taskCountDone = TasksRepository.tasks.where((task) => task.done).length;

    final tasks = TasksRepository.tasks.where((task) {
      if (selectedFilter == "zrobione") return task.done;
      if (selectedFilter == "do zrobienia") return !task.done;
      return true;
    }).toList();
    return Scaffold(

      appBar: AppBar(
        title: Text("KrakFlow"),
        actions: [
          IconButton(onPressed: TasksRepository.tasks.isEmpty ? null : (){
            showDialog(context: context, builder: (context){
              return AlertDialog(
                title: Text("Potwierdzenie"),
                content: Text("Czy na pewno chcesz usunac wszystkie zadania?"),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: Text("Anuluj")),
                  TextButton(onPressed: () {
                    setState(() {
                      TasksRepository.tasks.clear();
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
          color: TasksRepository.tasks.isEmpty ? Colors.grey : Colors.red))
        ],
      ),

      body:
      Padding(
          padding: EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text("Masz dziś ${TasksRepository.tasks.length} zadań"),
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

                      itemCount: tasks.length,
                      itemBuilder: (context, index) {

                        final task = tasks[index];
                        return Dismissible(
                            key: ValueKey(task.title),
                            direction: DismissDirection.endToStart,
                            onDismissed: (direction) {setState(() {
                              TasksRepository.tasks.remove(task);
                              });
                            },
                            child: TaskCard(
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
                                    setState(() {
                                      final index = TasksRepository.tasks.indexOf(task);
                                      TasksRepository.tasks[index] = updatedTask;
                                    });
                                  }
                                },
                            )
                        );
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