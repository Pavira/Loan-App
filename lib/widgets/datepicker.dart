import 'package:flutter/material.dart';
import 'package:loan_app/core/theme/app_theme.dart';

class CustomDatePicker extends StatefulWidget {
  // final String? labelText;
  final String hintText;
  final TextEditingController? controller;
  final Function(DateTime)? onDateSelected;

  const CustomDatePicker({
    Key? key,
    // this.labelText,
    required this.hintText,
    this.controller,
    this.onDateSelected,
  }) : super(key: key);

  @override
  _CustomDatePickerState createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  late TextEditingController _dobController;

  @override
  void initState() {
    super.initState();
    _dobController = widget.controller ?? TextEditingController();
  }

  @override
  void dispose() {
    _dobController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      // lastDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 100)),
    );

    if (picked != null) {
      setState(() {
        _dobController.text =
            // "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
            "${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}";
      });

      if (widget.onDateSelected != null) {
        widget.onDateSelected!(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   widget.labelText ?? "",
        //   style: GoogleFonts.raleway(
        //     textStyle: const TextStyle(
        //       color: Colors.black,
        //       fontWeight: FontWeight.normal,
        //       fontSize: 16,
        //     ),
        //   ),
        // ),
        // const SizedBox(height: 8),
        TextField(
          controller: _dobController,
          readOnly: true,
          onTap: () => _selectDate(context),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white, // Background color white
            hintText: widget.hintText,
            hintStyle: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.normal,
              fontSize: 16,
            ),
            border: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.black), // Black border
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.grey,
              ), // Black border when not focused
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: buttonColor,
              ), // Thicker black border when focused
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
