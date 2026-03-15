import '../models/task.dart';
import 'api_service.dart';

class TaskService {
  final _api = ApiService();

  /// Tasks assigned to the currently authenticated user.
  Future<List<Task>> getMyTasks() async {
    final data = await _api.getList('/api/tasks/my');
    return data.map((j) => Task.fromApiJson(j as Map<String, dynamic>)).toList();
  }

  /// All tasks (requires auth).
  Future<List<Task>> getAllTasks() async {
    final data = await _api.getList('/api/tasks/');
    return data.map((j) => Task.fromApiJson(j as Map<String, dynamic>)).toList();
  }

  /// Tasks for a specific project.
  Future<List<Task>> getTasksByProject(String projectId) async {
    final data = await _api.getList('/api/tasks/project/$projectId');
    return data.map((j) => Task.fromApiJson(j as Map<String, dynamic>)).toList();
  }
}
