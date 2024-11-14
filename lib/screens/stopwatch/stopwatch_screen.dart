import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timetrail/models/task.dart';
import 'package:timetrail/shared/text_input_dialog.dart';
import 'package:timetrail/utils/format_time.dart';
import 'stopwatch_widget.dart';

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

  // Calculate total time span from records in seconds
  String _getTotalTimeSpan() {
    int totalSeconds = widget.task.records?.fold<int?>(0, (sum, record) {
      // Ensure that sum is nullable and handle null by checking for null values explicitly.
      return (sum ?? 0) + (record.seconds ?? 0); 
    }) ?? 0; // If task.records is null, default to 0 seconds

    return formatRecordTime(totalSeconds);
  }

  // Function to edit memo in a dialog
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
      // Find the index of the record to modify
      final index = task.records?.indexWhere((record) => record == recordToModify);
      if (index != null) {
        task.records?[index].memo = newMemo;
        await isarService.updateTask(task);
        setState(() {
        });
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
          if (! widget.task.closed) StopwatchWidget(
            task: widget.task,
            onFinish: _handleFinish,
          ),
          SizedBox(height: 20),
          Text(
            '工作紀錄',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Table(
              border: TableBorder.all(
                color: Colors.black,
                width: 1,
              ),
              children: [
                TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('紀錄時間', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('工時', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('備註', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
                // Displaying records in table format
                ...widget.task.records?.map((record) {
                  return TableRow(
                    children: [
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            DateFormat('yyyy-MM-dd HH:mm').format(record.recordAt!),
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            formatRecordTime(record.seconds ?? 0),
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: () {
                              _editMemo(widget.task, record);
                            },
                            child: Text(
                              record.memo ?? '',
                              style: TextStyle(fontSize: 16, color: const Color.fromARGB(255, 13, 45, 61)),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList() ??
                [],
              ],
            ),
          ),
          // Display total time span under the table
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '總工時: ${_getTotalTimeSpan()}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
