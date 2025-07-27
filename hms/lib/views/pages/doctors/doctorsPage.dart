import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';

class DoctorsPage extends StatelessWidget {
  const DoctorsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy doctor data - replace with your real data source later
    final List<Map<String, String>> doctors = [
      {'name': 'Dr. John Smith', 'specialization': 'Cardiology'},
      {'name': 'Dr. Alice Brown', 'specialization': 'Neurology'},
      {'name': 'Dr. Michael Johnson', 'specialization': 'Orthopedics'},
    ];

    return BackgroundScaffold(
      appBar: CustomAppBar(title: 'Doctors'),
      scrollable: false,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Our Doctors', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to add new doctor form page
              },
              child: const Text('Add New Doctor'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  final doctor = doctors[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.local_hospital),
                      title: Text(doctor['name']!),
                      subtitle: Text(doctor['specialization']!),
                      onTap: () {
                        // TODO: Navigate to doctor detail or edit page
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
