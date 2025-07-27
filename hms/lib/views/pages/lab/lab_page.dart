import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';

class LabPage extends StatelessWidget {
  const LabPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy lab tests data - replace with real data later
    final List<Map<String, String>> labTests = [
      {'testName': 'Blood Test', 'status': 'Completed'},
      {'testName': 'X-Ray', 'status': 'Pending'},
      {'testName': 'MRI Scan', 'status': 'In Progress'},
    ];

    return BackgroundScaffold(
      appBar: CustomAppBar(title: 'Lab Tests'),
      scrollable: false,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Lab Test Results',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to sample collection or test booking page
              },
              child: const Text('Add New Test'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: labTests.length,
                itemBuilder: (context, index) {
                  final test = labTests[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.biotech),
                      title: Text(test['testName']!),
                      trailing: Text(
                        test['status']!,
                        style: TextStyle(
                          color: test['status'] == 'Completed'
                              ? Colors.green
                              : (test['status'] == 'Pending'
                                    ? Colors.orange
                                    : Colors.blue),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onTap: () {
                        // TODO: Show test details or edit page
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
