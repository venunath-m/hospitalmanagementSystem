import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';

class PharmacyPage extends StatelessWidget {
  const PharmacyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy pharmacy inventory data - replace with real data later
    final List<Map<String, dynamic>> medicines = [
      {'name': 'Paracetamol', 'stock': 150, 'unit': 'tablets'},
      {'name': 'Amoxicillin', 'stock': 80, 'unit': 'capsules'},
      {'name': 'Ibuprofen', 'stock': 120, 'unit': 'tablets'},
    ];

    return BackgroundScaffold(
      appBar: CustomAppBar(title: 'Pharmacy'),
      scrollable: false,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Medicine Inventory',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to add new medicine page
              },
              child: const Text('Add New Medicine'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: medicines.length,
                itemBuilder: (context, index) {
                  final medicine = medicines[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.medical_services),
                      title: Text(medicine['name']),
                      subtitle: Text(
                        'Stock: ${medicine['stock']} ${medicine['unit']}',
                      ),
                      onTap: () {
                        // TODO: Navigate to medicine details/edit page
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
