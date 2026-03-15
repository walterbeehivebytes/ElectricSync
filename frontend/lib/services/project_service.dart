import 'api_service.dart';

class ApiProject {
  final String id;
  final String name;
  final String status;
  final String location;
  final String? clientName;
  final double? budget;
  final List<String> assignedWorkers;

  ApiProject({
    required this.id,
    required this.name,
    required this.status,
    required this.location,
    this.clientName,
    this.budget,
    this.assignedWorkers = const [],
  });

  factory ApiProject.fromJson(Map<String, dynamic> json) {
    return ApiProject(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] as String,
      location: json['location'] as String,
      clientName: json['client_name'] as String?,
      budget: (json['budget'] as num?)?.toDouble(),
      assignedWorkers: (json['assigned_workers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// Maps backend status to a display label + color name.
  String get statusDisplay {
    switch (status) {
      case 'in_progress':
        return 'In Progress';
      case 'planning':
        return 'Planning';
      case 'on_hold':
        return 'On Hold';
      case 'completed':
        return 'Completed';
      default:
        return status;
    }
  }
}

class ProjectService {
  final _api = ApiService();

  Future<List<ApiProject>> getAllProjects() async {
    final data = await _api.getList('/api/projects/');
    return data.map((j) => ApiProject.fromJson(j as Map<String, dynamic>)).toList();
  }

  Future<ApiProject?> getProject(String id) async {
    try {
      final data = await _api.get('/api/projects/$id');
      return ApiProject.fromJson(data);
    } catch (_) {
      return null;
    }
  }
}
