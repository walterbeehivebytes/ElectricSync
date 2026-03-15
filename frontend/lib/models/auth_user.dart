import 'user.dart';

class AuthUser {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? phone;
  final String? jobTitle;
  final String? company;
  final String? certifications;

  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.jobTitle,
    this.company,
    this.certifications,
  });

  String get roleDisplay {
    switch (role) {
      case UserRole.projectManager:
        return 'Project Manager';
      case UserRole.siteManager:
        return 'Site Manager';
      case UserRole.teamLead:
        return 'Team Lead';
      case UserRole.teamMember:
        return 'Team Member';
    }
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    final certs = json['certifications'];
    return AuthUser(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      role: UserRole.fromString(json['role'] as String),
      phone: json['phone'] as String?,
      jobTitle: (json['jobTitle'] ?? json['license_number']) as String?,
      company: json['company'] as String? ?? 'ElectricSync Construction',
      certifications: certs is List ? certs.join(', ') : certs as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'name': name,
        'role': role.value,
        'phone': phone,
        'jobTitle': jobTitle,
        'company': company,
        'certifications': certifications,
      };

  AuthUser copyWith({
    String? id,
    String? email,
    String? name,
    UserRole? role,
    String? phone,
    String? jobTitle,
    String? company,
    String? certifications,
  }) {
    return AuthUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      certifications: certifications ?? this.certifications,
    );
  }
}
