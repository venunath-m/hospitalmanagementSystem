import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';

class MedicalRecordsPage extends StatelessWidget {
  const MedicalRecordsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text("Blood Test Report"),
              subtitle: const Text("Date: 25 July 2025"),
              trailing: const Icon(Icons.visibility),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
