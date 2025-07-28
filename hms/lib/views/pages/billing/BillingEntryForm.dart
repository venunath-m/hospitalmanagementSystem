import 'package:flutter/material.dart';
import 'package:hms/dbservices/BillingItemModel.dart';

class BillingEntryForm extends StatefulWidget {
  final List<String> services;
  final void Function(BillingItem) onAdd;

  BillingEntryForm({required this.services, required this.onAdd});

  @override
  _BillingEntryFormState createState() => _BillingEntryFormState();
}

class _BillingEntryFormState extends State<BillingEntryForm> {
  String? selectedCategory;
  final descriptionController = TextEditingController();
  final qtyController = TextEditingController();
  final priceController = TextEditingController();

  @override
  void dispose() {
    descriptionController.dispose();
    qtyController.dispose();
    priceController.dispose();
    super.dispose();
  }

  void submit() {
    if (selectedCategory != null &&
        descriptionController.text.isNotEmpty &&
        qtyController.text.isNotEmpty &&
        priceController.text.isNotEmpty) {
      widget.onAdd(
        BillingItem(
          category: selectedCategory!,
          description: descriptionController.text,
          quantity: double.tryParse(qtyController.text) ?? 1,
          unitPrice: double.tryParse(priceController.text) ?? 0,
        ),
      );
      descriptionController.clear();
      qtyController.clear();
      priceController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'Category'),
            items: widget.services
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: (val) => setState(() => selectedCategory = val),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: TextField(
            controller: descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: qtyController,
            decoration: InputDecoration(labelText: 'Qty'),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: priceController,
            decoration: InputDecoration(labelText: 'Unit Price'),
            keyboardType: TextInputType.number,
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(onPressed: submit, child: Icon(Icons.add)),
      ],
    );
  }
}
