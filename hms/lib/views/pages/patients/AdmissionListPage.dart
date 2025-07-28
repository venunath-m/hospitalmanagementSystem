import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';

class AdmissionListPage extends StatefulWidget {
  const AdmissionListPage({super.key});

  @override
  State<AdmissionListPage> createState() => _AdmissionListPageState();
}

class _AdmissionListPageState extends State<AdmissionListPage> {
  DateTimeRange? _dateRange;

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
            ElevatedButton(
              onPressed: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (range != null) {
                  setState(() {
                    _dateRange = range;
                  });
                }
              },
              child: const Text("Select Date Range"),
            ),
            const SizedBox(height: 16),
            if (_dateRange != null)
              Text(
                "Showing admissions from ${_dateRange!.start.toLocal().toString().split(' ')[0]} to ${_dateRange!.end.toLocal().toString().split(' ')[0]}",
              ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                color: Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: const [
                    ListTile(
                      title: Text("Patient: John Doe"),
                      subtitle: Text("Admitted on: 25 July 2025"),
                    ),
                    Divider(),
                    ListTile(
                      title: Text("Patient: Jane Smith"),
                      subtitle: Text("Admitted on: 22 July 2025"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
