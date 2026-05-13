import "package:flutter/material.dart";

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