import 'package:flutter/material.dart';

class DailyBillingTab extends StatelessWidget {
  const DailyBillingTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample daily billing data - replace with your actual data
    final dailyBillings = [
      {'date': DateTime(2025, 7, 27), 'totalBills': 45, 'totalAmount': 12500.0},
      {'date': DateTime(2025, 7, 26), 'totalBills': 38, 'totalAmount': 11000.0},
      {'date': DateTime(2025, 7, 25), 'totalBills': 50, 'totalAmount': 14000.0},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Billing Summary',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          Expanded(
            child: ListView.separated(
              itemCount: dailyBillings.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = dailyBillings[index];
                final date = item['date'] as DateTime;

                return ListTile(
                  leading: const Icon(Icons.receipt_long, color: Colors.indigo),
                  title: Text('${date.toLocal().toString().split(' ')[0]}'),
                  subtitle: Text('Total Bills: ${item['totalBills']}'),
                  trailing: Text(
                    '₹${(item['totalAmount'] as double).toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
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
