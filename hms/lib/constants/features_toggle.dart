// Refactored FeatureToggles class
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class FeatureToggles {
  // Static Navigation Menu
  static Map<String, bool> mainMenu = {
    'Dashboard': true,
    'Appointments': true,
    'Patients': true,
    'Doctors': true,
    'Billing': true,
    'Inventory': true,
    'Pharmacy': true,
    'Lab': true,
    'Reports': true,
    'Settings': true,
    'Login': true,
    'Logout': true,
    'SignUp': true,
    'Hospital Facilities': true,
  };

  // Grouped Feature Toggles
  static Map<String, bool> appointmentFeatures = {
    'Book Appointment': false,
    'Appointment List': false,
    'Calendar View': false,
  };

  static Map<String, bool> patientFeatures = {
    'Patient Registration': false,
    'Patient List': false,
    'Medical Records': false,
    'Vitals': false,
    'Admissions': false,
    'Discharges': false,
  };

  static Map<String, bool> doctorFeatures = {
    'Doctor Directory': false,
    'Doctor Schedules': false,
    'Specializations': false,
  };

  static Map<String, bool> billingFeatures = {
    'Generate Bill': false,
    'Payment History': false,
    'Insurance Claims': false,
  };

  static Map<String, bool> inventoryFeatures = {
    'Stock Management': false,
    'Suppliers': false,
    'Purchase Orders': false,
  };

  static Map<String, bool> labFeatures = {
    'Lab Tests': false,
    'Test Results': false,
    'Sample Collection': false,
  };

  static Map<String, bool> pharmacyFeatures = {
    'Medicine Inventory': false,
    'Issue Medicines': false,
    'Prescriptions': false,
  };

  static Map<String, bool> reportFeatures = {
    'Appointment Reports': false,
    'Revenue Reports': false,
    'Patient Visit Reports': false,
    'Inventory Usage': false,
    'Doctor Performance': false,
    'Admission Reports': false,
  };

  static Map<String, bool> settingFeatures = {
    'User Management': false,
    'Roles & Permissions': false,
    'Hospital Details': false,
    'Departments': false,
  };

  // Categorized Group Accessors (for UI)
  static Map<String, Map<String, bool>> categorized = {
    'Main Menu': mainMenu,
    'Appointments': appointmentFeatures,
    'Patients': patientFeatures,
    'Doctors': doctorFeatures,
    'Billing': billingFeatures,
    'Inventory': inventoryFeatures,
    'Lab': labFeatures,
    'Pharmacy': pharmacyFeatures,
    'Reports': reportFeatures,
    'Settings': settingFeatures,
  };

  // Combine all
  static Map<String, bool> get allFeatures => {
    ...mainMenu,
    ...appointmentFeatures,
    ...patientFeatures,
    ...doctorFeatures,
    ...billingFeatures,
    ...inventoryFeatures,
    ...labFeatures,
    ...pharmacyFeatures,
    ...reportFeatures,
    ...settingFeatures,
  };
  static Map<String, bool> getFeaturesForRole(String role) {
    if (role == 'DevelopAdmin') {
      return {for (var feature in allFeatures.keys) feature: true};
    }
    return mainMenu; // subset for others
  }

  static Future<Map<String, bool>> getFeaturesForUser(String role) async {
    if (role == 'DevelopAdmin') {
      return {for (var feature in allFeatures.keys) feature: true};
    }

    final prefs = await SharedPreferences.getInstance();
    final featureListString = prefs.getString('userFeatures');
    final enabledFeatures =
        featureListString == null || featureListString.isEmpty
        ? []
        : List<String>.from(jsonDecode(featureListString));

    // Build the map with true/false for all features
    return {
      for (var key in allFeatures.keys) key: enabledFeatures.contains(key),
    };
  }
}

// UI helper for feature toggles (widget example)
