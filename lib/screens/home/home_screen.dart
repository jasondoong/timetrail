import 'dart:io';

import 'package:flutter/material.dart';
import 'package:timetrail/models/task.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:timetrail/screens/home/task_card.dart';
import 'package:timetrail/services/isar_service.dart';

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


  // Export tasks to an Excel file
  Future<void> _exportTasks() async {
    // Fetch tasks from the database
    List<Task> tasks = await isarService.getAllTasks();

    // Create a new Excel workbook
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Tasks'];

    // Add headers
    sheetObject.appendRow([TextCellValue("ID"), TextCellValue("Name"), TextCellValue("Status")]);

    // Populate rows with task data
    for (var task in tasks) {
      sheetObject.appendRow([TextCellValue(task.id.toString()), TextCellValue(task.name), TextCellValue(task.closed ? "Closed" : "Open")]);
    }

    // Save the file to temporary directory
    var fileBytes = excel.encode();
    Directory tempDir = await getTemporaryDirectory();
    String filePath = "${tempDir.path}/tasks.xlsx";
    File(filePath)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes!);

    // Share the file
    await Share.shareFiles([filePath], text: "Exported Tasks");
  }


  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;

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
            onPressed: _exportTasks,
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
                    return CircularProgressIndicator();
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