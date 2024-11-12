import 'package:flutter/material.dart';
import 'package:timetrail/models/task.dart';
import 'package:timetrail/screens/home/home_screen.dart';
import 'package:timetrail/screens/stopwatch/stopwatch_screen.dart';
import 'package:timetrail/shared/styled_text.dart';

class TaskCard extends StatelessWidget {
  const TaskCard(this.task, {super.key});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: StyledText(task.name)),
                  SizedBox(width: 3),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.onSecondaryContainer,
                      backgroundColor: colorScheme.secondaryContainer,
                    ),
                    onPressed: () {
                    },
                    child: Text('改名')
                  ),
                  SizedBox(width: 3),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.onError,
                      backgroundColor: colorScheme.error,
                    ),
                    onPressed: () {},
                    child: Text('結案')
                  ),
                  SizedBox(width: 3),
                ],
              )
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => StopwatchScreen(task: task),
                  )
                );
              }, 
              icon: const Icon(Icons.arrow_forward),
            )
          ]
        ),
      ),
    );
  }
}