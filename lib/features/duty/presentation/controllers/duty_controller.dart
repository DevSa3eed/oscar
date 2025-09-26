import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/duty_person.dart';
import '../../domain/entities/duty_check.dart';
import '../../domain/entities/location.dart';
import '../../domain/entities/duty_assignment.dart';
import '../../domain/repositories/duty_repository.dart';
import '../../../../core/errors/failures.dart';
import '../../../../shared/services/dependency_injection.dart';

part 'duty_controller.g.dart';

class DutyState {
  final bool isLoading;
  final List<DutyPerson> dutyPersons;
  final List<DutyCheck> dutyChecks;
  final List<Location> locations;
  final List<DutyAssignment> dutyAssignments;
  final String? errorMessage;
  final int totalPersons;
  final int presentCount;
  final int issuesCount;

  const DutyState({
    this.isLoading = false,
    this.dutyPersons = const [],
    this.dutyChecks = const [],
    this.locations = const [],
    this.dutyAssignments = const [],
    this.errorMessage,
    this.totalPersons = 0,
    this.presentCount = 0,
    this.issuesCount = 0,
  });

  DutyState copyWith({
    bool? isLoading,
    List<DutyPerson>? dutyPersons,
    List<DutyCheck>? dutyChecks,
    List<Location>? locations,
    List<DutyAssignment>? dutyAssignments,
    String? errorMessage,
    int? totalPersons,
    int? presentCount,
    int? issuesCount,
  }) {
    return DutyState(
      isLoading: isLoading ?? this.isLoading,
      dutyPersons: dutyPersons ?? this.dutyPersons,
      dutyChecks: dutyChecks ?? this.dutyChecks,
      locations: locations ?? this.locations,
      dutyAssignments: dutyAssignments ?? this.dutyAssignments,
      errorMessage: errorMessage ?? this.errorMessage,
      totalPersons: totalPersons ?? this.totalPersons,
      presentCount: presentCount ?? this.presentCount,
      issuesCount: issuesCount ?? this.issuesCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DutyState &&
        other.isLoading == isLoading &&
        _listEquals(other.dutyPersons, dutyPersons) &&
        _listEquals(other.dutyChecks, dutyChecks) &&
        _listEquals(other.locations, locations) &&
        _listEquals(other.dutyAssignments, dutyAssignments) &&
        other.errorMessage == errorMessage &&
        other.totalPersons == totalPersons &&
        other.presentCount == presentCount &&
        other.issuesCount == issuesCount;
  }

  @override
  int get hashCode {
    return Object.hash(
      isLoading,
      Object.hashAll(dutyPersons),
      Object.hashAll(dutyChecks),
      Object.hashAll(locations),
      Object.hashAll(dutyAssignments),
      errorMessage,
      totalPersons,
      presentCount,
      issuesCount,
    );
  }

  @override
  String toString() {
    return 'DutyState(isLoading: $isLoading, dutyPersons: $dutyPersons, dutyChecks: $dutyChecks, locations: $locations, dutyAssignments: $dutyAssignments, errorMessage: $errorMessage, totalPersons: $totalPersons, presentCount: $presentCount, issuesCount: $issuesCount)';
  }
}

// Helper function for list equality
bool _listEquals<T>(List<T>? a, List<T>? b) {
  if (a == null) return b == null;
  if (b == null || a.length != b.length) return false;
  for (int index = 0; index < a.length; index += 1) {
    if (a[index] != b[index]) return false;
  }
  return true;
}

@riverpod
class DutyController extends _$DutyController {
  late final DutyRepository _dutyRepository;

  @override
  DutyState build() {
    _dutyRepository = getIt<DutyRepository>();
    return const DutyState();
  }

  Future<void> loadDutyData() async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final dutyPersonsResult = await _dutyRepository.getDutyPersons();
      if (!ref.mounted) return;

      final dutyChecksResult = await _dutyRepository.getDutyChecksForDate(
        DateTime.now(),
      );
      if (!ref.mounted) return;

      final locationsResult = await _dutyRepository.getLocations();
      if (!ref.mounted) return;

      dutyPersonsResult.when(
        success: (dutyPersons) {
          if (!ref.mounted) return;

          state = state.copyWith(dutyPersons: dutyPersons);
        },
        failure: (failure) {
          if (!ref.mounted) return;
          state = state.copyWith(errorMessage: _getErrorMessage(failure));
        },
      );

      dutyChecksResult.when(
        success: (dutyChecks) {
          if (!ref.mounted) return;
          final presentCount = dutyChecks
              .where((check) => check.status == 'present')
              .length;
          final issuesCount = dutyChecks
              .where((check) => check.isOnPhone || !check.isWearingVest)
              .length;

          state = state.copyWith(
            dutyChecks: dutyChecks,
            totalPersons: dutyPersonsResult.data?.length ?? 0,
            presentCount: presentCount,
            issuesCount: issuesCount,
          );
        },
        failure: (failure) {
          if (!ref.mounted) return;
          state = state.copyWith(errorMessage: _getErrorMessage(failure));
        },
      );

      locationsResult.when(
        success: (locations) {
          if (!ref.mounted) return;
          state = state.copyWith(locations: locations);
        },
        failure: (failure) {
          if (!ref.mounted) return;
          state = state.copyWith(errorMessage: _getErrorMessage(failure));
        },
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(errorMessage: 'Failed to load duty data: $e');
    } finally {
      if (ref.mounted) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> saveDutyCheck(DutyCheck dutyCheck) async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true);

    final result = await _dutyRepository.saveDutyCheck(dutyCheck);

    if (!ref.mounted) return;

    result.when(
      success: (_) async {
        if (!ref.mounted) return;
        // Wait for data refresh to complete
        await loadDutyData();
      },
      failure: (failure) {
        if (!ref.mounted) return;
        state = state.copyWith(
          isLoading: false,
          errorMessage: _getErrorMessage(failure),
        );
      },
    );
  }

  Future<void> loadLocations() async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final locationsResult = await _dutyRepository.getLocations();
      if (!ref.mounted) return;

      locationsResult.when(
        success: (locations) {
          if (!ref.mounted) return;
          state = state.copyWith(locations: locations);
        },
        failure: (failure) {
          if (!ref.mounted) return;
          state = state.copyWith(errorMessage: _getErrorMessage(failure));
        },
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(errorMessage: 'Failed to load locations: $e');
    } finally {
      if (ref.mounted) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> loadDutyAssignments() async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final assignmentsResult = await _dutyRepository.getDutyAssignments();
      if (!ref.mounted) return;

      assignmentsResult.when(
        success: (assignments) {
          if (!ref.mounted) return;
          state = state.copyWith(dutyAssignments: assignments);
        },
        failure: (failure) {
          if (!ref.mounted) return;
          state = state.copyWith(errorMessage: _getErrorMessage(failure));
        },
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        errorMessage: 'Failed to load duty assignments: $e',
      );
    } finally {
      if (ref.mounted) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  Future<void> assignDutyPerson({
    required String dutyPersonId,
    required String locationId,
    required String locationName,
    required String locationType,
    DateTime? startTime,
    DateTime? endTime,
    String? notes,
  }) async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final dutyPerson = state.dutyPersons.firstWhere(
        (person) => person.id == dutyPersonId,
      );

      final assignment = DutyAssignment(
        id: 'assign_${DateTime.now().millisecondsSinceEpoch}',
        dutyPersonId: dutyPersonId,
        dutyPersonName: dutyPerson.name,
        dutyPersonEmail: dutyPerson.email,
        locationId: locationId,
        locationName: locationName,
        locationType: locationType,
        assignedDate: DateTime.now(),
        startTime: startTime,
        endTime: endTime,
        assignedBy: 'current_user_id', // This should come from auth state
        assignedByName: 'Current User', // This should come from auth state
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await _dutyRepository.saveDutyAssignment(assignment);
      if (!ref.mounted) return;

      result.when(
        success: (_) {
          if (!ref.mounted) return;
          loadDutyAssignments(); // Refresh assignments
          loadDutyData(); // Refresh duty data
        },
        failure: (failure) {
          if (!ref.mounted) return;
          state = state.copyWith(
            isLoading: false,
            errorMessage: _getErrorMessage(failure),
          );
        },
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to assign duty person: $e',
      );
    }
  }

  Future<void> removeDutyAssignment(String assignmentId) async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _dutyRepository.deleteDutyAssignment(assignmentId);
      if (!ref.mounted) return;

      result.when(
        success: (_) {
          if (!ref.mounted) return;
          loadDutyAssignments(); // Refresh assignments
          loadDutyData(); // Refresh duty data
        },
        failure: (failure) {
          if (!ref.mounted) return;
          state = state.copyWith(
            isLoading: false,
            errorMessage: _getErrorMessage(failure),
          );
        },
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to remove duty assignment: $e',
      );
    }
  }

  // Personnel Management Methods
  Future<void> addDutyPerson({
    required String name,
    required String role,
    required String email,
    String? photoUrl,
  }) async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final dutyPerson = DutyPerson(
        id: 'person_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        role: role,
        email: email,
        photoUrl: photoUrl,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await _dutyRepository.saveDutyPerson(dutyPerson);
      if (!ref.mounted) return;

      result.when(
        success: (_) {
          if (!ref.mounted) return;
          loadDutyData(); // Refresh duty data
          state = state.copyWith(isLoading: false);
        },
        failure: (failure) {
          if (!ref.mounted) return;
          state = state.copyWith(
            isLoading: false,
            errorMessage: _getErrorMessage(failure),
          );
        },
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to add duty person: $e',
      );
    }
  }

  Future<void> updateDutyPerson(DutyPerson updatedPerson) async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _dutyRepository.saveDutyPerson(updatedPerson);
      if (!ref.mounted) return;

      result.when(
        success: (_) {
          if (!ref.mounted) return;
          loadDutyData(); // Refresh duty data
          state = state.copyWith(isLoading: false);
        },
        failure: (failure) {
          if (!ref.mounted) return;
          state = state.copyWith(
            isLoading: false,
            errorMessage: _getErrorMessage(failure),
          );
        },
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update duty person: $e',
      );
    }
  }

  Future<void> deleteDutyPerson(String personId) async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _dutyRepository.deleteDutyPerson(personId);
      if (!ref.mounted) return;

      result.when(
        success: (_) {
          if (!ref.mounted) return;
          loadDutyData(); // Refresh duty data
          state = state.copyWith(isLoading: false);
        },
        failure: (failure) {
          if (!ref.mounted) return;
          state = state.copyWith(
            isLoading: false,
            errorMessage: _getErrorMessage(failure),
          );
        },
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete duty person: $e',
      );
    }
  }

  Future<void> updateDutyPersonAssignment({
    required String dutyPersonId,
    required String? locationId,
    required String? locationName,
    required String? locationType,
  }) async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _dutyRepository.updateDutyPersonAssignment(
        dutyPersonId: dutyPersonId,
        locationId: locationId,
        locationName: locationName,
        locationType: locationType,
      );
      if (!ref.mounted) return;

      result.when(
        success: (_) {
          if (!ref.mounted) return;
          loadDutyData(); // Refresh duty data
        },
        failure: (failure) {
          if (!ref.mounted) return;
          state = state.copyWith(
            isLoading: false,
            errorMessage: _getErrorMessage(failure),
          );
        },
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update duty person assignment: $e',
      );
    }
  }

  // Location Management Methods
  Future<void> addLocation({
    required String name,
    required String type,
    String? description,
  }) async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final location = Location(
        id: 'loc_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        type: type,
        description: description,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await _dutyRepository.saveLocation(location);
      if (!ref.mounted) return;

      result.when(
        success: (_) {
          if (!ref.mounted) return;
          loadLocations(); // Refresh locations
          state = state.copyWith(isLoading: false);
        },
        failure: (failure) {
          if (!ref.mounted) return;
          state = state.copyWith(
            isLoading: false,
            errorMessage: _getErrorMessage(failure),
          );
        },
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to add location: $e',
      );
    }
  }

  Future<void> updateLocation(Location updatedLocation) async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _dutyRepository.saveLocation(updatedLocation);
      if (!ref.mounted) return;

      result.when(
        success: (_) {
          if (!ref.mounted) return;
          loadLocations(); // Refresh locations
          state = state.copyWith(isLoading: false);
        },
        failure: (failure) {
          if (!ref.mounted) return;
          state = state.copyWith(
            isLoading: false,
            errorMessage: _getErrorMessage(failure),
          );
        },
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to update location: $e',
      );
    }
  }

  Future<void> deleteLocation(String locationId) async {
    if (!ref.mounted) return;
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final result = await _dutyRepository.deleteLocation(locationId);
      if (!ref.mounted) return;

      result.when(
        success: (_) {
          if (!ref.mounted) return;
          loadLocations(); // Refresh locations
          state = state.copyWith(isLoading: false);
        },
        failure: (failure) {
          if (!ref.mounted) return;
          state = state.copyWith(
            isLoading: false,
            errorMessage: _getErrorMessage(failure),
          );
        },
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to delete location: $e',
      );
    }
  }

  String _getErrorMessage(Failure failure) {
    return failure.when(
      serverError: (message) => message,
      networkError: (message) => message,
      authError: (message) => message,
      validationError: (message) => message,
      notFoundError: (message) => message,
      permissionError: (message) => message,
      unknownError: (message) => message,
    );
  }
}
