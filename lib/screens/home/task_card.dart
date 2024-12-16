import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timetrail/models/task.dart';
import 'package:timetrail/screens/stopwatch/stopwatch_screen.dart';
import 'package:timetrail/services/isar_service.dart';
import 'package:timetrail/shared/styled_text.dart';
import 'package:timetrail/shared/text_input_dialog.dart';

import 'close_task_dialog.dart';

class TaskCard extends StatelessWidget {
  const TaskCard(this.task, this.isarService, {super.key});

  final Task task;
  final IsarService isarService;

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

    String _unsavedSecondsFormatting(int? seconds) {
      if (seconds is Null) {
        return '';
      }
      int hours = seconds ~/ 3600;
      int minutes = (seconds % 3600) ~/ 60;
      int displaySeconds = seconds % 60;
      return "${NumberFormat('00').format(hours)}:${NumberFormat('00').format(minutes)}:${NumberFormat('00').format(displaySeconds)}";
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                StyledText(task.name),
                SizedBox(height: 8),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: colorScheme.secondary),
                      onPressed: () => _showRenameDialog(context),
                      tooltip: '改名',
                    ),
                    IconButton(
                      icon: Icon(
                        task.closed ? Icons.undo : Icons.check,
                        color: task.closed
                            ? colorScheme.primary
                            : colorScheme.error,
                      ),
                      onPressed: () => _showCloseTaskDialog(context),
                      tooltip: task.closed ? '恢復專案' : '結案',
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (task.unsavedSeconds != null)
            StyledText("已暫停 ${_unsavedSecondsFormatting(task.unsavedSeconds)}"),
          IconButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => StopwatchScreen(task: task),
                  ));
            },
            icon: const Icon(Icons.arrow_forward),
          )
        ]),
      ),
    );
  }
}
