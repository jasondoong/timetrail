import 'dart:async';
import 'package:flutter/material.dart';
import 'package:timetrail/models/task.dart';
import 'package:timetrail/services/isar_service.dart';

class StopwatchWidget extends StatefulWidget {
  final Task task;
  final Function onFinish;

  StopwatchWidget({required this.task, required this.onFinish});

  @override
  _StopwatchWidgetState createState() => _StopwatchWidgetState();
}

IsarService isarService = IsarService();

class _StopwatchWidgetState extends State<StopwatchWidget> {
  Timer? _timer;
  int _seconds = 0;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    // Initialize _seconds from widget.task.unsavedSeconds here
    _seconds =
        widget.task.unsavedSeconds ?? 0; // Use null-ish coalescing operator
  }

  void _startTimer() {
    if (_isRunning) return;
    setState(() {
      _isRunning = true;
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
      if (_seconds % 5 == 0) {
        // Periodically save the current timer state (every 5 seconds)
        // to the database to enable recovery from unexpected app termination
        // (e.g., system crashes, battery depletion).
        isarService.saveUnsavedSeconds(widget.task, _seconds);
      }
    });
  }

  void _pauseTimer() {
    if (!_isRunning) return;
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
    _saveUnsavedSeconds();
  }

  Future<void> _saveUnsavedSeconds() async {
    isarService.saveUnsavedSeconds(widget.task, _seconds);
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
    _showAdjustTimeDialog();
  }

  Future<void> _showAdjustTimeDialog() async {
    int hours = _seconds ~/ 3600;
    int minutes = (_seconds % 3600) ~/ 60;
    int displaySeconds = _seconds % 60;

    TextEditingController hourController =
        TextEditingController(text: hours.toString());
    TextEditingController minuteController =
        TextEditingController(text: minutes.toString());
    TextEditingController secondController =
        TextEditingController(text: displaySeconds.toString());

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("調整計時結果"),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: TextField(
                  controller: hourController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "小時"),
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: TextField(
                  controller: minuteController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "分鐘"),
                ),
              ),
              SizedBox(width: 10),
              Flexible(
                child: TextField(
                  controller: secondController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: "秒"),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("取消"),
            ),
            TextButton(
              onPressed: () async {
                int adjustedHours = int.tryParse(hourController.text) ?? 0;
                int adjustedMinutes = int.tryParse(minuteController.text) ?? 0;
                int adjustedSeconds = int.tryParse(secondController.text) ?? 0;

                _seconds = adjustedHours * 3600 +
                    adjustedMinutes * 60 +
                    adjustedSeconds;

                final record = Record(
                  recordAt: DateTime.now(),
                  seconds: _seconds,
                );

                // Make a modifiable copy of the records list
                final newRecords = List<Record>.from(widget.task.records ?? []);
                newRecords.add(record);

                // Update task's records and save it to Isar
                widget.task.records = newRecords;
                await isarService.updateTask(widget.task);

                setState(() {
                  // reset seconds
                  _seconds = 0;
                });

                widget.onFinish();
                Navigator.of(context).pop();
              },
              child: Text("確定"),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(int seconds) {
    final int hours = seconds ~/ 3600;
    final int minutes = (seconds % 3600) ~/ 60;
    final int displaySeconds = seconds % 60;

    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${displaySeconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Timer Display
        Card(
          color: colorScheme.primaryContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
            child: Text(
              _formatTime(_seconds),
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Action Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              onPressed: _isRunning ? null : _startTimer,
              icon: Icon(Icons.play_arrow),
              iconSize: 36,
              color: _isRunning ? Colors.grey : colorScheme.primary,
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: _isRunning ? _pauseTimer : null,
              icon: Icon(Icons.pause),
              iconSize: 36,
              color: _isRunning ? colorScheme.secondary : Colors.grey,
            ),
            const SizedBox(width: 10),
            IconButton(
              onPressed: _stopTimer,
              icon: Icon(Icons.stop),
              iconSize: 36,
              color: colorScheme.error,
            ),
          ],
        ),
      ],
    );
  }
}
