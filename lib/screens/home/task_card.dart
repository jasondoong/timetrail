import 'package:flutter/material.dart';
import 'package:timetrail/models/task.dart';
import 'package:timetrail/screens/home/home_screen.dart';
import 'package:timetrail/screens/stopwatch/stopwatch_screen.dart';
import 'package:timetrail/shared/styled_text.dart';
import 'package:timetrail/shared/text_input_dialog.dart';

import 'close_task_dialog.dart';

class TaskCard extends StatelessWidget {
  const TaskCard(this.task, {super.key});

  final Task task;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    
    void _showRenameDialog(BuildContext context) async {
      final result = await showDialog<String>(
        context: context,
        builder: (context) {
          return TextInputDialog(
            title: '改名',
            hintText: '輸入新名稱',
            initialText: task.name,
          );
        },
      );

      if (result != null && result.isNotEmpty && result != task.name) {
        task.name = result;
        await isarService.updateTask(task);
      }
    }

    void _showCloseTaskDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) {
          return CloseTaskDialog(
            task: task,
            onTaskUpdate: isarService.updateTask, // Pass the update function
          );
        },
      );
    }

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
                    onPressed: () => _showRenameDialog(context),
                    child: Text('改名')
                  ),
                  SizedBox(width: 3),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: task.closed? colorScheme.onSecondaryContainer : colorScheme.surface,
                      backgroundColor: task.closed? colorScheme.secondaryContainer : colorScheme.outline,
                    ),
                    onPressed: () => _showCloseTaskDialog(context),
                    child: Text(task.closed ? '恢復專案': '結案')
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