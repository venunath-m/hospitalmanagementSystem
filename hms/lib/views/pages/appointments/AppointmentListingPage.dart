import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';
import 'package:intl/intl.dart';

class AppointmentListingPage extends StatefulWidget {
  const AppointmentListingPage({super.key});

  @override
  State<AppointmentListingPage> createState() => _AppointmentListingPageState();
}

class _AppointmentListingPageState extends State<AppointmentListingPage> {
  DateTimeRange? selectedRange;

  // Dummy data for appointments (replace with your actual data source)
  final List<Map<String, dynamic>> allAppointments = List.generate(
    30,
    (index) => {
      'name': 'Patient $index',
      'phone': '987654321$index',
      'doctor': ['Dr. A Kumar', 'Dr. S Mehta', 'Dr. N Reddy'][index % 3],
      'date': DateTime.now().subtract(Duration(days: index * 2)),
    },
  );

  // Pagination variables
  int currentPage = 0;
  final int rowsPerPage = 5;

  List<Map<String, dynamic>> get filteredAppointments {
    if (selectedRange == null) return allAppointments;

    return allAppointments.where((appointment) {
      final date = appointment['date'] as DateTime;
      return date.isAfter(
            selectedRange!.start.subtract(const Duration(days: 1)),
          ) &&
          date.isBefore(selectedRange!.end.add(const Duration(days: 1)));
    }).toList();
  }

  int get totalPages => (filteredAppointments.length / rowsPerPage).ceil();

  List<Map<String, dynamic>> get paginatedAppointments {
    final start = currentPage * rowsPerPage;
    return filteredAppointments.skip(start).take(rowsPerPage).toList();
  }

  void nextPage() {
    if (currentPage < totalPages - 1) {
      setState(() {
        currentPage++;
      });
    }
  }

  void previousPage() {
    if (currentPage > 0) {
      setState(() {
        currentPage--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Card(
        elevation: 4,
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 500, // You can adjust height as needed
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CustomDateRangeButton(
                  selectedRange: selectedRange,
                  onChanged: (range) {
                    setState(() {
                      selectedRange = range;
                      currentPage = 0; // reset page on filter change
                    });
                  },
                  label: "Select Date Range",
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                ),
                if (selectedRange != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      "Showing bookings from ${DateFormat.yMMMd().format(selectedRange!.start)} to ${DateFormat.yMMMd().format(selectedRange!.end)}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                const SizedBox(height: 12),
                Expanded(
                  child: CustomPaginatedTable(
                    columns: const [
                      DataColumn(label: Text('Patient Name')),
                      DataColumn(label: Text('Phone')),
                      DataColumn(label: Text('Doctor')),
                      DataColumn(label: Text('Date')),
                    ],
                    rows: paginatedAppointments.map((appointment) {
                      return DataRow(
                        cells: [
                          DataCell(Text(appointment['name'])),
                          DataCell(Text(appointment['phone'])),
                          DataCell(Text(appointment['doctor'])),
                          DataCell(
                            Text(
                              DateFormat.yMMMd().format(appointment['date']),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                    currentPage: currentPage,
                    totalPages: totalPages,
                    onNextPage: nextPage,
                    onPreviousPage: previousPage,
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
