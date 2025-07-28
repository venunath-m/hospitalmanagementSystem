import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';
import 'package:hms/views/pages/appointments/AppointmentBookingPage.dart';
import 'package:hms/views/pages/appointments/AppointmentListingPage.dart';
import 'package:hms/views/pages/patients/AdmissionListPage.dart';
import 'package:hms/views/pages/patients/AdmitPatientPage.dart';

class AdmissionsPage extends StatefulWidget {
  const AdmissionsPage({super.key});

  @override
  State<AdmissionsPage> createState() => _AdmissionsPageState();
}

class _AdmissionsPageState extends State<AdmissionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            color: Colors.red.shade800,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: "Admit Patient"),
                Tab(text: "Admission List"),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                // Just widgets here — no Scaffold or AppBar inside
                AdmitPatientPage(),
                AdmissionListPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
