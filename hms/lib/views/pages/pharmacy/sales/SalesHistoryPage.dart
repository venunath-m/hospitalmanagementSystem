import 'package:flutter/material.dart';
import 'package:hms/views/pages/pharmacy/sales/SaleDetailPage.dart';

class SalesHistoryPage extends StatefulWidget {
  const SalesHistoryPage({Key? key}) : super(key: key);

  @override
  State<SalesHistoryPage> createState() => _SalesHistoryPageState();
}

class _SalesHistoryPageState extends State<SalesHistoryPage> {
  final TextEditingController searchController = TextEditingController();
  String billingTypeFilter = 'All'; // All, Inpatient, Outpatient
  DateTimeRange? selectedDateRange;

  List<Map<String, dynamic>> salesHistory = [
    {
      'patientName': 'John Doe',
      'date': DateTime(2025, 7, 25),
      'billingType': 'Outpatient',
      'totalAmount': 1500.0,
    },
    {
      'patientName': 'Jane Smith',
      'date': DateTime(2025, 7, 24),
      'billingType': 'Inpatient',
      'totalAmount': 4500.0,
    },
    // Add more demo entries or fetch from your DB
  ];

  List<Map<String, dynamic>> filteredHistory = [];

  @override
  void initState() {
    super.initState();
    filteredHistory = salesHistory;
  }

  void filterHistory() {
    final searchText = searchController.text.toLowerCase();

    setState(() {
      filteredHistory = salesHistory.where((entry) {
        final matchesName = entry['patientName'].toLowerCase().contains(
          searchText,
        );
        final matchesBillingType =
            billingTypeFilter == 'All' ||
            entry['billingType'] == billingTypeFilter;
        final matchesDate =
            selectedDateRange == null ||
            (entry['date'].isAfter(
                  selectedDateRange!.start.subtract(const Duration(days: 1)),
                ) &&
                entry['date'].isBefore(
                  selectedDateRange!.end.add(const Duration(days: 1)),
                ));

        return matchesName && matchesBillingType && matchesDate;
      }).toList();
    });
  }

  Future<void> pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: selectedDateRange,
    );

    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
      });
      filterHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales History'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search by patient name
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search by Patient Name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    filterHistory();
                  },
                ),
              ),
              onChanged: (value) => filterHistory(),
            ),

            const SizedBox(height: 12),

            // Billing Type Filter Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['All', 'Inpatient', 'Outpatient']
                  .map(
                    (type) => ChoiceChip(
                      label: Text(type),
                      selected: billingTypeFilter == type,
                      onSelected: (selected) {
                        setState(() {
                          billingTypeFilter = type;
                        });
                        filterHistory();
                      },
                      selectedColor: Colors.indigo.shade200,
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 12),

            // Date Range Picker Button
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.date_range),
                    label: Text(
                      selectedDateRange == null
                          ? 'Select Date Range'
                          : '${selectedDateRange!.start.toLocal().toString().split(' ')[0]} - ${selectedDateRange!.end.toLocal().toString().split(' ')[0]}',
                    ),
                    onPressed: pickDateRange,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                    ),
                  ),
                ),
                if (selectedDateRange != null)
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        selectedDateRange = null;
                      });
                      filterHistory();
                    },
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Sales History List
            Expanded(
              child: filteredHistory.isEmpty
                  ? const Center(child: Text('No sales records found'))
                  : ListView.separated(
                      itemCount: filteredHistory.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final entry = filteredHistory[index];
                        return ListTile(
                          leading: Icon(
                            entry['billingType'] == 'Inpatient'
                                ? Icons.local_hospital
                                : Icons.person,
                            color: Colors.indigo,
                          ),
                          title: Text(entry['patientName']),
                          subtitle: Text(
                            'Date: ${entry['date'].toLocal().toString().split(' ')[0]}',
                          ),
                          trailing: Text(
                            '₹${entry['totalAmount'].toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SaleDetailPage(
                                  patientName: entry['patientName'],
                                  patientType:
                                      entry['billingType'], // assuming outpatient/inpatient is here
                                  ward: entry['ward'], // if available
                                  bed: entry['bed'], // if available
                                  patientId: entry['patientId'], // if available
                                  billingType: entry['billingType'],
                                  insuranceType:
                                      entry['insuranceType'], // if available
                                  insuranceNumber:
                                      entry['insuranceNumber'], // if available
                                  saleDate: entry['date'],
                                  salesItems:
                                      entry['salesItems'], // this needs to be included in your data
                                  totalAmount: entry['totalAmount'],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
