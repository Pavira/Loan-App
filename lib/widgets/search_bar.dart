import 'package:flutter/material.dart';

class SearchBarWithFilter extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onFilterPressed;
  final ValueChanged<String>? onChanged;
  final String hintText;
  final bool isFilterApplied;

  const SearchBarWithFilter({
    Key? key,
    required this.controller,
    required this.onFilterPressed,
    this.onChanged,
    required this.hintText,
    this.isFilterApplied = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
        prefixIcon: const Icon(Icons.search, color: Colors.grey),
        suffixIcon: Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.black),
              onPressed: onFilterPressed,
            ),
            if (isFilterApplied)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        hintText: hintText, // Dynamic hint text
        hintStyle: TextStyle(color: Colors.grey.shade600),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
