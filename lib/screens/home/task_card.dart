import 'package:flutter/material.dart';
import 'package:timetrail/models/task.dart';
import 'package:timetrail/shared/styled_text.dart';

class TaskCard extends StatelessWidget {
  const TaskCard(this.task, {super.key});

  final Task task;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('${task.id}:'),
                  const SizedBox(width: 8),
                  Expanded(child: StyledText(task.name)),
                  Text('closed: ${task.closed}')
                ],
              )
            ),
            IconButton(
              onPressed: () {}, 
              icon: const Icon(Icons.arrow_forward),
            )
          ]
        ),
      ),
    );
  }
}