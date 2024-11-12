import 'package:flutter/material.dart';
import 'package:timetrail/models/task.dart';
import 'package:timetrail/screens/home/task_card.dart';
import 'package:timetrail/services/isar_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

// Service instance for Isar database operations
IsarService isarService = IsarService();

class _HomeScreenState extends State<HomeScreen> {

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

    return Scaffold(
      appBar: AppBar(
        title: const Text("任務列表"),
        backgroundColor: colorScheme.secondaryFixed,
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
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (_, index) {
                        return TaskCard(snapshot.data![index]);
                      },
                    );
                  }
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