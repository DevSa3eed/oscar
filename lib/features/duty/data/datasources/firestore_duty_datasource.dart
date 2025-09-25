import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/duty_check_model.dart';
import '../models/duty_person_model.dart';
import '../models/location_model.dart';
import '../models/duty_assignment_model.dart';
import '../../../../core/constants/app_constants.dart';

abstract class FirestoreDutyDataSource {
  Future<List<DutyPersonModel>> getDutyPersons();
  Future<DutyPersonModel?> getDutyPersonById(String id);
  Future<void> saveDutyPerson(DutyPersonModel dutyPerson);
  Future<void> deleteDutyPerson(String id);
  Future<List<DutyCheckModel>> getDutyChecksForDate(DateTime date);
  Future<DutyCheckModel?> getDutyCheckForPerson({
    required String dutyPersonId,
    required DateTime date,
  });
  Future<void> saveDutyCheck(DutyCheckModel dutyCheck);
  Future<List<DutyCheckModel>> getDutyChecksForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  // Location management
  Future<List<LocationModel>> getLocations();
  Future<LocationModel?> getLocationById(String id);
  Future<void> saveLocation(LocationModel location);
  Future<void> deleteLocation(String id);

  // Duty assignment management
  Future<List<DutyAssignmentModel>> getDutyAssignments();
  Future<List<DutyAssignmentModel>> getDutyAssignmentsForDate(DateTime date);
  Future<DutyAssignmentModel?> getDutyAssignmentById(String id);
  Future<void> saveDutyAssignment(DutyAssignmentModel assignment);
  Future<void> deleteDutyAssignment(String id);
  Future<void> updateDutyPersonAssignment({
    required String dutyPersonId,
    required String? locationId,
    required String? locationName,
    required String? locationType,
  });
}

class FirestoreDutyDataSourceImpl implements FirestoreDutyDataSource {
  final FirebaseFirestore _firestore;

  FirestoreDutyDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<DutyPersonModel>> getDutyPersons() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.dutyPersonsCollection)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => DutyPersonModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get duty persons: $e');
    }
  }

  @override
  Future<DutyPersonModel?> getDutyPersonById(String id) async {
    try {
      final doc = await _firestore
          .collection(AppConstants.dutyPersonsCollection)
          .doc(id)
          .get();

      if (doc.exists && doc.data() != null) {
        return DutyPersonModel.fromJson({'id': doc.id, ...doc.data()!});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get duty person: $e');
    }
  }

  @override
  Future<void> saveDutyPerson(DutyPersonModel dutyPerson) async {
    try {
      final data = dutyPerson.toJson();
      data.remove('id'); // Remove ID from data

      if (dutyPerson.id.isNotEmpty) {
        // Update existing
        await _firestore
            .collection(AppConstants.dutyPersonsCollection)
            .doc(dutyPerson.id)
            .set(data);
      } else {
        // Create new
        await _firestore
            .collection(AppConstants.dutyPersonsCollection)
            .add(data);
      }
    } catch (e) {
      throw Exception('Failed to save duty person: $e');
    }
  }

  @override
  Future<void> deleteDutyPerson(String id) async {
    try {
      await _firestore
          .collection(AppConstants.dutyPersonsCollection)
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete duty person: $e');
    }
  }

  @override
  Future<List<DutyCheckModel>> getDutyChecksForDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection(AppConstants.dutyChecksCollection)
          .where(
            'checkDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('checkDate', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      return querySnapshot.docs
          .map((doc) => DutyCheckModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get duty checks: $e');
    }
  }

  @override
  Future<DutyCheckModel?> getDutyCheckForPerson({
    required String dutyPersonId,
    required DateTime date,
  }) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection(AppConstants.dutyChecksCollection)
          .where('dutyPersonId', isEqualTo: dutyPersonId)
          .where(
            'checkDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('checkDate', isLessThan: Timestamp.fromDate(endOfDay))
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return DutyCheckModel.fromJson({'id': doc.id, ...doc.data()});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get duty check: $e');
    }
  }

  @override
  Future<void> saveDutyCheck(DutyCheckModel dutyCheck) async {
    try {
      final data = dutyCheck.toJson();
      data.remove('id'); // Remove ID from data

      if (dutyCheck.id.isNotEmpty) {
        // Update existing
        await _firestore
            .collection(AppConstants.dutyChecksCollection)
            .doc(dutyCheck.id)
            .set(data);
      } else {
        // Create new
        await _firestore
            .collection(AppConstants.dutyChecksCollection)
            .add(data);
      }
    } catch (e) {
      throw Exception('Failed to save duty check: $e');
    }
  }

  @override
  Future<List<DutyCheckModel>> getDutyChecksForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.dutyChecksCollection)
          .where(
            'checkDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
          )
          .where('checkDate', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('checkDate', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => DutyCheckModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get duty checks for date range: $e');
    }
  }

  @override
  Future<List<LocationModel>> getLocations() async {
    try {
      final querySnapshot = await _firestore
          .collection('locations')
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map((doc) => LocationModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw Exception('Failed to get locations: $e');
    }
  }

  @override
  Future<LocationModel?> getLocationById(String id) async {
    try {
      final doc = await _firestore.collection('locations').doc(id).get();

      if (doc.exists && doc.data() != null) {
        return LocationModel.fromJson({'id': doc.id, ...doc.data()!});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get location: $e');
    }
  }

  @override
  Future<void> saveLocation(LocationModel location) async {
    try {
      final data = location.toJson();
      data.remove('id');

      if (location.id.isNotEmpty) {
        await _firestore.collection('locations').doc(location.id).set(data);
      } else {
        await _firestore.collection('locations').add(data);
      }
    } catch (e) {
      throw Exception('Failed to save location: $e');
    }
  }

  @override
  Future<void> deleteLocation(String id) async {
    try {
      await _firestore.collection('locations').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete location: $e');
    }
  }

  @override
  Future<List<DutyAssignmentModel>> getDutyAssignments() async {
    try {
      final querySnapshot = await _firestore
          .collection('duty_assignments')
          .orderBy('assignedDate', descending: true)
          .get();

      return querySnapshot.docs
          .map(
            (doc) =>
                DutyAssignmentModel.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get duty assignments: $e');
    }
  }

  @override
  Future<List<DutyAssignmentModel>> getDutyAssignmentsForDate(
    DateTime date,
  ) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final querySnapshot = await _firestore
          .collection('duty_assignments')
          .where(
            'assignedDate',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
          )
          .where('assignedDate', isLessThan: Timestamp.fromDate(endOfDay))
          .get();

      return querySnapshot.docs
          .map(
            (doc) =>
                DutyAssignmentModel.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get duty assignments for date: $e');
    }
  }

  @override
  Future<DutyAssignmentModel?> getDutyAssignmentById(String id) async {
    try {
      final doc = await _firestore.collection('duty_assignments').doc(id).get();

      if (doc.exists && doc.data() != null) {
        return DutyAssignmentModel.fromJson({'id': doc.id, ...doc.data()!});
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get duty assignment: $e');
    }
  }

  @override
  Future<void> saveDutyAssignment(DutyAssignmentModel assignment) async {
    try {
      final data = assignment.toJson();
      data.remove('id');

      if (assignment.id.isNotEmpty) {
        await _firestore
            .collection('duty_assignments')
            .doc(assignment.id)
            .set(data);
      } else {
        await _firestore.collection('duty_assignments').add(data);
      }
    } catch (e) {
      throw Exception('Failed to save duty assignment: $e');
    }
  }

  @override
  Future<void> deleteDutyAssignment(String id) async {
    try {
      await _firestore.collection('duty_assignments').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete duty assignment: $e');
    }
  }

  @override
  Future<void> updateDutyPersonAssignment({
    required String dutyPersonId,
    required String? locationId,
    required String? locationName,
    required String? locationType,
  }) async {
    try {
      final updates = <String, dynamic>{
        'locationId': locationId,
        'locationName': locationName,
        'locationType': locationType,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(AppConstants.dutyPersonsCollection)
          .doc(dutyPersonId)
          .update(updates);
    } catch (e) {
      throw Exception('Failed to update duty person assignment: $e');
    }
  }
}
