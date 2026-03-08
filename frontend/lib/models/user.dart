enum UserRole {
  projectManager,
  siteManager,
  teamLead,
  teamMember,
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
