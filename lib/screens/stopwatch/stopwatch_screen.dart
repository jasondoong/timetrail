import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timetrail/models/task.dart';
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

    return _formatRecordTime(totalSeconds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task.name),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          StopwatchWidget(
            task: widget.task,
            onFinish: _handleFinish,
          ),
          SizedBox(height: 20),
          Text(
            '工作紀錄',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
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
                            _formatRecordTime(record.seconds ?? 0),
                            style: TextStyle(fontSize: 16),
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

  // Format the time in hours:minutes:seconds
  String _formatRecordTime(int seconds) {
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    final int displaySeconds = seconds % 60;
    return '${hours.toString().padLeft(2, '0')}時'
           '${minutes.toString().padLeft(2, '0')}分'
           '${displaySeconds.toString().padLeft(2, '0')}秒';
  }
}
