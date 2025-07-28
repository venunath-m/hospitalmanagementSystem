import 'package:flutter/material.dart';
import 'package:hms/views/pages/pharmacy/DashboardAction.dart';
import 'package:hms/views/pages/pharmacy/DashboardCard.dart';

class PharmacyDashboardPage extends StatelessWidget {
  const PharmacyDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacy Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.indigo,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Summary Cards
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                DashboardCard(
                  title: 'Total Medicines',
                  icon: Icons.medication,
                  value: '218',
                ),
                DashboardCard(
                  title: 'Low Stock',
                  icon: Icons.warning,
                  value: '9',
                ),
                DashboardCard(
                  title: 'Today\'s Purchases',
                  icon: Icons.shopping_cart,
                  value: '₹3,200',
                ),
                DashboardCard(
                  title: 'Today\'s Sales',
                  icon: Icons.attach_money,
                  value: '₹7,450',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Action Buttons Grid
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                DashboardAction(
                  title: 'Add Medicine',
                  icon: Icons.add,
                  onTap: () {},
                ),
                DashboardAction(
                  title: 'View Medicines',
                  icon: Icons.list,
                  onTap: () {},
                ),
                DashboardAction(
                  title: 'Sales Billing',
                  icon: Icons.receipt,
                  onTap: () {},
                ),
                DashboardAction(
                  title: 'Purchase Entry',
                  icon: Icons.inventory,
                  onTap: () {},
                ),
                DashboardAction(
                  title: 'Customers',
                  icon: Icons.people,
                  onTap: () {},
                ),
                DashboardAction(
                  title: 'Reports',
                  icon: Icons.bar_chart,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable Summary Card

// Reusable Action Button
