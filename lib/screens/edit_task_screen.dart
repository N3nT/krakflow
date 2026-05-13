import 'package:flutter/material.dart';
import '../models/task.dart';

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
