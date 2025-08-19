import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AutoSuggestionField extends StatelessWidget {
  final TextEditingController suggestionController;
  final String fieldName;
  final String labelName;
  final String collectionName;
  final Future<List<String>> Function(String) suggestionFetcher;

  const AutoSuggestionField({
    Key? key,
    required this.suggestionController,
    required this.fieldName,
    required this.labelName,
    required this.collectionName,
    required this.suggestionFetcher,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<String>(
      builder: (context, _, focusNode) {
        return TextField(
          controller: suggestionController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: labelName,
            border: const OutlineInputBorder(),
          ),
        );
      },
      suggestionsCallback: (pattern) async {
        return await suggestionFetcher(pattern);
      },
      itemBuilder: (context, String suggestion) {
        return ListTile(title: Text(suggestion));
      },
      // When a suggestion is selected, update the external controller.
      onSelected: (String suggestion) {
        suggestionController.text = suggestion;
      },
      // Use emptyBuilder instead of noItemsFoundBuilder.
      emptyBuilder:
          (context) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('No $labelName found'),
          ),
    );
  }
}
