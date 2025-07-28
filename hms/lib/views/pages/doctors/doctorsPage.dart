import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';
import 'package:hms/views/pages/doctors/DoctorManagementPage.dart';

class DoctorsPage extends StatefulWidget {
  const DoctorsPage({Key? key}) : super(key: key);

  @override
  State<DoctorsPage> createState() => _DoctorsPageState();
}

class _DoctorsPageState extends State<DoctorsPage> {
  final int rowsPerPage = 5;
  int currentPage = 0;

  final List<Map<String, String>> _doctors = [
    {'name': 'Dr. John Smith', 'specialization': 'Cardiology'},
    {'name': 'Dr. Alice Brown', 'specialization': 'Neurology'},
    {'name': 'Dr. Michael Johnson', 'specialization': 'Orthopedics'},
    {'name': 'Dr. Emma Wilson', 'specialization': 'Dermatology'},
    {'name': 'Dr. Olivia Davis', 'specialization': 'Pediatrics'},
    {'name': 'Dr. William Lee', 'specialization': 'Radiology'},
    {'name': 'Dr. James Taylor', 'specialization': 'Gastroenterology'},
    {'name': 'Dr. Sophia Martin', 'specialization': 'Oncology'},
  ];

  List<DataRow> _getRows() {
    final start = currentPage * rowsPerPage;
    final end = (start + rowsPerPage).clamp(0, _doctors.length);
    final pageItems = _doctors.sublist(start, end);

    return pageItems.map((doctor) {
      return DataRow(
        cells: [
          DataCell(Text(doctor['name']!)),
          DataCell(Text(doctor['specialization']!)),
          DataCell(
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.indigo),
              onPressed: () {
                // TODO: Navigate to doctor detail or edit
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        MainLayout(child: DoctorManagementPage()),
                  ),
                );
              },
            ),
          ),
        ],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (_doctors.length / rowsPerPage).ceil();

    return BackgroundScaffold(
      appBar: CustomAppBar(
        title: 'Doctors',
        centerTitle: true,
        backgroundColor: Colors.red.shade800,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SizedBox(
            height: 400, // Fixed height for the card
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MainLayout(child: DoctorManagementPage()),
                        ),
                      );
                    },
                    child: const Text('Add New Doctor'),
                  ),
                ),
                const SizedBox(height: 20),
                Flexible(
                  // <-- Wrap here
                  child: CustomPaginatedTable(
                    columns: const [
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Specialization')),
                      DataColumn(label: Text('Actions')),
                    ],
                    rows: _getRows(),
                    currentPage: currentPage,
                    totalPages: totalPages,
                    onPreviousPage: () {
                      setState(() {
                        if (currentPage > 0) currentPage--;
                      });
                    },
                    onNextPage: () {
                      setState(() {
                        if (currentPage < totalPages - 1) currentPage++;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
