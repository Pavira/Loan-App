import 'package:flutter/material.dart';

class TimePickerField extends StatefulWidget {
  final String label;
  final TextEditingController controller;

  const TimePickerField({
    Key? key,
    required this.label,
    required this.controller,
  }) : super(key: key);

  @override
  _TimePickerFieldState createState() => _TimePickerFieldState();
}

class _TimePickerFieldState extends State<TimePickerField> {
  Future<void> _selectTime(BuildContext context) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        widget.controller.text = pickedTime.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      readOnly: true,
      onTap: () => _selectTime(context),
      decoration: InputDecoration(
        labelText: widget.label,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        suffixIcon: const Icon(
          Icons.access_time,
          color: Colors.grey,
        ), // Clock Icon
      ),
    );
  }
}
