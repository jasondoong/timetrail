import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:timetrail/models/task.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
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


  // Export tasks to an Excel file with each task on a separate sheet
  Future<void> _exportTasks() async {
    // Fetch tasks from the database
    List<Task> tasks = await isarService.getAllTasks();

    // Create a new Excel workbook
    var excel = Excel.createExcel();
    excel.delete('Sheet1');

    for (var task in tasks) {
      // Create a new sheet for each task, named after the task name
      String sheetName = task.name.length > 31 ? task.name.substring(0, 31) : task.name; // Ensure sheet name is within Excel's 31-char limit
      Sheet sheetObject = excel[sheetName];

      // Add headers for task info and records
      sheetObject.appendRow([TextCellValue("Task ID"), TextCellValue("Name"), TextCellValue("Status")]);
      sheetObject.appendRow([TextCellValue(task.id.toString()), TextCellValue(task.name), TextCellValue(task.closed ? "Closed" : "Open")]);

      // Leave a blank row before records
      sheetObject.appendRow([TextCellValue("")]);

      // Headers for records
      sheetObject.appendRow([TextCellValue("Record At"), TextCellValue("Seconds"), TextCellValue("Memo")]);

      // Populate rows with record data for each task
      if (task.records != null && task.records!.isNotEmpty) {
        for (var record in task.records!) {
          sheetObject.appendRow([
            TextCellValue(record.recordAt?.toIso8601String() ?? "N/A"),
            TextCellValue(record.seconds?.toString() ?? "N/A"),
            TextCellValue(record.memo ?? ""),
          ]);
        }
      } else {
        sheetObject.appendRow([TextCellValue("No records available")]);
      }
    }

    // Encode the Excel file
    var fileBytes = excel.encode();

    // Use FilePicker to select a location to save the file
    String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Select Output Location',
      fileName: 'tasks_with_records.xlsx',
    );

    if (outputPath != null && fileBytes != null) {
      if (!outputPath.endsWith('.xlsx')) {
        outputPath = '$outputPath.xlsx';
      }
      
      // Save the file to the selected location
      File(outputPath)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("File saved to $outputPath")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("File saving was cancelled.")),
      );
    }
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