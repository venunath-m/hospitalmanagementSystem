import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';

class PatientsPage extends StatelessWidget {
  const PatientsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy patient data - replace with real data later
    final List<Map<String, String>> patients = [
      {'name': 'John Doe', 'id': 'P001', 'phone': '123-456-7890'},
      {'name': 'Jane Smith', 'id': 'P002', 'phone': '987-654-3210'},
      {'name': 'Alice Johnson', 'id': 'P003', 'phone': '555-123-4567'},
    ];

    return BackgroundScaffold(
      appBar: CustomAppBar(title: 'Patients'),
      scrollable: false,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'List of registered patients',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to patient registration form page
              },
              child: const Text('Register New Patient'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: patients.length,
                itemBuilder: (context, index) {
                  final patient = patients[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(patient['name']!),
                      subtitle: Text(
                        'ID: ${patient['id']} - Phone: ${patient['phone']}',
                      ),
                      onTap: () {
                        // TODO: Navigate to patient details or edit page
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
