import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'dart:math';

class AddMedicinePage extends StatefulWidget {
  const AddMedicinePage({super.key});

  @override
  State<AddMedicinePage> createState() => _AddMedicinePageState();
}

class _AddMedicinePageState extends State<AddMedicinePage> {
  final _formKey = GlobalKey<FormState>();

  late String medicineId;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController expiryDateController = TextEditingController();

  final List<String> categoryOptions = [
    'Tablet',
    'Capsule',
    'Syrup',
    'Injection',
    'Ointment',
    'Other',
  ];
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    generateMedicineId();
  }

  void generateMedicineId() {
    final random = Random();
    medicineId = 'MED${1000 + random.nextInt(9999)}';
  }

  Future<void> _selectExpiryDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      expiryDateController.text = DateFormat('dd-MM-yyyy').format(pickedDate);
    }
  }

  void _saveMedicine() {
    if (_formKey.currentState!.validate()) {
      // This is where backend or Firebase code will go

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Medicine $medicineId added successfully')),
      );

      // Optionally clear the form
      nameController.clear();
      priceController.clear();
      quantityController.clear();
      expiryDateController.clear();
      selectedCategory = null;
      generateMedicineId();
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Medicine'),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Text(
                'Medicine ID: $medicineId',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),

              _buildTextField(nameController, 'Medicine Name'),
              const SizedBox(height: 12),

              _buildDropdownField(),
              const SizedBox(height: 12),

              _buildTextField(
                priceController,
                'Price (₹)',
                inputType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              _buildTextField(
                quantityController,
                'Quantity',
                inputType: TextInputType.number,
              ),
              const SizedBox(height: 12),

              GestureDetector(
                onTap: _selectExpiryDate,
                child: AbsorbPointer(
                  child: _buildTextField(
                    expiryDateController,
                    'Expiry Date (Tap to pick)',
                    inputType: TextInputType.datetime,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: _saveMedicine,
                icon: const Icon(Icons.add),
                label: const Text('Add Medicine'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType inputType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Enter $label' : null,
    );
  }

  Widget _buildDropdownField() {
    return DropdownButtonFormField<String>(
      value: selectedCategory,
      items: categoryOptions
          .map(
            (category) =>
                DropdownMenuItem(value: category, child: Text(category)),
          )
          .toList(),
      onChanged: (value) => setState(() => selectedCategory = value),
      decoration: const InputDecoration(
        labelText: 'Select Category',
        border: OutlineInputBorder(),
      ),
      validator: (value) => value == null ? 'Please select a category' : null,
    );
  }
}
