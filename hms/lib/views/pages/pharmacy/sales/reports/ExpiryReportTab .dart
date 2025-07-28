import 'package:flutter/material.dart';

class ExpiryReportTab extends StatelessWidget {
  const ExpiryReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample data - replace with your actual medicine expiry data
    final expiryItems = [
      {
        'medicine': 'Paracetamol',
        'batch': 'B123',
        'expiryDate': DateTime(2025, 9, 10),
        'quantity': 50,
      },
      {
        'medicine': 'Amoxicillin',
        'batch': 'A456',
        'expiryDate': DateTime(2025, 7, 20),
        'quantity': 30,
      },
      {
        'medicine': 'Cetirizine',
        'batch': 'C789',
        'expiryDate': DateTime(2025, 11, 5),
        'quantity': 20,
      },
      {
        'medicine': 'Ibuprofen',
        'batch': 'I101',
        'expiryDate': DateTime(2025, 7, 28),
        'quantity': 10,
      },
    ];

    final today = DateTime.now();

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expiry Report',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Search field
          TextField(
            decoration: InputDecoration(
              labelText: 'Search by Medicine or Batch',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              // TODO: Implement search/filter functionality
            },
          ),

          const SizedBox(height: 12),

          Expanded(
            child: ListView.separated(
              itemCount: expiryItems.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = expiryItems[index];
                final expiryDate = item['expiryDate'] as DateTime;
                final daysLeft = expiryDate.difference(today).inDays;
                final isNearExpiry =
                    daysLeft <= 30; // Highlight if expiry within 30 days

                return ListTile(
                  leading: Icon(
                    Icons.calendar_today,
                    color: isNearExpiry ? Colors.red : Colors.green,
                  ),
                  title: Text('${item['medicine']} (Batch: ${item['batch']})'),
                  subtitle: Text(
                    'Expiry Date: ${expiryDate.toLocal().toString().split(' ')[0]}  |  Quantity: ${item['quantity']}',
                  ),
                  trailing: isNearExpiry
                      ? Text(
                          '$daysLeft days left',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
