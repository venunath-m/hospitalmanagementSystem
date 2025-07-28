enum UserLevel {
  SuperAdmin,
  ServiceStaff,
  Doctor,
  Patient,
  DevelopAdmin, // internal use
}

extension UserLevelExtension on UserLevel {
  String get name {
    switch (this) {
      case UserLevel.SuperAdmin:
        return 'SuperAdmin';
      case UserLevel.ServiceStaff:
        return 'ServiceStaff';
      case UserLevel.Doctor:
        return 'Doctor';
      case UserLevel.Patient:
        return 'Patient';
      case UserLevel.DevelopAdmin:
        return 'DevelopAdmin';
    }
  }

  static UserLevel? fromName(String value) {
    return UserLevel.values.firstWhere(
      (e) => e.name == value,
      orElse: () => UserLevel.Patient, // default fallback
    );
  }
}
