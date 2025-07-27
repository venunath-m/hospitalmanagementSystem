import 'package:flutter/material.dart';
import 'package:hms/custom_component_widgets/global/layouts/MainLayout.dart';
import 'package:hms/views/pages/appointments/appoinmentPage.dart';
import 'package:hms/views/pages/billing/billing_page.dart';
import 'package:hms/views/pages/dashboardView/dashboard_page.dart';
import 'package:hms/views/pages/doctors/doctorsPage.dart';
import 'package:hms/views/pages/inventory/inventory_page.dart';
import 'package:hms/views/pages/lab/lab_page.dart';
import 'package:hms/views/pages/patients/patientsPage.dart';
import 'package:hms/views/pages/pharmacy/pharmacy_page.dart';
import 'package:hms/views/pages/reports/reports_page.dart';
import 'package:hms/views/pages/settings/settings_page.dart';
import 'package:hms/views/pages/userView/login_page.dart';
import 'package:hms/views/pages/userView/user_registration_page.dart';

class AppRoutes {
  static final Map<String, WidgetBuilder> routes = {
    '/': (context) =>
        MainLayout(child: DashboardPage()), // Add this for initial route
    '/dashboard': (context) => MainLayout(child: DashboardPage()),
    '/appointments': (context) => MainLayout(child: AppointmentsPage()),
    '/patients': (context) => MainLayout(child: PatientsPage()),
    '/doctors': (context) => MainLayout(child: DoctorsPage()),
    '/billing': (context) => MainLayout(child: BillingPage()),
    '/inventory': (context) => MainLayout(child: InventoryPage()),
    '/pharmacy': (context) => MainLayout(child: PharmacyPage()),
    '/lab': (context) => MainLayout(child: LabPage()),
    '/reports': (context) => ReportsPage(),
    '/settings': (context) => SettingsPage(),
    '/login': (context) => LoginPage(),
    '/signup': (context) => MainLayout(
      child: UserRegistrationPage(
        loggedInUserCompanyId: '1',
        loggedInUserCompanyName: 'Default Company',
      ),
    ),
  };
}

final Map<String, String> featureToRoute = {
  'Dashboard': '/dashboard',
  'Appointments': '/appointments',
  'Patients': '/patients',
  'Doctors': '/doctors',
  'Billing': '/billing',
  'Inventory': '/inventory',
  'Pharmacy': '/pharmacy',
  'Lab': '/lab',
  'Reports': '/reports',
  'Settings': '/settings',
  'Login': '/login',
  'SignUp': '/signup',
  // Add Logout only if you handle it specially, no route needed
};

// Icon helper function to map features to icons
IconData getIconForFeature(String feature) {
  switch (feature) {
    case 'Dashboard':
      return Icons.dashboard;
    case 'Appointments':
      return Icons.calendar_today;
    case 'Patients':
      return Icons.people;
    case 'Doctors':
      return Icons.local_hospital;
    case 'Billing':
      return Icons.receipt_long;
    case 'Inventory':
      return Icons.inventory;
    case 'Pharmacy':
      return Icons.local_pharmacy;
    case 'Lab':
      return Icons.biotech;
    case 'Reports':
      return Icons.analytics;
    case 'Settings':
      return Icons.settings;
    case 'Login':
      return Icons.login;
    case 'Logout':
      return Icons.logout;
    case 'SignUp':
      return Icons.person_add;
    default:
      return Icons.help_outline;
  }
}
