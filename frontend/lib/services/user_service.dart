import '../models/user.dart';
import 'api_service.dart';

class UserService {
  final _api = ApiService();

  Future<List<User>> getUsersByRole(String role) async {
    final data = await _api.getList('/api/users/role/$role');
    return data.map((j) => User.fromApiJson(j as Map<String, dynamic>)).toList();
  }
}
