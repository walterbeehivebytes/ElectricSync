enum UserRole {
  projectManager,
  siteManager,
  teamLead,
  teamMember;

  String get value {
    switch (this) {
      case UserRole.projectManager:
        return 'project_manager';
      case UserRole.siteManager:
        return 'site_manager';
      case UserRole.teamLead:
        return 'team_lead';
      case UserRole.teamMember:
        return 'team_member';
    }
  }

  static UserRole fromString(String value) {
    switch (value) {
      case 'project_manager':
        return UserRole.projectManager;
      case 'site_manager':
        return UserRole.siteManager;
      case 'team_lead':
        return UserRole.teamLead;
      case 'team_member':
        return UserRole.teamMember;
      default:
        return UserRole.teamMember;
    }
  }
}

class User {
  final String id;
  final String name;
  final UserRole role;

  const User({
    required this.id,
    required this.name,
    required this.role,
  });

  factory User.fromApiJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      role: UserRole.fromString(json['role'] as String),
    );
  }

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
}
