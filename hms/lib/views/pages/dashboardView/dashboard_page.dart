import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String username = 'Admin'; // dummy for now

  List<SalesData> weeklyAppointments = [];
  List<SalesData> monthlyAdmissions = [];

  @override
  void initState() {
    super.initState();
    loadDummyData();
  }

  void loadDummyData() {
    final now = DateTime.now();

    weeklyAppointments = List.generate(7, (index) {
      final day = now.subtract(Duration(days: 6 - index));
      return SalesData(day, (10 + index * 3).toDouble()); // random
    });

    monthlyAdmissions = List.generate(12, (index) {
      final month = DateTime(now.year, index + 1, 1);
      return SalesData(month, (50 + index * 8).toDouble());
    });

    setState(() {});
  }

  Widget buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 6,
      shadowColor: color.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 36, color: color),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildChart(String title, List<SalesData> data) {
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
                    color: Colors.deepPurple,
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

  @override
  Widget build(BuildContext context) {
    return VideoBackgroundScaffold(
      appBar: CustomAppBar(title: 'Dashboard', showBackButton: false),
      scrollable: false,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Welcome, $username 👋',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),

              /// Metrics
              /// Metrics Section (Refactored)
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children:
                    [
                      buildMetricCard(
                        "Total Patients",
                        "1,234",
                        Icons.people,
                        Colors.teal,
                      ),
                      buildMetricCard(
                        "Admitted Today",
                        "36",
                        Icons.local_hospital,
                        Colors.redAccent,
                      ),
                      buildMetricCard(
                        "Doctors On Duty",
                        "12",
                        Icons.medical_services,
                        Colors.green,
                      ),
                      buildMetricCard(
                        "Appointments Today",
                        "58",
                        Icons.calendar_today,
                        Colors.blueAccent,
                      ),
                    ].map((card) {
                      return ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: 280),
                        child: card,
                      );
                    }).toList(),
              ),

              SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 500),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: buildChart(
                          "Weekly Appointments",
                          weeklyAppointments,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  Divider(),

                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 500),
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: buildChart(
                          "Monthly Admissions",
                          monthlyAdmissions,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              /// Charts
              //buildChart("Weekly Appointments", weeklyAppointments),
              SizedBox(height: 200),
            ],
          ),
        ),
      ),
    );
  }
}

class SalesData {
  final DateTime date;
  final double value;
  SalesData(this.date, this.value);
}
