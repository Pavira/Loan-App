import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:loan_app/core/theme/app_theme.dart';

class DropdownSearchWidget<T> extends StatelessWidget {
  final String label;
  final double? labelFontSize;
  final T? selectedItem;
  final Future<List<T>> Function(String) asyncItemsFetcher;
  final String Function(T)? itemAsString;
  final void Function(T?)? onChanged;
  final isReadOnly;

  const DropdownSearchWidget({
    Key? key,
    required this.label,
    this.labelFontSize,
    required this.selectedItem,
    required this.asyncItemsFetcher,
    this.itemAsString,
    this.onChanged,
    this.isReadOnly = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<T>(
      enabled: isReadOnly,
      selectedItem: selectedItem,
      asyncItems: asyncItemsFetcher,
      itemAsString: itemAsString,
      onChanged: onChanged,
      popupProps: PopupProps.menu(
        showSearchBox: true,
        searchFieldProps: TextFieldProps(
          decoration: InputDecoration(
            hintText: "Search...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: label,
          hintText: "Select $label",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: 12,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: textBoardColor, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
