import "package:flutter/material.dart";
import "../models/task.dart";

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
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
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