import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loan_app/core/theme/app_theme.dart';

class AnimatedTextArea extends StatefulWidget {
  final String label;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool isReadOnly;
  final Color color;
  final List<TextInputFormatter>? inputFormatter;

  const AnimatedTextArea({
    Key? key,
    required this.label,
    this.controller,
    this.focusNode,
    this.isReadOnly = false,
    this.color = Colors.white,
    this.inputFormatter,
  }) : super(key: key);

  @override
  _AnimatedTextAreaState createState() => _AnimatedTextAreaState();
}

class _AnimatedTextAreaState extends State<AnimatedTextArea> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus || _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      readOnly: widget.isReadOnly,
      inputFormatters: widget.inputFormatter,
      keyboardType: TextInputType.multiline,
      maxLines: 4, // Adjust number of visible lines
      minLines: 3, // Optional: set minimum height
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 12.0,
        ),
        filled: true,
        fillColor: widget.isReadOnly ? Colors.grey.shade300 : Colors.white,
        labelText: widget.label,
        labelStyle: TextStyle(
          color: _isFocused ? textBoardColor : Colors.grey,
          fontSize: _isFocused ? 16 : 18,
          fontWeight: _isFocused ? FontWeight.bold : FontWeight.normal,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(8),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: textBoardColor, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
