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
