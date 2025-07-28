import 'package:flutter/material.dart';

class EditMedicinePage extends StatefulWidget {
  final Map<String, dynamic> medicine;

  const EditMedicinePage({super.key, required this.medicine});

  @override
  State<EditMedicinePage> createState() => _EditMedicinePageState();
}

class _EditMedicinePageState extends State<EditMedicinePage> {
  late TextEditingController nameController;
  late TextEditingController categoryController;
  late TextEditingController quantityController;
  late TextEditingController priceController;
  late TextEditingController expiryDateController;
  late TextEditingController manufacturerController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.medicine['name']);
    categoryController = TextEditingController(
      text: widget.medicine['category'],
    );
    quantityController = TextEditingController(
      text: "${widget.medicine['quantity']}",
    );
    priceController = TextEditingController(
      text: "${widget.medicine['price']}",
    );
    expiryDateController = TextEditingController(
      text: widget.medicine['expiryDate'],
    );
    manufacturerController = TextEditingController(
      text: widget.medicine['manufacturer'],
    );
    descriptionController = TextEditingController(
      text: widget.medicine['description'],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    quantityController.dispose();
    priceController.dispose();
    expiryDateController.dispose();
    manufacturerController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void saveChanges() {
    // Implement backend call or state update here
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Medicine updated successfully')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Medicine"),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Medicine Name'),
            ),
            TextField(
              controller: categoryController,
              decoration: const InputDecoration(labelText: 'Category'),
            ),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Quantity'),
            ),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price'),
            ),
            TextField(
              controller: expiryDateController,
              decoration: const InputDecoration(labelText: 'Expiry Date'),
            ),
            TextField(
              controller: manufacturerController,
              decoration: const InputDecoration(labelText: 'Manufacturer'),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: saveChanges,
              icon: const Icon(Icons.save),
              label: const Text("Save Changes"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            ),
          ],
        ),
      ),
    );
  }
}
