import 'package:flutter/material.dart';

class MedicineListPage extends StatefulWidget {
  const MedicineListPage({super.key});

  @override
  State<MedicineListPage> createState() => _MedicineListPageState();
}

class _MedicineListPageState extends State<MedicineListPage> {
  final TextEditingController _searchController = TextEditingController();

  // Dummy medicine list
  List<Map<String, String>> medicines = [
    {'name': 'Paracetamol', 'type': 'Tablet', 'stock': '120', 'price': '₹5'},
    {'name': 'Amoxicillin', 'type': 'Capsule', 'stock': '90', 'price': '₹12'},
    {'name': 'Cough Syrup', 'type': 'Liquid', 'stock': '45', 'price': '₹45'},
  ];

  List<Map<String, String>> filteredList = [];

  @override
  void initState() {
    super.initState();
    filteredList = List.from(medicines);
  }

  void _searchMedicine(String query) {
    setState(() {
      filteredList = medicines
          .where(
            (med) => med['name']!.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medicine List'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              onChanged: _searchMedicine,
              decoration: InputDecoration(
                hintText: 'Search medicine...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Table/List
            Expanded(
              child: ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  final medicine = filteredList[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(medicine['name'] ?? ''),
                      subtitle: Text(
                        'Type: ${medicine['type']} | Stock: ${medicine['stock']} | Price: ${medicine['price']}',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'Edit') {
                            // Navigate to edit screen
                          } else if (value == 'View') {
                            // Navigate to view details screen
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'View',
                            child: Text('View Details'),
                          ),
                          const PopupMenuItem(
                            value: 'Edit',
                            child: Text('Edit'),
                          ),
                        ],
                      ),
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
