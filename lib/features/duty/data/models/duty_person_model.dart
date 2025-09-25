import '../../domain/entities/duty_person.dart';

class DutyPersonModel {
  final String id;
  final String name;
  final String role;
  final String email;
  final String? photoUrl;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const DutyPersonModel({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    this.photoUrl,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory DutyPersonModel.fromJson(Map<String, dynamic> json) {
    return DutyPersonModel(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      email: json['email'] as String,
      photoUrl: json['photoUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
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
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory DutyPersonModel.fromEntity(DutyPerson dutyPerson) {
    return DutyPersonModel(
      id: dutyPerson.id,
      name: dutyPerson.name,
      role: dutyPerson.role,
      email: dutyPerson.email,
      photoUrl: dutyPerson.photoUrl,
      isActive: dutyPerson.isActive,
      createdAt: dutyPerson.createdAt,
      updatedAt: dutyPerson.updatedAt,
    );
  }

  DutyPerson toEntity() {
    return DutyPerson(
      id: id,
      name: name,
      role: role,
      email: email,
      photoUrl: photoUrl,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DutyPersonModel &&
        other.id == id &&
        other.name == name &&
        other.role == role &&
        other.email == email &&
        other.photoUrl == photoUrl &&
        other.isActive == isActive &&
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
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'DutyPersonModel(id: $id, name: $name, role: $role, email: $email, photoUrl: $photoUrl, isActive: $isActive, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
