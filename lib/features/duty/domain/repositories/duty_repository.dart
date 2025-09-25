import '../entities/duty_person.dart';
import '../entities/duty_check.dart';
import '../entities/location.dart';
import '../entities/duty_assignment.dart';
import '../../../../core/utils/result.dart';

abstract class DutyRepository {
  Future<Result<List<DutyPerson>>> getDutyPersons();

  Future<Result<DutyPerson>> getDutyPersonById(String id);

  // Personnel management
  Future<Result<void>> saveDutyPerson(DutyPerson dutyPerson);
  Future<Result<void>> deleteDutyPerson(String id);

  Future<Result<List<DutyCheck>>> getDutyChecksForDate(DateTime date);

  Future<Result<DutyCheck?>> getDutyCheckForPerson({
    required String dutyPersonId,
    required DateTime date,
  });

  Future<Result<void>> saveDutyCheck(DutyCheck dutyCheck);

  Future<Result<void>> updateDutyCheck(DutyCheck dutyCheck);

  Future<Result<List<DutyCheck>>> getDutyChecksByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  // Location management
  Future<Result<List<Location>>> getLocations();
  Future<Result<Location>> getLocationById(String id);
  Future<Result<void>> saveLocation(Location location);
  Future<Result<void>> deleteLocation(String id);

  // Duty assignment management
  Future<Result<List<DutyAssignment>>> getDutyAssignments();
  Future<Result<List<DutyAssignment>>> getDutyAssignmentsForDate(DateTime date);
  Future<Result<DutyAssignment>> getDutyAssignmentById(String id);
  Future<Result<void>> saveDutyAssignment(DutyAssignment assignment);
  Future<Result<void>> deleteDutyAssignment(String id);
  Future<Result<void>> updateDutyPersonAssignment({
    required String dutyPersonId,
    required String? locationId,
    required String? locationName,
    required String? locationType,
  });
}
