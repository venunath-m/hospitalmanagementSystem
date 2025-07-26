import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDateRangeButton extends StatelessWidget {
  final DateTimeRange? selectedRange;
  final ValueChanged<DateTimeRange> onChanged;
  final String label;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const CustomDateRangeButton({
    Key? key,
    required this.selectedRange,
    required this.onChanged,
    this.label = "Pick Date Range",
    this.firstDate,
    this.lastDate,
  }) : super(key: key);

  Future<void> _pickDateRange(BuildContext context) async {
    final picked = await showDateRangePicker(
      context: context,
      initialDateRange: selectedRange,
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime(2100),
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayText = selectedRange != null
        ? "${DateFormat.yMMMd().format(selectedRange!.start)} - ${DateFormat.yMMMd().format(selectedRange!.end)}"
        : label;

    return ElevatedButton.icon(
      onPressed: () => _pickDateRange(context),
      icon: const Icon(Icons.date_range),
      label: Text(displayText),
    );
  }
}
