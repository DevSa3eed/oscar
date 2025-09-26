import 'package:cloud_firestore/cloud_firestore.dart';

class DutyAssignment {
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

  const DutyAssignment({
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

  factory DutyAssignment.fromJson(Map<String, dynamic> json) {
    return DutyAssignment(
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
      'assignedDate': assignedDate.toIso8601String(),
      'startTime': startTime?.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'assignedBy': assignedBy,
      'assignedByName': assignedByName,
      'isActive': isActive,
      'notes': notes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  DutyAssignment copyWith({
    String? id,
    String? dutyPersonId,
    String? dutyPersonName,
    String? dutyPersonEmail,
    String? locationId,
    String? locationName,
    String? locationType,
    DateTime? assignedDate,
    DateTime? startTime,
    DateTime? endTime,
    String? assignedBy,
    String? assignedByName,
    bool? isActive,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DutyAssignment(
      id: id ?? this.id,
      dutyPersonId: dutyPersonId ?? this.dutyPersonId,
      dutyPersonName: dutyPersonName ?? this.dutyPersonName,
      dutyPersonEmail: dutyPersonEmail ?? this.dutyPersonEmail,
      locationId: locationId ?? this.locationId,
      locationName: locationName ?? this.locationName,
      locationType: locationType ?? this.locationType,
      assignedDate: assignedDate ?? this.assignedDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      assignedBy: assignedBy ?? this.assignedBy,
      assignedByName: assignedByName ?? this.assignedByName,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DutyAssignment &&
        other.id == id &&
        other.dutyPersonId == dutyPersonId &&
        other.locationId == locationId &&
        other.assignedDate == assignedDate;
  }

  @override
  int get hashCode {
    return Object.hash(id, dutyPersonId, locationId, assignedDate);
  }

  @override
  String toString() {
    return 'DutyAssignment(id: $id, dutyPersonId: $dutyPersonId, locationId: $locationId, assignedDate: $assignedDate)';
  }
}
