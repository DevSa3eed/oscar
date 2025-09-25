import '../../domain/entities/duty_person.dart';
import '../../domain/entities/duty_check.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/duty_assignment.dart';
import '../../domain/repositories/duty_repository.dart';
import '../datasources/firestore_duty_datasource.dart';
import '../models/duty_person_model.dart';
import '../models/duty_check_model.dart';
import '../models/location_model.dart';
import '../models/duty_assignment_model.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/errors/failures.dart';

class FirestoreDutyRepositoryImpl implements DutyRepository {
  final FirestoreDutyDataSource _dataSource;

  FirestoreDutyRepositoryImpl({required FirestoreDutyDataSource dataSource})
    : _dataSource = dataSource;

  @override
  Future<Result<List<DutyPerson>>> getDutyPersons() async {
    try {
      final dutyPersonModels = await _dataSource.getDutyPersons();
      final dutyPersons = dutyPersonModels
          .map((model) => model.toEntity())
          .toList();
      return Result.success(dutyPersons);
    } catch (e) {
      return Result.failure(ServerError('Failed to get duty persons: $e'));
    }
  }

  @override
  Future<Result<DutyPerson>> getDutyPersonById(String id) async {
    try {
      final dutyPersonModel = await _dataSource.getDutyPersonById(id);
      if (dutyPersonModel != null) {
        return Result.success(dutyPersonModel.toEntity());
      } else {
        return Result.failure(NotFoundError('Duty person not found'));
      }
    } catch (e) {
      return Result.failure(ServerError('Failed to get duty person: $e'));
    }
  }

  @override
  Future<Result<void>> saveDutyPerson(DutyPerson dutyPerson) async {
    try {
      final dutyPersonModel = DutyPersonModel.fromEntity(dutyPerson);
      await _dataSource.saveDutyPerson(dutyPersonModel);
      return Result.success(null);
    } catch (e) {
      return Result.failure(ServerError('Failed to save duty person: $e'));
    }
  }

  @override
  Future<Result<void>> deleteDutyPerson(String id) async {
    try {
      await _dataSource.deleteDutyPerson(id);
      return Result.success(null);
    } catch (e) {
      return Result.failure(ServerError('Failed to delete duty person: $e'));
    }
  }

  @override
  Future<Result<List<DutyCheck>>> getDutyChecksForDate(DateTime date) async {
    try {
      final dutyCheckModels = await _dataSource.getDutyChecksForDate(date);
      final dutyChecks = dutyCheckModels
          .map((model) => model.toEntity())
          .toList();
      return Result.success(dutyChecks);
    } catch (e) {
      return Result.failure(ServerError('Failed to get duty checks: $e'));
    }
  }

  @override
  Future<Result<DutyCheck?>> getDutyCheckForPerson({
    required String dutyPersonId,
    required DateTime date,
  }) async {
    try {
      final dutyCheckModel = await _dataSource.getDutyCheckForPerson(
        dutyPersonId: dutyPersonId,
        date: date,
      );
      return Result.success(dutyCheckModel?.toEntity());
    } catch (e) {
      return Result.failure(ServerError('Failed to get duty check: $e'));
    }
  }

  @override
  Future<Result<void>> saveDutyCheck(DutyCheck dutyCheck) async {
    try {
      final dutyCheckModel = DutyCheckModel.fromEntity(dutyCheck);
      await _dataSource.saveDutyCheck(dutyCheckModel);
      return Result.success(null);
    } catch (e) {
      return Result.failure(ServerError('Failed to save duty check: $e'));
    }
  }

  @override
  Future<Result<void>> updateDutyCheck(DutyCheck dutyCheck) async {
    try {
      final dutyCheckModel = DutyCheckModel.fromEntity(dutyCheck);
      await _dataSource.saveDutyCheck(dutyCheckModel);
      return Result.success(null);
    } catch (e) {
      return Result.failure(ServerError('Failed to update duty check: $e'));
    }
  }

  @override
  Future<Result<List<DutyCheck>>> getDutyChecksByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final dutyCheckModels = await _dataSource.getDutyChecksForDateRange(
        startDate: startDate,
        endDate: endDate,
      );
      final dutyChecks = dutyCheckModels
          .map((model) => model.toEntity())
          .toList();
      return Result.success(dutyChecks);
    } catch (e) {
      return Result.failure(
        ServerError('Failed to get duty checks by date range: $e'),
      );
    }
  }

  @override
  Future<Result<List<Location>>> getLocations() async {
    try {
      final locationModels = await _dataSource.getLocations();
      final locations = locationModels
          .map((model) => model.toEntity())
          .toList();
      return Result.success(locations);
    } catch (e) {
      return Result.failure(ServerError('Failed to get locations: $e'));
    }
  }

  @override
  Future<Result<Location>> getLocationById(String id) async {
    try {
      final locationModel = await _dataSource.getLocationById(id);
      if (locationModel != null) {
        return Result.success(locationModel.toEntity());
      } else {
        return Result.failure(NotFoundError('Location not found'));
      }
    } catch (e) {
      return Result.failure(ServerError('Failed to get location: $e'));
    }
  }

  @override
  Future<Result<void>> saveLocation(Location location) async {
    try {
      final locationModel = LocationModel.fromEntity(location);
      await _dataSource.saveLocation(locationModel);
      return Result.success(null);
    } catch (e) {
      return Result.failure(ServerError('Failed to save location: $e'));
    }
  }

  @override
  Future<Result<void>> deleteLocation(String id) async {
    try {
      await _dataSource.deleteLocation(id);
      return Result.success(null);
    } catch (e) {
      return Result.failure(ServerError('Failed to delete location: $e'));
    }
  }

  @override
  Future<Result<List<DutyAssignment>>> getDutyAssignments() async {
    try {
      final assignmentModels = await _dataSource.getDutyAssignments();
      final assignments = assignmentModels
          .map((model) => model.toEntity())
          .toList();
      return Result.success(assignments);
    } catch (e) {
      return Result.failure(ServerError('Failed to get duty assignments: $e'));
    }
  }

  @override
  Future<Result<List<DutyAssignment>>> getDutyAssignmentsForDate(
    DateTime date,
  ) async {
    try {
      final assignmentModels = await _dataSource.getDutyAssignmentsForDate(
        date,
      );
      final assignments = assignmentModels
          .map((model) => model.toEntity())
          .toList();
      return Result.success(assignments);
    } catch (e) {
      return Result.failure(
        ServerError('Failed to get duty assignments for date: $e'),
      );
    }
  }

  @override
  Future<Result<DutyAssignment>> getDutyAssignmentById(String id) async {
    try {
      final assignmentModel = await _dataSource.getDutyAssignmentById(id);
      if (assignmentModel != null) {
        return Result.success(assignmentModel.toEntity());
      } else {
        return Result.failure(NotFoundError('Duty assignment not found'));
      }
    } catch (e) {
      return Result.failure(ServerError('Failed to get duty assignment: $e'));
    }
  }

  @override
  Future<Result<void>> saveDutyAssignment(DutyAssignment assignment) async {
    try {
      final assignmentModel = DutyAssignmentModel.fromEntity(assignment);
      await _dataSource.saveDutyAssignment(assignmentModel);
      return Result.success(null);
    } catch (e) {
      return Result.failure(ServerError('Failed to save duty assignment: $e'));
    }
  }

  @override
  Future<Result<void>> deleteDutyAssignment(String id) async {
    try {
      await _dataSource.deleteDutyAssignment(id);
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        ServerError('Failed to delete duty assignment: $e'),
      );
    }
  }

  @override
  Future<Result<void>> updateDutyPersonAssignment({
    required String dutyPersonId,
    required String? locationId,
    required String? locationName,
    required String? locationType,
  }) async {
    try {
      await _dataSource.updateDutyPersonAssignment(
        dutyPersonId: dutyPersonId,
        locationId: locationId,
        locationName: locationName,
        locationType: locationType,
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(
        ServerError('Failed to update duty person assignment: $e'),
      );
    }
  }
}
