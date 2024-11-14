// text_input_dialog.dart
import 'package:flutter/material.dart';

class TextInputDialog extends StatelessWidget {
  final String title;
  final String hintText;
  final String? initialText;

  const TextInputDialog({
    Key? key,
    required this.title,
    required this.hintText,
    this.initialText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController textController = TextEditingController(text: initialText);

    return AlertDialog(
      title: Text(title),
      content: TextField(
        controller: textController,
        decoration: InputDecoration(hintText: hintText),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text("取消"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(textController.text); // Return the input text
          },
          child: Text("儲存"),
        ),
      ],
    );
  }
}
