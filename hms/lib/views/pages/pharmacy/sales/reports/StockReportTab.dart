import 'package:flutter/material.dart';

class StockReportTab extends StatelessWidget {
  const StockReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample stock data, replace with your actual data
    final stockItems = [
      {'medicine': 'Paracetamol', 'stock': 120, 'reorderLevel': 50},
      {'medicine': 'Amoxicillin', 'stock': 30, 'reorderLevel': 40},
      {'medicine': 'Cetirizine', 'stock': 75, 'reorderLevel': 20},
      {'medicine': 'Ibuprofen', 'stock': 15, 'reorderLevel': 30},
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stock Report',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Search box for medicine name
          TextField(
            decoration: InputDecoration(
              labelText: 'Search by Medicine Name',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onChanged: (value) {
              // TODO: Implement search/filter logic
            },
          ),

          const SizedBox(height: 12),

          Expanded(
            child: ListView.separated(
              itemCount: stockItems.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = stockItems[index];
                final stock = item['stock'] as int;
                final reorderLevel = item['reorderLevel'] as int;
                final isLowStock = stock <= reorderLevel;

                return ListTile(
                  leading: Icon(
                    Icons.medical_services,
                    color: isLowStock ? Colors.red : Colors.green,
                  ),
                  title: Text(item['medicine'].toString()),
                  subtitle: Text(
                    'Stock: $stock  |  Reorder Level: $reorderLevel',
                  ),
                  trailing: isLowStock
                      ? const Text(
                          'Low Stock',
                          style: TextStyle(
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
