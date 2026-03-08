import '../models/auth_user.dart';
import '../models/user.dart';

class AuthService {
  // Mock user database
  static final Map<String, Map<String, dynamic>> _users = {
    'pm@esync.com': {
      'password': 'password123',
      'user': const AuthUser(
        id: '1',
        email: 'pm@esync.com',
        name: 'Diana Chen',
        role: UserRole.projectManager,
        phone: '(555) 100-2000',
        jobTitle: 'Project Manager',
        company: 'ElectricSync Construction',
        certifications: 'PMP, Master Electrician License',
      ),
    },
    'site@esync.com': {
      'password': 'password123',
      'user': const AuthUser(
        id: '2',
        email: 'site@esync.com',
        name: 'James Park',
        role: UserRole.siteManager,
        phone: '(555) 200-3000',
        jobTitle: 'Site Manager',
        company: 'ElectricSync Construction',
        certifications: 'Master Electrician, OSHA 30',
      ),
    },
    'lead@esync.com': {
      'password': 'password123',
      'user': const AuthUser(
        id: '3',
        email: 'lead@esync.com',
        name: 'Carmen Ortiz',
        role: UserRole.teamLead,
        phone: '(555) 300-4000',
        jobTitle: 'Team Lead',
        company: 'ElectricSync Construction',
        certifications: 'Journeyman License #54321, OSHA 10',
      ),
    },
    'member@esync.com': {
      'password': 'password123',
      'user': const AuthUser(
        id: '4',
        email: 'member@esync.com',
        name: 'Mike Rodriguez',
        role: UserRole.teamMember,
        phone: '(555) 400-5000',
        jobTitle: 'Electrician',
        company: 'ElectricSync Construction',
        certifications: 'Apprentice License, OSHA 10',
      ),
    },
  };

  AuthUser? _currentUser;

  AuthUser? get currentUser => _currentUser;

  Future<AuthUser?> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    final userData = _users[email.toLowerCase()];
    if (userData != null && userData['password'] == password) {
      _currentUser = userData['user'] as AuthUser;
      return _currentUser;
    }
    return null;
  }

  Future<AuthUser?> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Check if user already exists
    if (_users.containsKey(email.toLowerCase())) {
      return null;
    }

    // Create new user
    final newUser = AuthUser(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      role: role,
    );

    _users[email.toLowerCase()] = {
      'password': password,
      'user': newUser,
    };

    _currentUser = newUser;
    return _currentUser;
  }

  Future<bool> resetPassword(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    return _users.containsKey(email.toLowerCase());
  }

  Future<void> updateProfile(AuthUser updatedUser) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (_currentUser != null) {
      _currentUser = updatedUser;
      _users[updatedUser.email.toLowerCase()]!['user'] = updatedUser;
    }
  }

  void logout() {
    _currentUser = null;
  }
}
