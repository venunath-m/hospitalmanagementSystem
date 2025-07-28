import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';

class PatientListPage extends StatelessWidget {
  const PatientListPage({Key? key}) : super(key: key);

  final List<Map<String, String>> patients = const [
    {'name': 'John Doe', 'age': '35'},
    {'name': 'Jane Smith', 'age': '29'},
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView.builder(
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];
          return ListTile(
            title: Text(patient['name']!),
            subtitle: Text("Age: ${patient['age']!}"),
            trailing: IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: () {},
            ),
          );
        },
      ),
    );
  }
}
