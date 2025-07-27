import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy inventory data - replace with real data later
    final List<Map<String, dynamic>> inventoryItems = [
      {'item': 'Syringes', 'quantity': 120, 'unit': 'pcs'},
      {'item': 'Bandages', 'quantity': 250, 'unit': 'pcs'},
      {'item': 'Gloves', 'quantity': 500, 'unit': 'pairs'},
    ];

    return BackgroundScaffold(
      appBar: CustomAppBar(title: 'Inventory'),
      scrollable: false,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Inventory Items',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to add inventory item page
              },
              child: const Text('Add Inventory Item'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: inventoryItems.length,
                itemBuilder: (context, index) {
                  final item = inventoryItems[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.inventory_2),
                      title: Text(item['item']),
                      subtitle: Text(
                        'Quantity: ${item['quantity']} ${item['unit']}',
                      ),
                      onTap: () {
                        // TODO: Navigate to inventory item details/edit page
                      },
                    ),
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
