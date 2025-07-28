import 'package:flutter/material.dart';

class SearchableFlexibleInputField extends StatefulWidget {
  final String label;
  final String? hintText;
  final bool isRequired;
  final Future<List<Map<String, dynamic>>> Function(String query)
  searchCallback;
  final void Function(Map<String, dynamic>) onItemSelected;
  final Future<Map<String, dynamic>> Function(String input)? onManualEntry;
  final TextEditingController controller;

  const SearchableFlexibleInputField({
    Key? key,
    required this.label,
    required this.searchCallback,
    required this.onItemSelected,
    required this.controller,
    this.hintText,
    this.onManualEntry,
    this.isRequired = false,
  }) : super(key: key);

  @override
  State<SearchableFlexibleInputField> createState() =>
      _SearchableFlexibleInputFieldState();
}

class _SearchableFlexibleInputFieldState
    extends State<SearchableFlexibleInputField> {
  final FocusNode _focusNode = FocusNode();
  List<Map<String, dynamic>> _suggestions = [];
  bool _showDropdown = false;

  void _onChanged(String input) async {
    if (input.isEmpty) {
      setState(() {
        _suggestions = [];
        _showDropdown = false;
      });
      return;
    }

    final results = await widget.searchCallback(input);
    setState(() {
      _suggestions = results;
      _showDropdown = true;
    });
  }

  void _onSuggestionTap(Map<String, dynamic> item) {
    widget.controller.text = item['name'] ?? '';
    widget.onItemSelected(item);
    setState(() {
      _showDropdown = false;
    });
  }

  void _onSubmitted(String value) async {
    if (widget.onManualEntry != null) {
      final manualItem = await widget.onManualEntry!(value);
      widget.onItemSelected(manualItem);
    }
    setState(() {
      _showDropdown = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hintText,
            border: const OutlineInputBorder(),
          ),
          onChanged: _onChanged,
          onFieldSubmitted: _onSubmitted,
          validator: (value) {
            if (widget.isRequired && (value == null || value.trim().isEmpty)) {
              return 'This field is required';
            }
            return null;
          },
        ),
        if (_showDropdown && _suggestions.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(8),
              ),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final item = _suggestions[index];
                return ListTile(
                  title: Text(item['name'] ?? ''),
                  onTap: () => _onSuggestionTap(item),
                );
              },
            ),
          ),
      ],
    );
  }
}
