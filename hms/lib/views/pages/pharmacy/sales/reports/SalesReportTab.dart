import 'package:flutter/material.dart';

class SalesReportTab extends StatelessWidget {
  const SalesReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sales Report',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          // Example filter/search bar
          TextField(
            decoration: InputDecoration(
              labelText: 'Search by Patient or Medicine',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Example sales report list placeholder
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Replace with real data count
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long),
                    title: Text('Sale Item #${index + 1}'),
                    subtitle: const Text('Patient: John Doe'),
                    trailing: const Text('₹1500'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
