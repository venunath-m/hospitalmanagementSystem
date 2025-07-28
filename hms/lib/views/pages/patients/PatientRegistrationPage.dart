import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';

class PatientRegistrationPage extends StatefulWidget {
  const PatientRegistrationPage({super.key});

  @override
  State<PatientRegistrationPage> createState() =>
      _PatientRegistrationPageState();
}

class _PatientRegistrationPageState extends State<PatientRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _genderController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isSubmitting = false;

  void _registerPatient() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);

      // Simulate async operation
      Future.delayed(const Duration(seconds: 2), () {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Patient registered successfully!')),
        );
        _formKey.currentState?.reset();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              FlexibleInputField(
                fieldType: FieldType.text,
                controller: _nameController,
                label: 'Full Name',
                isRequired: true,
              ),
              const SizedBox(height: 12),
              FlexibleInputField(
                fieldType: FieldType.number,
                controller: _ageController,
                label: 'Age',
                isRequired: true,
              ),
              const SizedBox(height: 12),
              FlexibleInputField(
                fieldType: FieldType.text,
                controller: _genderController,
                label: 'Gender',
                isRequired: true,
              ),
              const SizedBox(height: 12),
              FlexibleInputField(
                fieldType: FieldType.phone,
                controller: _phoneController,
                label: 'Phone Number',
                isRequired: true,
              ),
              const SizedBox(height: 12),
              FlexibleInputField(
                fieldType: FieldType.multiline,
                controller: _addressController,
                label: 'Address',
                isRequired: true,
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: CustomButton(
                  label: 'Register',
                  onPressed: _isSubmitting ? () {} : _registerPatient,
                  isLoading: _isSubmitting,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
