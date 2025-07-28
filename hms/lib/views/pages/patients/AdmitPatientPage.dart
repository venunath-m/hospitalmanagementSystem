import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';

class AdmitPatientPage extends StatefulWidget {
  const AdmitPatientPage({super.key});

  @override
  State<AdmitPatientPage> createState() => _AdmitPatientPageState();
}

class _AdmitPatientPageState extends State<AdmitPatientPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _patientNameController = TextEditingController();
  DateTime? _admitDate = DateTime.now();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Save logic here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Patient admitted successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Admit New Patient",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _patientNameController,
                decoration: const InputDecoration(labelText: "Patient Name"),
                validator: (value) =>
                    value!.isEmpty ? "Please enter patient name" : null,
              ),
              const SizedBox(height: 16),
              Text(
                "Admit Date: ${_admitDate!.toLocal().toString().split(' ')[0]}",
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () async {
                  final selected = await showDatePicker(
                    context: context,
                    initialDate: _admitDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (selected != null) {
                    setState(() {
                      _admitDate = selected;
                    });
                  }
                },
                child: const Text("Select Date"),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text("Admit"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
