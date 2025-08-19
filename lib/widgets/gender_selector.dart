import 'package:flutter/material.dart';

class GenderSelector extends StatefulWidget {
  final String label;
  final String initialGender; // 'Male' or 'Female'
  final ValueChanged<String> onChanged;

  const GenderSelector({
    Key? key,
    this.label = 'Gender*',
    this.initialGender = 'Male',
    required this.onChanged,
  }) : super(key: key);

  @override
  _GenderSelectorState createState() => _GenderSelectorState();
}

class _GenderSelectorState extends State<GenderSelector> {
  late String _selectedGender;

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.initialGender;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Radio<String>(
              value: 'Male',
              groupValue: _selectedGender,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedGender = value);
                  widget.onChanged(value);
                }
              },
            ),
            const Text('Male'),
            const SizedBox(width: 16),
            Radio<String>(
              value: 'Female',
              groupValue: _selectedGender,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedGender = value);
                  widget.onChanged(value);
                }
              },
            ),
            const Text('Female'),
          ],
        ),
      ],
    );
  }
}
