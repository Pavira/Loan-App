import 'package:flutter/material.dart';

class CustomDialogBox extends StatelessWidget {
  final String? title;
  final String? content;
  final VoidCallback onYesPressed;
  final VoidCallback onCancelPressed;

  const CustomDialogBox({
    Key? key,
    required this.onYesPressed,
    required this.onCancelPressed,
    this.title,
    this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title!),
      content: Text(content!),
      actions: [
        TextButton(onPressed: onCancelPressed, child: const Text('Cancel')),
        ElevatedButton(
          onPressed: onYesPressed,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Yes'),
        ),
      ],
    );
  }
}
