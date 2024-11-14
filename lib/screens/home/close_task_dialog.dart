import 'package:flutter/material.dart';
import 'package:timetrail/models/task.dart';

class CloseTaskDialog extends StatelessWidget {
  final Task task;
  final Future<void> Function(Task) onTaskUpdate;

  const CloseTaskDialog({
    Key? key,
    required this.task,
    required this.onTaskUpdate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            await onTaskUpdate(task); // Call the update function with the modified task
            Navigator.pop(context);
          },
          child: Text(task.closed ? '復原' : '結案'),
        ),
      ],
    );
  }
}
