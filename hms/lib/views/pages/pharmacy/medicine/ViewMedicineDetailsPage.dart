import 'package:flutter/material.dart';
import 'package:hms/views/pages/pharmacy/medicine/DetailTile.dart';
import 'package:hms/views/pages/pharmacy/medicine/EditMedicinePage.dart';

class ViewMedicineDetailsPage extends StatelessWidget {
  final Map<String, dynamic> medicine;

  const ViewMedicineDetailsPage({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Medicine Details"),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DetailTile(title: "Name", value: medicine['name']),
            DetailTile(title: "Category", value: medicine['category']),
            DetailTile(title: "Quantity", value: "${medicine['quantity']}"),
            DetailTile(title: "Price", value: "₹${medicine['price']}"),
            DetailTile(title: "Expiry Date", value: medicine['expiryDate']),
            DetailTile(title: "Manufacturer", value: medicine['manufacturer']),
            DetailTile(title: "Description", value: medicine['description']),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditMedicinePage(medicine: medicine),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text("Edit"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            ),
          ],
        ),
      ),
    );
  }
}
