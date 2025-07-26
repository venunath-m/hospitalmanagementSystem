import 'package:flutter/material.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:collection/collection.dart';

class FlexibleDropdown<T> extends StatefulWidget {
  final List<T> items;
  final String? selectedId;
  final String label;
  final String? hintText;
  final String Function(T) idSelector;
  final String Function(T) displaySelector;
  final ValueChanged<String?> onChanged;

  const FlexibleDropdown({
    Key? key,
    required this.items,
    required this.selectedId,
    required this.label,
    required this.idSelector,
    required this.displaySelector,
    required this.onChanged,
    this.hintText,
  }) : super(key: key);

  @override
  State<FlexibleDropdown<T>> createState() => _FlexibleDropdownState<T>();
}

class _FlexibleDropdownState<T> extends State<FlexibleDropdown<T>> {
  T? _selectedItem;
  String? _manualEntry;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.items.firstWhereOrNull(
      (item) => widget.idSelector(item) == widget.selectedId,
    );
    _manualEntry = _selectedItem == null ? widget.selectedId : null;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownSearch<T>(
      items: widget.items,
      selectedItem: _selectedItem,
      itemAsString: (item) => widget.displaySelector(item),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: widget.label,
          hintText: widget.hintText,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        ),
      ),
      popupProps: PopupProps.menu(
        showSearchBox: true,
        showSelectedItems: true,
        searchFieldProps: TextFieldProps(
          controller: _manualEntry != null
              ? TextEditingController(text: _manualEntry)
              : null,
          decoration: const InputDecoration(
            hintText: 'Search or type...',
            contentPadding: EdgeInsets.symmetric(horizontal: 12),
          ),
          // Removed onChanged: not supported in TextFieldProps
        ),
      ),
      clearButtonProps: ClearButtonProps(isVisible: true),
      onChanged: (selected) {
        setState(() {
          _selectedItem = selected;
          _manualEntry = null;
        });
        widget.onChanged(selected == null ? null : widget.idSelector(selected));
      },
    );
  }
}
