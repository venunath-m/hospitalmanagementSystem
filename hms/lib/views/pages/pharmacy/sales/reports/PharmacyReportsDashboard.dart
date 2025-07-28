import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';
import 'package:hms/views/pages/pharmacy/sales/SalesHistoryPage.dart';
import 'package:hms/views/pages/pharmacy/sales/reports/ReportActionButton.dart';
import 'package:hms/views/pages/pharmacy/sales/reports/ReportSummaryCard.dart';
import 'package:hms/views/pages/pharmacy/sales/sharedPharmacy_reports.dart';

class PharmacyReportsDashboard extends StatelessWidget {
  const PharmacyReportsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: BackgroundScaffold(
        scrollable: false,
        appBar: CustomAppBar(
          title: 'Pharmacy Reports DashBoard',
          centerTitle: true,
          backgroundColor: Colors.red.shade800,
        ),
        child: Column(
          children: [
            // TabBar
            Container(
              color: Colors.red.shade800,
              child: const TabBar(
                isScrollable: true,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  Tab(icon: Icon(Icons.history), text: 'Sales History'),
                  Tab(icon: Icon(Icons.point_of_sale), text: 'Sales'),
                  Tab(icon: Icon(Icons.shopping_cart), text: 'Purchases'),
                  Tab(icon: Icon(Icons.store), text: 'Stock'),
                  Tab(icon: Icon(Icons.warning_amber), text: 'Expiry'),
                  Tab(icon: Icon(Icons.summarize), text: 'Daily Summary'),
                  Tab(icon: Icon(Icons.credit_card), text: 'Credit Billing'),
                ],
              ),
            ),

            // TabBarView
            // TabBarView
            Expanded(
              child: TabBarView(
                children: [
                  // 1. Sales History Tab — Dashboard wrapped in a Card
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 700),
                            child: ListView(
                              shrinkWrap: true,
                              children: [
                                const SizedBox(height: 24),
                                GridView.count(
                                  crossAxisCount:
                                      MediaQuery.of(context).size.width > 600
                                      ? 3
                                      : 2,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                  children: const [
                                    ReportSummaryCard(
                                      title: 'Total Sales',
                                      icon: Icons.attach_money,
                                      value: '₹1,20,000',
                                      color: Colors.green,
                                    ),
                                    ReportSummaryCard(
                                      title: 'Total Purchases',
                                      icon: Icons.shopping_cart,
                                      value: '₹80,000',
                                      color: Colors.orange,
                                    ),
                                    ReportSummaryCard(
                                      title: 'Low Stock Items',
                                      icon: Icons.warning,
                                      value: '15',
                                      color: Colors.red,
                                    ),
                                    ReportSummaryCard(
                                      title: 'Total Customers',
                                      icon: Icons.people,
                                      value: '250',
                                      color: Colors.blue,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Other tabs remain unchanged
                  const SalesReportTab(),
                  const PurchaseReportTab(),
                  const StockReportTab(),
                  const ExpiryReportTab(),
                  const DailyBillingTab(),
                  const CreditBillingReportTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
