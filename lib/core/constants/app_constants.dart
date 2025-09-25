class AppConstants {
  // App Info
  static const String appName = 'Duty App';
  static const String appVersion = '1.0.0';

  // User Roles
  static const String supervisorRole = 'supervisor';
  static const String hodRole = 'hod';

  // Duty Status
  static const String presentStatus = 'present';
  static const String absentStatus = 'absent';
  static const String goodStatus = 'good';
  static const String issueStatus = 'issue';

  // Duty Types
  static const String gateDuty = 'Gate Duty';
  static const String playgroundDuty = 'Playground Duty';
  static const String cafeteriaDuty = 'Cafeteria Duty';
  static const String libraryDuty = 'Library Duty';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String dutyPersonsCollection = 'duty_persons';
  static const String dutyChecksCollection = 'duty_checks';
  static const String reportsCollection = 'reports';

  // Storage Keys
  static const String userRoleKey = 'user_role';
  static const String userIdKey = 'user_id';
  static const String isLoggedInKey = 'is_logged_in';
}
