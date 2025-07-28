import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';

class DischargesPage extends StatelessWidget {
  const DischargesPage({Key? key}) : super(key: key);

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
              title: const Text("Patient: Jane Smith"),
              subtitle: const Text("Discharged on: 26 July 2  025"),
            ),
          ),
        ],
      ),
    );
  }
}
