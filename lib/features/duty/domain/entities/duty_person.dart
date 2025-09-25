class DutyPerson {
  final String id;
  final String name;
  final String role;
  final String email;
  final String? photoUrl;
  final bool isActive;
  final String? assignedLocationId;
  final String? assignedLocationName;
  final String? assignedLocationType;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DutyPerson({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    this.photoUrl,
    this.isActive = true,
    this.assignedLocationId,
    this.assignedLocationName,
    this.assignedLocationType,
    this.createdAt,
    this.updatedAt,
  });

  factory DutyPerson.fromJson(Map<String, dynamic> json) {
    return DutyPerson(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      assignedLocationId: json['assignedLocationId'] as String?,
      assignedLocationName: json['assignedLocationName'] as String?,
      assignedLocationType: json['assignedLocationType'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'email': email,
      'photoUrl': photoUrl,
      'isActive': isActive,
      'assignedLocationId': assignedLocationId,
      'assignedLocationName': assignedLocationName,
      'assignedLocationType': assignedLocationType,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  DutyPerson copyWith({
    String? id,
    String? name,
    String? role,
    String? email,
    String? photoUrl,
    bool? isActive,
    String? assignedLocationId,
    String? assignedLocationName,
    String? assignedLocationType,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DutyPerson(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isActive: isActive ?? this.isActive,
      assignedLocationId: assignedLocationId ?? this.assignedLocationId,
      assignedLocationName: assignedLocationName ?? this.assignedLocationName,
      assignedLocationType: assignedLocationType ?? this.assignedLocationType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DutyPerson &&
        other.id == id &&
        other.name == name &&
        other.role == role &&
        other.email == email &&
        other.photoUrl == photoUrl &&
        other.isActive == isActive &&
        other.assignedLocationId == assignedLocationId &&
        other.assignedLocationName == assignedLocationName &&
        other.assignedLocationType == assignedLocationType &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      role,
      email,
      photoUrl,
      isActive,
      assignedLocationId,
      assignedLocationName,
      assignedLocationType,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'DutyPerson(id: $id, name: $name, role: $role, email: $email, photoUrl: $photoUrl, isActive: $isActive, assignedLocationId: $assignedLocationId, assignedLocationName: $assignedLocationName, assignedLocationType: $assignedLocationType, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
