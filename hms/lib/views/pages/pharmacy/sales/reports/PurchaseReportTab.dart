import 'package:flutter/material.dart';

class PurchaseReportTab extends StatelessWidget {
  const PurchaseReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Purchase Report',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Search or filter by supplier or medicine
          TextField(
            decoration: InputDecoration(
              labelText: 'Search by Supplier or Medicine',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Example Date Range filter button (can be enhanced)
          ElevatedButton.icon(
            onPressed: () {
              // TODO: implement date range picker
            },
            icon: const Icon(Icons.date_range),
            label: const Text('Filter by Date Range'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),

          const SizedBox(height: 12),

          // Purchase records list placeholder
          Expanded(
            child: ListView.builder(
              itemCount: 10, // replace with your actual data length
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: ListTile(
                    leading: const Icon(Icons.local_shipping),
                    title: Text('Purchase #${index + 1}'),
                    subtitle: const Text('Supplier: ABC Pharma'),
                    trailing: const Text('₹12,000'),
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
