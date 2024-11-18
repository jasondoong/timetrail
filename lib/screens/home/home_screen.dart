import 'package:flutter/material.dart';
import 'package:timetrail/models/task.dart';
import 'package:timetrail/screens/home/task_card.dart';
import 'package:timetrail/services/isar_service.dart';
import 'package:timetrail/services/tasks_export_service.dart';
import 'package:timetrail/shared/styled_text.dart';
import 'package:timetrail/shared/text_input_dialog.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

// Service instance for Isar database operations
IsarService isarService = IsarService();

class _HomeScreenState extends State<HomeScreen> {
  bool _showClosedTasks = false;
  final ScrollController _scrollController = ScrollController();

  void _openTextInputDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return TextInputDialog(
          title: "新增任務",
          hintText: "輸入任務名稱",
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
          Text(
            _showClosedTasks ? '已結案' : '未結案',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          Switch(
            value: _showClosedTasks,
            onChanged: (value) => setState(() => _showClosedTasks = value),
          ),
          IconButton(
            icon: Icon(Icons.download),
            onPressed: tasksExportService.exportTasks,
            tooltip: "匯出所有任務",
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
                      if (filteredTasks.isEmpty) {
                        return Center(
                          child: StyledText(_showClosedTasks ? '沒有已結案任務': '沒有任何任務，請新增一個新的任務。')
                        );
                      }
                      return Scrollbar(
                        thumbVisibility: true,
                        controller: _scrollController,
                        child: ListView.builder(
                          itemCount: filteredTasks.length,
                          itemBuilder: (_, index) => TaskCard(filteredTasks[index], isarService),
                          controller: _scrollController,
                          scrollDirection: Axis.vertical,
                        ),
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