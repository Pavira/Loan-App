import 'package:flutter/material.dart';

void showCustomSnackbar(BuildContext context, String text, {Color? color}) {
  final snackBar = SnackBar(
    content: Text(text, style: TextStyle(color: Colors.white, fontSize: 16)),
    backgroundColor:
        color ?? Colors.red, // Default to red if no color is provided
    duration: Duration(seconds: 2),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
