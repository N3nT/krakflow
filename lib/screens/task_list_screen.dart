import 'package:flutter/material.dart';

import '../models/task.dart';
import '../services/task_local_database.dart';

import '../widgets/task_card.dart';
import 'edit_task_screen.dart';

class TaskListScreen extends StatefulWidget {
  final ValueChanged<List<Task>> onTasksLoaded;

  const TaskListScreen({
    super.key,
    required this.onTasksLoaded,
  });

  @override
  State<TaskListScreen> createState() =>
      _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  late Future<List<Task>> tasksFuture;

  Future<List<Task>> loadTasks() async {
    return TaskLocalDatabase.getTasks();
  }

  @override
  void initState() {
    super.initState();
    tasksFuture = loadTasks();
  }

  Future<void> reload() async {
    final tasks = await loadTasks();

    setState(() {
      tasksFuture = Future.value(tasks);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onTasksLoaded(tasks);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Task>>(
      future: tasksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text("Błąd ${snapshot.error}"),
          );
        }

        final tasks = snapshot.data ?? [];

        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.onTasksLoaded(tasks);
        });

        return ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];

            return Dismissible(
              key: ValueKey(task.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerRight,
                padding:
                const EdgeInsets.only(right: 16),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              onDismissed: (_) async {
                await TaskLocalDatabase.deleteTask(task.id);

                final updatedTasks = List<Task>.from(tasks)
                  ..removeWhere((t) => t.id == task.id);

                setState(() {
                  tasksFuture = Future.value(updatedTasks);
                });

                widget.onTasksLoaded(updatedTasks);
              },
              child: TaskCard(
                title: task.title,
                subtitle: task.deadline,
                icon: task.done
                    ? Icons.check_circle
                    : Icons.radio_button_checked,
                priority: task.priority,
                done: task.done,

                onChange: (value) async {
                  task.done = value!;
                  await TaskLocalDatabase.updateTask(
                    task,
                  );
                  await reload();
                },

                onTap: () async {
                  final updatedTask =
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EditTaskScreen(task: task),
                    ),
                  );

                  if (updatedTask != null) {
                    await TaskLocalDatabase.updateTask(
                      updatedTask,
                    );
                    await reload();
                  }
                },
              ),
            );
          },
        );
      },
    );
  }
}