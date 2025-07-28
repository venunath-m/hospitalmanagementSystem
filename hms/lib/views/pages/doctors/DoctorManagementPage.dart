import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class DoctorManagementPage extends StatefulWidget {
  const DoctorManagementPage({super.key});

  @override
  State<DoctorManagementPage> createState() => _DoctorManagementPageState();
}

class _DoctorManagementPageState extends State<DoctorManagementPage> {
  final _formKey = GlobalKey<FormState>();

  String? doctorName;
  String? selectedDepartment;
  String? selectedRoom;
  DateTime? consultationStartDate;
  DateTime? consultationEndDate;

  List<String> departmentsFromDB = [
    'Cardiology',
    'Neurology',
    'Orthopedics',
    'Pediatrics',
  ];
  Map<String, List<String>> departmentRooms = {
    'Cardiology': ['101', '102'],
    'Neurology': ['201', '202'],
    'Orthopedics': ['301', '302'],
    'Pediatrics': ['401', '402'],
  };

  List<String> doctorCertificates = [];
  PlatformFile? doctorPhoto;

  Future<void> _pickDoctorPhoto() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      setState(() {
        doctorPhoto = result.files.first;
      });
    }
  }

  Future<void> _pickCertificates() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        doctorCertificates = result.paths.whereType<String>().toList();
      });
    }
  }

  Future<void> _pickConsultationDates(BuildContext context) async {
    final start = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: DateTime.now(),
    );
    if (start != null) {
      final end = await showDatePicker(
        context: context,
        firstDate: start,
        lastDate: DateTime.now().add(const Duration(days: 365)),
        initialDate: start,
      );
      setState(() {
        consultationStartDate = start;
        consultationEndDate = end;
      });
    }
  }

  void autoAssignRoom(String? department) {
    if (department != null && departmentRooms[department]!.isNotEmpty) {
      setState(() {
        selectedRoom = departmentRooms[department]!.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Doctor Management")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Doctor Name
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Doctor Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (val) => doctorName = val,
              ),
              const SizedBox(height: 16),

              // Department
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Select Department',
                  border: OutlineInputBorder(),
                ),
                value: selectedDepartment,
                items: departmentsFromDB
                    .map(
                      (dept) =>
                          DropdownMenuItem(value: dept, child: Text(dept)),
                    )
                    .toList(),
                onChanged: (val) {
                  selectedDepartment = val;
                  autoAssignRoom(val);
                },
              ),
              const SizedBox(height: 16),

              // Room (auto-assigned)
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Room Number',
                  border: OutlineInputBorder(),
                ),
                value: selectedRoom,
                items: selectedDepartment == null
                    ? []
                    : departmentRooms[selectedDepartment]!
                          .map(
                            (room) => DropdownMenuItem(
                              value: room,
                              child: Text(room),
                            ),
                          )
                          .toList(),
                onChanged: (val) => setState(() => selectedRoom = val),
              ),
              const SizedBox(height: 16),

              // File Upload - Photo
              ElevatedButton.icon(
                onPressed: _pickDoctorPhoto,
                icon: const Icon(Icons.image),
                label: Text(
                  doctorPhoto == null
                      ? 'Upload Doctor Photo'
                      : doctorPhoto!.name,
                ),
              ),
              const SizedBox(height: 12),

              // File Upload - Certificates
              ElevatedButton.icon(
                onPressed: _pickCertificates,
                icon: const Icon(Icons.upload_file),
                label: Text(
                  doctorCertificates.isEmpty
                      ? 'Upload Certificates'
                      : '${doctorCertificates.length} files selected',
                ),
              ),
              const SizedBox(height: 16),

              // Consultation Date Range
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pickConsultationDates(context),
                      icon: const Icon(Icons.calendar_month),
                      label: const Text('Select Consultation Dates'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (consultationStartDate != null && consultationEndDate != null)
                Text(
                  'From: ${consultationStartDate!.toLocal().toString().split(' ')[0]} '
                  'To: ${consultationEndDate!.toLocal().toString().split(' ')[0]}',
                ),
              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Submit logic here
                  }
                },
                icon: const Icon(Icons.save),
                label: const Text("Save Doctor Details"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
