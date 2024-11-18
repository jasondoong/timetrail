import 'package:flutter/material.dart';
import 'package:timetrail/models/task.dart';
import 'package:timetrail/shared/text_input_dialog.dart';
import 'stopwatch_widget.dart';
import 'record_table_widget.dart';

class StopwatchScreen extends StatefulWidget {
  final Task task;

  StopwatchScreen({required this.task});

  @override
  _StopwatchScreenState createState() => _StopwatchScreenState();
}

class _StopwatchScreenState extends State<StopwatchScreen> {
  void _handleFinish() {
    setState(() {
      // Trigger a rebuild to display new record
    });
  }

  void _editMemo(Task task, Record recordToModify) async {
    final newMemo = await showDialog<String>(
      context: context,
      builder: (context) {
        return TextInputDialog(
          title: '編輯備註',
          hintText: '輸入備註',
          initialText: recordToModify.memo,
        );
      },
    );

    if (newMemo != null) {
      final index = task.records?.indexWhere((record) => record == recordToModify);
      if (index != null) {
        task.records?[index].memo = newMemo;
        await isarService.updateTask(task);
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.name),
        backgroundColor: colorScheme.secondaryFixed,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (!widget.task.closed)
            StopwatchWidget(
              task: widget.task,
              onFinish: _handleFinish,
            ),
          Expanded(
            child: SingleChildScrollView(
              child: RecordTableWidget(
                task: widget.task,
                onEditMemo: _editMemo,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
