import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';
import 'package:hms/fireStore_service/purchaseSummaryCollection_service.dart';
import 'package:hms/fireStore_service/salesSummary_service.dart';
import 'package:hms/fireStore_service/ledger_summary_service.dart';
import 'package:hms/views/pages/userView/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final LedgerSummaryService _ledgerSummaryService = LedgerSummaryService();
  String? username;
  String? companyId;
  bool isLoading = true;
  List<SalesData> monthlySales = [];
  List<SalesData> weeklyRevenue = [];
  final ScrollController _salesScrollController = ScrollController();
  final ScrollController _customersScrollController = ScrollController();
  final SalessummaryService _SalessummaryService = SalessummaryService();
  final PurchaseSummaryCollectionService _PurchaseSummaryCollectionService =
      PurchaseSummaryCollectionService();
  @override
  void initState() {
    super.initState();
    loadCompanyId().then((_) {
      print('Loaded companyId: $companyId');
      checkCompanyRenewalStatus(context);
      loadSalesData();
    });
    loadUsername();
  }

  Future<void> loadCompanyId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      companyId = prefs.getString('companyId');
    });
  }

  Future<void> checkCompanyRenewalStatus(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final companyId = prefs.getString('companyId');
    final userLevel = prefs.getString('userlevel'); // <-- Get the userLevel

    if (companyId == null) return;

    final db = FirebaseFirestore.instance;
    final querySnapshot = await db
        .collection('companies')
        .where('id', isEqualTo: companyId)
        .limit(1)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final companyData = querySnapshot.docs.first.data();

      // Skip the check if user is DevelopAdmin
      if (userLevel == 'DevelopAdmin') return;

      final renewalDate = (companyData['renewalDate'] as Timestamp).toDate();

      if (DateTime.now().isAfter(renewalDate)) {
        // Show alert and log the user out
        await FirebaseAuth.instance.signOut();
        prefs.clear(); // Optional: clear shared prefs

        // Navigate to login page
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => LoginPage()),
          (route) => false,
        );

        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Subscription Expired'),
            content: Text(
              'Your subscription has expired. Please contact your administrator.\nContact: 8590216646',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  Future<void> loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('loggedInUsername') ?? 'User';
      isLoading = false;
    });
  }

  Future<void> loadSalesData() async {
    if (companyId == null) return;

    final db = FirebaseFirestore.instance;
    final now = DateTime.now();
    final firstDayOfYear = DateTime(now.year, 1, 1);
    final sevenDaysAgo = now.subtract(Duration(days: 6));

    final querySnapshot = await db
        .collection('sales_summary')
        .where('companyId', isEqualTo: companyId)
        .where(
          'billEntryDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(firstDayOfYear),
        )
        .get();

    // Temporary maps to accumulate totals
    Map<int, double> monthTotals = {};
    Map<DateTime, double> dayTotals = {};

    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      final billEntryDateStr = data['billEntryDate'] as String?;
      final grandTotal = (data['grandTotal'] as num?)?.toDouble() ?? 0;

      if (billEntryDateStr == null) continue;

      final date = DateTime.parse(billEntryDateStr);

      // Monthly totals
      final month = date.month;
      monthTotals[month] = (monthTotals[month] ?? 0) + grandTotal;

      // Weekly totals
      if (date.isAfter(sevenDaysAgo.subtract(Duration(days: 1)))) {
        final day = DateTime(date.year, date.month, date.day);
        dayTotals[day] = (dayTotals[day] ?? 0) + grandTotal;
      }
    }

    // Convert to lists
    final monthlyList = List.generate(12, (i) {
      final month = i + 1;
      return SalesData(DateTime(now.year, month, 1), monthTotals[month] ?? 0);
    });

    final weeklyList = List.generate(7, (i) {
      final date = sevenDaysAgo.add(Duration(days: i));
      return SalesData(
        date,
        dayTotals[DateTime(date.year, date.month, date.day)] ?? 0,
      );
    });

    // Update state
    setState(() {
      monthlySales = monthlyList;
      weeklyRevenue = weeklyList;
    });
  }

  Widget buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 20, color: color)),
          ],
        ),
      ),
    );
  }

  Widget buildChart(String title, List<SalesData> data, SplineType type) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            SizedBox(
              height: 200,
              child: SfCartesianChart(
                primaryXAxis: DateTimeAxis(),
                series: <CartesianSeries<SalesData, DateTime>>[
                  SplineSeries<SalesData, DateTime>(
                    dataSource: data,
                    xValueMapper: (SalesData sales, _) => sales.date,
                    yValueMapper: (SalesData sales, _) => sales.value,
                    splineType: type,
                    color: Colors.blue,
                    animationDuration: 1500,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPaginatedList(String title, ScrollController controller) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: controller,
              itemCount: 20,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('$title Item #$index'),
                  subtitle: Text('Details of item #$index'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(BuildContext context, String text, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Text(
        text,
        style: TextStyle(
          color: Colors.blueAccent,
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFooterLinks(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: [
        _buildFooterLink(context, "Privacy Policy", "/privacyPolicy"),
        _buildFooterLink(context, "Refund Policy", "/refundPolicy"),
        _buildFooterLink(context, "Shipping Policy", "/shippingPolicy"),
        _buildFooterLink(context, "Terms & Conditions", "/termsandConditions"),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return BackgroundScaffold(
      appBar: CustomAppBar(title: 'Dashboard'),
       scrollable: false,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: Image.asset('assets/burjLogo.png', fit: BoxFit.cover),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hi, $username!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: FutureBuilder<double>(
                          future: _SalessummaryService.getTotalSales(),
                          builder: (context, snapshot) {
                            return buildMetricCard(
                              "Total Sales",
                              snapshot.connectionState ==
                                      ConnectionState.waiting
                                  ? "Loading..."
                                  : snapshot.hasError
                                  ? "Error"
                                  : "₹${snapshot.data?.toStringAsFixed(2)}",
                              Icons.show_chart,
                              Colors.green,
                            );
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: FutureBuilder<double>(
                          future:
                              _PurchaseSummaryCollectionService.getTotalPayments(),
                          builder: (context, snapshot) {
                            return buildMetricCard(
                              "Total Purchase",
                              snapshot.connectionState ==
                                      ConnectionState.waiting
                                  ? "Loading..."
                                  : snapshot.hasError
                                  ? "Error"
                                  : "₹${snapshot.data?.toStringAsFixed(2)}",
                              Icons.payments,
                              Colors.blue,
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  FutureBuilder<Map<String, List<DailyLedger>>>(
                    future: _ledgerSummaryService.getWeeklySummary(
                      collection: 'account_book',
                      companyId: companyId!,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error loading account book data');
                      }

                      final credits = snapshot.data!['credit']!;
                      final debits = snapshot.data!['debit']!;

                      final totalCredit = credits.fold<double>(
                        0.0,
                        (sum, item) => sum + item.amount,
                      );

                      final totalDebit = debits.fold<double>(
                        0.0,
                        (sum, item) => sum + item.amount,
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Account Book (Weekly)",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: buildMetricCard(
                                  "Weekly Credits",
                                  "₹${totalCredit.toStringAsFixed(2)}",
                                  Icons.trending_up,
                                  Colors.teal,
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: buildMetricCard(
                                  "Weekly Debits",
                                  "₹${totalDebit.toStringAsFixed(2)}",
                                  Icons.trending_down,
                                  Colors.redAccent,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),

                  FutureBuilder<Map<String, List<DailyLedger>>>(
                    future: _ledgerSummaryService.getWeeklySummary(
                      collection: 'customer_ledger',
                      companyId: companyId!,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error loading customer ledger data');
                      }

                      final credits = snapshot.data!['credit']!;
                      final debits = snapshot.data!['debit']!;

                      final totalCredit = credits.fold<double>(
                        0.0,
                        (sum, item) => sum + item.amount,
                      );

                      final totalDebit = debits.fold<double>(
                        0.0,
                        (sum, item) => sum + item.amount,
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 12),
                          Text(
                            "Customer Ledger (Weekly)",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: buildMetricCard(
                                  "Weekly Credits",
                                  "₹${totalCredit.toStringAsFixed(2)}",
                                  Icons.account_balance_wallet,
                                  Colors.deepPurple,
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: buildMetricCard(
                                  "Weekly Debits",
                                  "₹${totalDebit.toStringAsFixed(2)}",
                                  Icons.account_balance_wallet_outlined,
                                  Colors.orange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),

                  FutureBuilder<Map<String, List<DailyLedger>>>(
                    future: _ledgerSummaryService.getWeeklySummary(
                      collection: 'supplier_ledger',
                      companyId: companyId!,
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Text('Error loading supplier ledger data');
                      }

                      final credits = snapshot.data!['credit']!;
                      final debits = snapshot.data!['debit']!;

                      final totalCredit = credits.fold<double>(
                        0.0,
                        (sum, item) => sum + item.amount,
                      );

                      final totalDebit = debits.fold<double>(
                        0.0,
                        (sum, item) => sum + item.amount,
                      );

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 12),
                          Text(
                            "Supplier Ledger (Weekly)",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: buildMetricCard(
                                  "Weekly Credits",
                                  "₹${totalCredit.toStringAsFixed(2)}",
                                  Icons.shopping_cart,
                                  Colors.indigo,
                                ),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: buildMetricCard(
                                  "Weekly Debits",
                                  "₹${totalDebit.toStringAsFixed(2)}",
                                  Icons.shopping_cart_checkout,
                                  Colors.brown,
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 12),
                  buildChart(
                    "Monthly Sales",
                    monthlySales,
                    SplineType.cardinal,
                  ),
                  buildChart(
                    "Weekly Revenue",
                    weeklyRevenue,
                    SplineType.natural,
                  ),

                  SizedBox(height: 12),
                  SizedBox(height: 24),
                  Divider(),
                  SizedBox(height: 12),
                  Center(child: _buildFooterLinks(context)),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SalesData {
  final DateTime date;
  final double value;

  SalesData(this.date, this.value);
}
