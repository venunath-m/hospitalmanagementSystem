import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddStockPage extends StatefulWidget {
  const AddStockPage({Key? key}) : super(key: key);

  @override
  State<AddStockPage> createState() => _AddStockPageState();
}

class _AddStockPageState extends State<AddStockPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController medicineController = TextEditingController();
  final TextEditingController batchController = TextEditingController();
  final TextEditingController quantityInController = TextEditingController();
  final TextEditingController quantityOutController = TextEditingController();
  final TextEditingController remarksController = TextEditingController();

  DateTime? expiryDate;

  void _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: expiryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        expiryDate = picked;
      });
    }
  }

  void _saveStock() {
    if (_formKey.currentState!.validate()) {
      // Process saving stock here, e.g., call API or Firestore

      // For now, just show a success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Stock saved successfully!')),
      );

      Navigator.pop(context); // Go back after saving
    }
  }

  @override
  Widget build(BuildContext context) {
    final expiryDateText = expiryDate != null
        ? DateFormat('yyyy-MM-dd').format(expiryDate!)
        : '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medicine Stock'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Medicine Name
              TextFormField(
                controller: medicineController,
                decoration: const InputDecoration(
                  labelText: 'Medicine Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter medicine name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Batch Number
              TextFormField(
                controller: batchController,
                decoration: const InputDecoration(
                  labelText: 'Batch Number',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter batch number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Expiry Date picker
              InkWell(
                onTap: _pickExpiryDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Expiry Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    expiryDateText.isEmpty
                        ? 'Select Expiry Date'
                        : expiryDateText,
                    style: TextStyle(
                      color: expiryDateText.isEmpty
                          ? Colors.grey.shade600
                          : Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Quantity In
              TextFormField(
                controller: quantityInController,
                decoration: const InputDecoration(
                  labelText: 'Quantity In',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Quantity Out (Optional)
              TextFormField(
                controller: quantityOutController,
                decoration: const InputDecoration(
                  labelText: 'Quantity Out (Optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (int.tryParse(value) == null) {
                      return 'Enter a valid number';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Remarks / Notes (Optional)
              TextFormField(
                controller: remarksController,
                decoration: const InputDecoration(
                  labelText: 'Remarks / Notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              // Save Button
              ElevatedButton(
                onPressed: _saveStock,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Stock', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
