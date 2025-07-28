import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';
import 'package:hms/views/pages/pharmacy/DashboardAction.dart';
import 'package:hms/views/pages/pharmacy/DashboardCard.dart';
import 'package:hms/views/pages/pharmacy/customer/PharmacyCustomerFormPage.dart';
import 'package:hms/views/pages/pharmacy/customer/PharmacyCustomerListPage.dart';
import 'package:hms/views/pages/pharmacy/medicine/AddMedicinePage.dart';
import 'package:hms/views/pages/pharmacy/medicine/MedicineListPage.dart';
import 'package:hms/views/pages/pharmacy/purchase/pharmacyPurchaseEntryPage.dart';
import 'package:hms/views/pages/pharmacy/sales/DashboardItem.dart';
import 'package:hms/views/pages/pharmacy/sales/pharmacySalesBillingPage.dart';
import 'package:hms/views/pages/pharmacy/sales/reports/PharmacyReportsDashboard.dart';
import 'package:hms/views/pages/pharmacy/settings/PharmacySettingsPage.dart';

class PharmacyDashboardPage extends StatelessWidget {
  const PharmacyDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<DashboardItem> dashboardItems = [
      DashboardItem(
        title: 'Add Medicine',
        icon: Icons.add,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddMedicinePage()),
          );
        },
      ),
      DashboardItem(
        title: 'View Medicines',
        icon: Icons.list,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => MedicineListPage()),
          );
        },
      ),
      DashboardItem(
        title: 'Purchase Entry',
        icon: Icons.inventory,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MainLayout(child: PharmacyPurchaseEntryPage()),
            ),
          );
        },
      ),
      DashboardItem(
        title: 'Sales Billing',
        icon: Icons.receipt,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PharmacySalesBillingPage()),
          );
        },
      ),
      DashboardItem(
        title: 'Reports',
        icon: Icons.bar_chart,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PharmacyReportsDashboard()),
          );
        },
      ),
      DashboardItem(
        title: 'Add Customer',
        icon: Icons.person_add,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PharmacyCustomerFormPage()),
          );
        },
      ),
      DashboardItem(
        title: 'Customers List',
        icon: Icons.people,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PharmacyCustomerListPage()),
          );
        },
      ),
      DashboardItem(
        title: 'Settings',
        icon: Icons.settings,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => PharmacySettingsPage()),
          );
        },
      ),
    ];

    return BackgroundScaffold(
      appBar: CustomAppBar(
        title: 'Pharmacy Dashboard',
        centerTitle: true,
        backgroundColor: Colors.red.shade800,
      ),
      scrollable: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Summary Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = (constraints.maxWidth - 20) / 2;

                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: const [
                    SizedBox(
                      width: 160,
                      child: DashboardCard(
                        title: 'Total Medicines',
                        icon: Icons.medication,
                        value: '218',
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: DashboardCard(
                        title: 'Low Stock',
                        icon: Icons.warning,
                        value: '9',
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: DashboardCard(
                        title: 'Today\'s Purchases',
                        icon: Icons.shopping_cart,
                        value: '₹3,200',
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: DashboardCard(
                        title: 'Today\'s Sales',
                        icon: Icons.attach_money,
                        value: '₹7,450',
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                int crossAxisCount = constraints.maxWidth > 1000
                    ? 4
                    : constraints.maxWidth > 600
                    ? 3
                    : 2;

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  itemCount: dashboardItems.length,
                  itemBuilder: (context, index) {
                    final item = dashboardItems[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: InkWell(
                        onTap: item.onTap,
                        borderRadius: BorderRadius.circular(16),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(item.icon, size: 40, color: Colors.indigo),
                              const SizedBox(height: 10),
                              Text(
                                item.title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),

            // Action Buttons Grid
          ],
        ),
      ),
    );
  }
}
