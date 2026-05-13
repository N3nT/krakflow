import 'package:flutter/material.dart';
import 'package:krakflow/services/task_local_database.dart';
import '../widgets/filter_bar.dart';
import "add_task_screen.dart";
import "task_list_screen.dart";
import "../models/task.dart";
import '../services/task_sync_service.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  String selectedFilter = "wszystkie";
  late Future<List<Task>> tasksFuture;

  int allTasksCount = 0;
  int doneTasksCount = 0;
  int todoTasksCount = 0;

  void updateCounters(List<Task> tasks) {
    setState(() {
      allTasksCount = tasks.length;
      doneTasksCount = tasks.where((t) => t.done).length;
      todoTasksCount = tasks.where((t) => !t.done).length;
    });
  }

  Future<List<Task>> loadTasks() async {
    await TaskSyncService.loadInitialDataIfNeeded();
    return TaskLocalDatabase.getTasks();
  }

  void onFilterChange(String filter){
    setState(() {
      selectedFilter = filter;
    });
  }

  Future<void> openAddTask() async {
    final result = await Navigator.push(
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
        )
    );

    if(result != null){
      await TaskLocalDatabase.addTask(result);
      setState(() {
        tasksFuture = loadTasks();
      });
    }
  }

  void deleteAllDialog() {
    showDialog(context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Potwierdzenie"),
            content: Text("Czy na pewno chcesz usunac wszystkie zadania?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text("Anuluj")),
              TextButton(onPressed: () async {
                await TaskLocalDatabase.deleteAllTasks();
                setState(() {
                  tasksFuture = loadTasks();
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
        }
    );
  }

  @override
  void initState() {
    super.initState();
    tasksFuture = loadTasks();
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("KrakFlow"),
        actions: [
              IconButton(onPressed: deleteAllDialog,
              icon: const Icon(Icons.delete, color: Colors.red)
            )
          ],
      ),

      body:
      Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Masz dziś ${allTasksCount} zadań"),

              SizedBox(height: 16),
              FilterBar(
                selectedFilter: selectedFilter,
                onFilterChanged: onFilterChange,
              ),

              SizedBox(height: 16),
              Text("Wykonano ${doneTasksCount} zadań",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,),
              ),

              SizedBox(height: 16),
              Text("Dzisiejsze zadania ${todoTasksCount}:",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              Expanded(
                  child: FutureBuilder(future: tasksFuture, builder: (context, snapshot) {
                    if(!snapshot.hasData){
                      return const Center(child: CircularProgressIndicator());
                    }

                    return TaskListScreen(
                      onTasksLoaded: updateCounters,
                    );
                  })
              ),

            ],

          )
      ),
      floatingActionButton:
      FloatingActionButton(
        onPressed: openAddTask,
        child: Icon(Icons.add),
      ),
    );
  }
}