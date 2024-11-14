import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:timetrail/models/task.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timetrail/screens/home/task_card.dart';
import 'package:timetrail/services/isar_service.dart';
import 'package:timetrail/services/tasks_export_service.dart';
import 'package:timetrail/shared/styled_text.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

// Service instance for Isar database operations
IsarService isarService = IsarService();

class _HomeScreenState extends State<HomeScreen> {
  bool _showClosedTasks = false;

  void _openTextInputDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        String inputText = "";
        return AlertDialog(
          title: Text("新增任務"),
          content: TextField(
            onChanged: (value) {
              inputText = value;
            },
            decoration: InputDecoration(hintText: "輸入任務名稱"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without saving
              },
              child: Text("取消"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(inputText); // Return the input text
              },
              child: Text("儲存"),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      await isarService.saveTask(Task(name: result, closed: false));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final TasksExportService tasksExportService = TasksExportService(isarService, context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("任務列表"),
        backgroundColor: colorScheme.secondaryFixed,
        actions: [
          Text(_showClosedTasks ? '已結案' : '未結案'),
          Switch(
            value: _showClosedTasks,
            onChanged: (value) => setState(() => _showClosedTasks = value),
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: tasksExportService.exportTasks,
            tooltip: "Export tasks",
          ),
          SizedBox(width: 16),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: StreamBuilder<List<Task>>(
                  stream: isarService.listenTask(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final filteredTasks = snapshot.data!.where((task) =>
                          _showClosedTasks == task.closed).toList(); // Filter tasks
                      return ListView.builder(
                        itemCount: filteredTasks.length,
                        itemBuilder: (_, index) => TaskCard(filteredTasks[index]),
                      );
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    }

                    // Display a loading indicator while waiting for data
                    return Center(
                      child: StyledText('Loading...')
                    );
                  },
                ),
              ),
              FloatingActionButton(
                onPressed: _openTextInputDialog,
                child: Icon(Icons.add),
              ),
            ],
          ),
        ),
      ),
    );
  }
}