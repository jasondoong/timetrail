import 'package:flutter/material.dart';
import 'package:timetrail/shared/styled_text.dart';

class TaskCard extends StatelessWidget {
  const TaskCard(this.task, {super.key});

  final String task;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            StyledText(task),
          ]
        ),
      ),
    );
  }
}