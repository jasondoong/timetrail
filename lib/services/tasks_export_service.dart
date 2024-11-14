  import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timetrail/models/task.dart';
import 'package:excel/excel.dart';
import 'package:timetrail/services/isar_service.dart';

import '../utils/format_time.dart';


class TasksExportService {

  TasksExportService(this.isarService, this.context);

  final IsarService isarService;
  final context;

  // Export tasks to an Excel file with each task on a separate sheet
  Future<void> exportTasks() async {
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
      sheetObject.appendRow([TextCellValue("任務編號"), TextCellValue("任務名稱"), TextCellValue("是否結案")]);
      sheetObject.appendRow([TextCellValue(task.id.toString()), TextCellValue(task.name), TextCellValue(task.closed ? "已結案" : "未結案")]);

      // Leave a blank row before records
      sheetObject.appendRow([TextCellValue("")]);

      // Headers for records
      sheetObject.appendRow([TextCellValue("紀錄時間"), TextCellValue("工時"), TextCellValue("備註")]);

      // Populate rows with record data for each task
      if (task.records != null && task.records!.isNotEmpty) {
        for (var record in task.records!) {
          sheetObject.appendRow([
            TextCellValue(DateFormat('yyyy-MM-dd HH:mm').format(record.recordAt!)),
            TextCellValue(formatRecordTime(record.seconds ?? 0)),
            TextCellValue(record.memo ?? ""),
          ]);
        }
      } else {
        sheetObject.appendRow([TextCellValue("無紀錄")]);
      }
    }

    // Encode the Excel file
    var fileBytes = excel.encode();

    // Use FilePicker to select a location to save the file
    String? outputPath = await FilePicker.platform.saveFile(
      dialogTitle: '匯出至',
      fileName: '工時紀錄.xlsx',
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
        SnackBar(content: Text("已匯出至$outputPath")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("匯出失敗")),
      );
    }
  }
}
