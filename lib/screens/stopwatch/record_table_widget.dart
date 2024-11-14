// record_table_widget.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timetrail/models/task.dart';
import 'package:timetrail/utils/format_time.dart';

class RecordTableWidget extends StatelessWidget {
  final Task task;
  final void Function(Task, Record) onEditMemo;

  const RecordTableWidget({
    Key? key,
    required this.task,
    required this.onEditMemo,
  }) : super(key: key);

  // Calculate total time span from records in seconds
  String _getTotalTimeSpan() {
    int totalSeconds = task.records?.fold<int?>(0, (sum, record) {
      return (sum ?? 0) + (record.seconds ?? 0);
    }) ?? 0;

    return formatRecordTime(totalSeconds);
  }

  @override
  Widget build(BuildContext context) {
    final headerStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87);
    final rowTextStyle = TextStyle(fontSize: 14, color: Colors.black87);
    final totalTimeStyle = TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey);

    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          '工作紀錄',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Table(
            columnWidths: const {
              0: FractionColumnWidth(0.3),
              1: FractionColumnWidth(0.3),
              2: FractionColumnWidth(0.4),
            },
            border: TableBorder(
              horizontalInside: BorderSide(width: 1, color: Colors.grey[300]!),
              verticalInside: BorderSide(width: 1, color: Colors.grey[300]!),
            ),
            children: [
              // Header row with a light background color
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.grey[300], // Light grey background for header
                  borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                ),
                children: [
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('紀錄時間', style: headerStyle),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('工時', style: headerStyle),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('備註', style: headerStyle),
                    ),
                  ),
                ],
              ),
              // Data rows with alternating colors and padding
              ...task.records?.asMap().entries.map((entry) {
                int index = entry.key;
                Record record = entry.value;
                final isEvenRow = index % 2 == 0;
                return TableRow(
                  decoration: BoxDecoration(
                    color: isEvenRow ? Colors.grey[100] : Colors.white,
                  ),
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          DateFormat('yyyy-MM-dd HH:mm').format(record.recordAt!),
                          style: rowTextStyle,
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          formatRecordTime(record.seconds ?? 0),
                          style: rowTextStyle,
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () => onEditMemo(task, record),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  record.memo ?? '',
                                  style: rowTextStyle,
                                ),
                              ),
                              Icon(Icons.edit, size: 16, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList() ?? [],
            ],
          ),
        ),
        // Total time display with more padding and a larger font
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '總工時: ${_getTotalTimeSpan()}',
                style: totalTimeStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
