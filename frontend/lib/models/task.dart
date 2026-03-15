enum TaskStatus {
  unassigned,
  assigned,
  inProgress,
  completed,
  verified,
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent,
}

class Task {
  final String id;
  final String title;
  final String description;
  final String projectId;
  final String projectName;
  final String? location; // Floor/Room
  final List<String> materialKits;
  final String? blueprintUrl;
  final TaskStatus status;
  final TaskPriority priority;
  final String? assignedTo; // Electrician ID
  final String? assignedToName;
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final List<String> workPhotos; // Photos uploaded during work
  final bool helpRequested;
  final String? helpMessage;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.projectId,
    required this.projectName,
    this.location,
    this.materialKits = const [],
    this.blueprintUrl,
    required this.status,
    required this.priority,
    this.assignedTo,
    this.assignedToName,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.workPhotos = const [],
    this.helpRequested = false,
    this.helpMessage,
  });

  factory Task.fromApiJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      projectId: json['project_id'] as String,
      projectName: json['project_id'] as String, // resolved later if needed
      location: null,
      materialKits: (json['materials_needed'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      status: _statusFromApi(json['status'] as String),
      priority: _priorityFromApi(json['priority'] as String),
      assignedTo: json['assigned_to'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
    );
  }

  static TaskStatus _statusFromApi(String s) {
    switch (s) {
      case 'in_progress':
        return TaskStatus.inProgress;
      case 'completed':
        return TaskStatus.completed;
      case 'review':
        return TaskStatus.verified;
      default:
        return TaskStatus.assigned;
    }
  }

  static TaskPriority _priorityFromApi(String p) {
    switch (p) {
      case 'urgent':
        return TaskPriority.urgent;
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      default:
        return TaskPriority.medium;
    }
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? projectId,
    String? projectName,
    String? location,
    List<String>? materialKits,
    String? blueprintUrl,
    TaskStatus? status,
    TaskPriority? priority,
    String? assignedTo,
    String? assignedToName,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    List<String>? workPhotos,
    bool? helpRequested,
    String? helpMessage,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      location: location ?? this.location,
      materialKits: materialKits ?? this.materialKits,
      blueprintUrl: blueprintUrl ?? this.blueprintUrl,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      workPhotos: workPhotos ?? this.workPhotos,
      helpRequested: helpRequested ?? this.helpRequested,
      helpMessage: helpMessage ?? this.helpMessage,
    );
  }
}
