import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loan_app/core/theme/app_theme.dart';

class AnimatedTextField extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool isReadOnly;
  final Color color;
  final List<TextInputFormatter>? inputFormatter; // Add this line
  final TextInputType? keyboardType; // ✅ Add this

  const AnimatedTextField({
    Key? key,
    required this.label,
    this.controller,
    this.focusNode,
    this.isReadOnly = false,
    this.color = Colors.white,
    this.inputFormatter, // Add this line
    this.keyboardType, // ✅ Add this
  }) : super(key: key);

  @override
  _AnimatedTextFieldState createState() => _AnimatedTextFieldState();
}

class _AnimatedTextFieldState extends State<AnimatedTextField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller =
        widget.controller ?? TextEditingController(); // Use passed controller
    _focusNode =
        widget.focusNode ?? FocusNode(); // Use passed focusNode if available

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus || _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller
          .dispose(); // Only dispose if it was created inside this widget
    }
    if (widget.focusNode == null) {
      _focusNode.dispose(); // Dispose only if created internally
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      // Set text color
      controller: _controller,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatter, // Pass it here
      focusNode: _focusNode,
      readOnly: widget.isReadOnly, // Ensure this makes the field readonly
      // style: TextStyle(
      //   color: widget.isReadOnly ? Colors.grey.shade500 : Colors.black,
      // ), // Set text color
      decoration: InputDecoration(
        //If you want to add padding inside the text field
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 12.0,
        ),
        filled: true,
        fillColor:
            widget.isReadOnly
                ? Colors.grey.shade300
                : Colors.white, // Set background color

        labelText: widget.label,
        labelStyle: TextStyle(
          color: _isFocused ? textBoardColor : Colors.grey,
          fontSize: _isFocused ? 16 : 18,
          fontWeight: _isFocused ? FontWeight.bold : FontWeight.normal,
        ),
        // Light grey border when not focused
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: textBoardColor, width: 2),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}
