import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';

class VitalsPage extends StatelessWidget {
  const VitalsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Patient: John Doe", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            _buildVitalRow("Blood Pressure", "120/80 mmHg"),
            _buildVitalRow("Heart Rate", "72 bpm"),
            _buildVitalRow("Temperature", "98.6°F"),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(label), Text(value)],
      ),
    );
  }
}
