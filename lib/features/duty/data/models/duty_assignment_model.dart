import '../../domain/entities/duty_assignment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DutyAssignmentModel {
  final String id;
  final String dutyPersonId;
  final String dutyPersonName;
  final String dutyPersonEmail;
  final String locationId;
  final String locationName;
  final String locationType;
  final DateTime assignedDate;
  final DateTime? startTime;
  final DateTime? endTime;
  final String assignedBy;
  final String assignedByName;
  final bool isActive;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DutyAssignmentModel({
    required this.id,
    required this.dutyPersonId,
    required this.dutyPersonName,
    required this.dutyPersonEmail,
    required this.locationId,
    required this.locationName,
    required this.locationType,
    required this.assignedDate,
    this.startTime,
    this.endTime,
    required this.assignedBy,
    required this.assignedByName,
    this.isActive = true,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory DutyAssignmentModel.fromJson(Map<String, dynamic> json) {
    return DutyAssignmentModel(
      id: json['id'] as String,
      dutyPersonId: json['dutyPersonId'] as String,
      dutyPersonName: json['dutyPersonName'] as String,
      dutyPersonEmail: json['dutyPersonEmail'] as String,
      locationId: json['locationId'] as String,
      locationName: json['locationName'] as String,
      locationType: json['locationType'] as String,
      assignedDate: _parseTimestamp(json['assignedDate'])!,
      startTime: _parseTimestamp(json['startTime']),
      endTime: _parseTimestamp(json['endTime']),
      assignedBy: json['assignedBy'] as String,
      assignedByName: json['assignedByName'] as String,
      isActive: json['isActive'] as bool? ?? true,
      notes: json['notes'] as String?,
      createdAt: _parseTimestamp(json['createdAt']),
      updatedAt: _parseTimestamp(json['updatedAt']),
    );
  }

  /// Helper method to parse timestamps from Firestore
  /// Handles both Timestamp objects and ISO string formats
  static DateTime? _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return null;

    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    } else if (timestamp is DateTime) {
      return timestamp;
    }

    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dutyPersonId': dutyPersonId,
      'dutyPersonName': dutyPersonName,
      'dutyPersonEmail': dutyPersonEmail,
      'locationId': locationId,
      'locationName': locationName,
      'locationType': locationType,
      'assignedDate': Timestamp.fromDate(assignedDate),
      'startTime': startTime != null ? Timestamp.fromDate(startTime!) : null,
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'assignedBy': assignedBy,
      'assignedByName': assignedByName,
      'isActive': isActive,
      'notes': notes,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  DutyAssignment toEntity() {
    return DutyAssignment(
      id: id,
      dutyPersonId: dutyPersonId,
      dutyPersonName: dutyPersonName,
      dutyPersonEmail: dutyPersonEmail,
      locationId: locationId,
      locationName: locationName,
      locationType: locationType,
      assignedDate: assignedDate,
      startTime: startTime,
      endTime: endTime,
      assignedBy: assignedBy,
      assignedByName: assignedByName,
      isActive: isActive,
      notes: notes,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  factory DutyAssignmentModel.fromEntity(DutyAssignment assignment) {
    return DutyAssignmentModel(
      id: assignment.id,
      dutyPersonId: assignment.dutyPersonId,
      dutyPersonName: assignment.dutyPersonName,
      dutyPersonEmail: assignment.dutyPersonEmail,
      locationId: assignment.locationId,
      locationName: assignment.locationName,
      locationType: assignment.locationType,
      assignedDate: assignment.assignedDate,
      startTime: assignment.startTime,
      endTime: assignment.endTime,
      assignedBy: assignment.assignedBy,
      assignedByName: assignment.assignedByName,
      isActive: assignment.isActive,
      notes: assignment.notes,
      createdAt: assignment.createdAt,
      updatedAt: assignment.updatedAt,
    );
  }
}
