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
