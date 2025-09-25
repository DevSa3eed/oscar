import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../core/utils/app_logger.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  late final FirebaseFirestore _firestore;
  late final FirebaseAuth _auth;

  FirebaseFirestore get firestore => _firestore;
  FirebaseAuth get auth => _auth;

  void initialize() {
    AppLogger.firebase('Initializing Firebase services');

    try {
      // Check if Firebase is available
      final apps = Firebase.apps;
      if (apps.isEmpty) {
        throw Exception(
          'No Firebase apps available. Firebase.initializeApp() may have failed.',
        );
      }

      _firestore = FirebaseFirestore.instance;
      _auth = FirebaseAuth.instance;

      // Configure Firestore settings with reduced logging
      _configureFirestoreSettings();

      // Enable offline persistence for Firestore
      _enableOfflinePersistence();

      AppLogger.firebase('Firebase services initialized successfully');
    } catch (e) {
      AppLogger.firebase('Failed to initialize Firebase services: $e');
      // Set up fallback instances or handle gracefully
      rethrow;
    }
  }

  void _configureFirestoreSettings() {
    if (kDebugMode) {
      // Reduce Firestore logging in debug mode
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    } else {
      // Production settings
      _firestore.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    }
  }

  void _enableOfflinePersistence() {
    try {
      // Persistence is already configured in _configureFirestoreSettings
      // This method is kept for any additional offline-specific configuration
    } catch (e) {
      // Persistence may already be enabled - this is expected
    }
  }

  // Helper method to create initial collections and sample data
  Future<void> initializeCollections() async {
    try {
      // Check if user is authenticated before trying to create data
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        AppLogger.firebase(
          'No authenticated user, skipping collection initialization',
        );
        return;
      }

      await _createInitialData();
    } catch (e) {
      // Error initializing collections - this is expected in some cases
      AppLogger.firebase('Failed to initialize collections: $e');
    }
  }

  Future<void> _createInitialData() async {
    // Check if we already have data
    final usersSnapshot = await _firestore.collection('users').limit(1).get();
    if (usersSnapshot.docs.isNotEmpty) {
      return; // Data already exists
    }

    // Create sample locations
    await _createSampleLocations();

    // Create sample duty persons
    await _createSampleDutyPersons();
  }

  Future<void> _createSampleLocations() async {
    final locations = [
      {
        'name': 'Main Gate',
        'type': 'Gate',
        'description': 'Primary entrance gate',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Playground',
        'type': 'Recreation',
        'description': 'Student playground area',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Cafeteria',
        'type': 'Dining',
        'description': 'Student cafeteria',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Library',
        'type': 'Academic',
        'description': 'Main library building',
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final location in locations) {
      await _firestore.collection('locations').add(location);
    }
  }

  Future<void> _createSampleDutyPersons() async {
    final dutyPersons = [
      {
        'name': 'John Smith',
        'employeeId': 'EMP001',
        'department': 'Security',
        'contactNumber': '+1234567890',
        'email': 'john.smith@company.com',
        'isActive': true,
        'dutyType': 'Gate Duty',
        'shift': 'Morning',
        'locationId': null,
        'locationName': 'Main Gate',
        'locationType': 'Gate',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Sarah Johnson',
        'employeeId': 'EMP002',
        'department': 'Supervision',
        'contactNumber': '+1234567891',
        'email': 'sarah.johnson@company.com',
        'isActive': true,
        'dutyType': 'Playground Duty',
        'shift': 'Morning',
        'locationId': null,
        'locationName': 'Playground',
        'locationType': 'Recreation',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Mike Brown',
        'employeeId': 'EMP003',
        'department': 'Food Service',
        'contactNumber': '+1234567892',
        'email': 'mike.brown@company.com',
        'isActive': true,
        'dutyType': 'Cafeteria Duty',
        'shift': 'Lunch',
        'locationId': null,
        'locationName': 'Cafeteria',
        'locationType': 'Dining',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Emily Davis',
        'employeeId': 'EMP004',
        'department': 'Academic Support',
        'contactNumber': '+1234567893',
        'email': 'emily.davis@company.com',
        'isActive': true,
        'dutyType': 'Library Duty',
        'shift': 'Evening',
        'locationId': null,
        'locationName': 'Library',
        'locationType': 'Academic',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final dutyPerson in dutyPersons) {
      await _firestore.collection('duty_persons').add(dutyPerson);
    }
  }
}
