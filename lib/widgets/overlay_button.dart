import 'package:flutter/material.dart';

class OverlayButton extends StatelessWidget {
  final VoidCallback onPressed;

  const OverlayButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.blue,
      child: Icon(Icons.add, color: Colors.white),
    );
  }
}
