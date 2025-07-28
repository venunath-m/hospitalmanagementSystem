import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/shared_widgets.dart';
import 'package:hms/views/pages/patients/AdmissionsPage.dart';
import 'package:hms/views/pages/patients/DischargesPage.dart';
import 'package:hms/views/pages/patients/MedicalRecordsPage.dart';
import 'package:hms/views/pages/patients/PatientListPage.dart';
import 'package:hms/views/pages/patients/PatientRegistrationPage.dart';
import 'package:hms/views/pages/patients/VitalsPage.dart';

class PatientsPage extends StatefulWidget {
  const PatientsPage({super.key});

  @override
  State<PatientsPage> createState() => _PatientsPageState();
}

class _PatientsPageState extends State<PatientsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      appBar: CustomAppBar(title: 'Patient Management'),
      scrollable: false,
      child: Column(
        children: [
          Container(
            color: Colors.red.shade800,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(text: 'Registration'),
                Tab(text: 'Patient List'),
                Tab(text: 'Medical Records'),
                Tab(text: 'Vitals'),
                Tab(text: 'Admissions'),
                Tab(text: 'Discharges'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                // Just widgets here — no Scaffold or AppBar inside
                PatientRegistrationPage(),
                PatientListPage(),
                MedicalRecordsPage(),
                VitalsPage(),
                AdmissionsPage(),
                DischargesPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
