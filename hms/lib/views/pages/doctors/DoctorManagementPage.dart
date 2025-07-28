import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';
import 'package:hms/custom_component_widgets/shared_widgets/background_scaffold.dart';

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
    return BackgroundScaffold(
      appBar: CustomAppBar(
        title: "Doctor Management",
        centerTitle: true,
        backgroundColor: Colors.red.shade800,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Doctor Name
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Doctor Name',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) => doctorName = val,
                  ),
                  const SizedBox(height: 20),

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
                      setState(() {
                        selectedDepartment = val;
                        autoAssignRoom(val);
                      });
                    },
                  ),
                  const SizedBox(height: 20),

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
                  const SizedBox(height: 20),

                  // File Upload - Photo
                  ElevatedButton.icon(
                    onPressed: _pickDoctorPhoto,
                    icon: const Icon(Icons.image),
                    label: Text(
                      doctorPhoto == null
                          ? 'Upload Doctor Photo'
                          : doctorPhoto!.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // File Upload - Certificates
                  ElevatedButton.icon(
                    onPressed: _pickCertificates,
                    icon: const Icon(Icons.upload_file),
                    label: Text(
                      doctorCertificates.isEmpty
                          ? 'Upload Certificates'
                          : '${doctorCertificates.length} file(s) selected',
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Consultation Date Range
                  ElevatedButton.icon(
                    onPressed: () => _pickConsultationDates(context),
                    icon: const Icon(Icons.calendar_month),
                    label: const Text('Select Consultation Dates'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (consultationStartDate != null &&
                      consultationEndDate != null)
                    Text(
                      'From: ${consultationStartDate!.toLocal().toString().split(' ')[0]} '
                      'To: ${consultationEndDate!.toLocal().toString().split(' ')[0]}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  const SizedBox(height: 30),

                  // Submit Button
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Submit logic here
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text("Save Doctor Details"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      textStyle: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
