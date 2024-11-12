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

    void _showRenameDialog(BuildContext context) {
      final newTaskNameController = TextEditingController(text: task.name);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('改名'),
            content: TextField(
              controller: newTaskNameController,
              decoration: InputDecoration(hintText: '輸入新名稱'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('取消'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (newTaskNameController.text.isNotEmpty) {
                    task.name = newTaskNameController.text;
                    await isarService.updateTask(task);                    
                  }
                  
                  Navigator.pop(context);
                },
                child: Text('儲存'),
              ),
            ],
          );
        },
      );
    }

    void _showCloseTaskDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(task.closed ? '復原專案' : '結案'),
            content: Text('確定要${task.closed ? '復原': '結案'}「${task.name}」嗎？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('取消'),
              ),
              ElevatedButton(
                onPressed: () async {
                  task.closed = !task.closed;
                  await isarService.updateTask(task);                    
                  Navigator.pop(context);
                },
                child: Text(task.closed ? '復原': '結案'),
              ),
            ],
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
                      foregroundColor: task.closed? colorScheme.onSecondaryContainer : colorScheme.onError,
                      backgroundColor: task.closed? colorScheme.secondaryContainer : colorScheme.error,
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