enum PinStatus {
  pending,
  inProgress,
  completed,
  redlined,
}

class BlueprintPin {
  final String id;
  final double x; // X position on blueprint (0.0 to 1.0)
  final double y; // Y position on blueprint (0.0 to 1.0)
  final String taskId;
  final String title;
  final String? description;
  final PinStatus status;
  final String createdBy;
  final DateTime createdAt;
  final String? redlineNote;
  final DateTime? redlinedAt;

  const BlueprintPin({
    required this.id,
    required this.x,
    required this.y,
    required this.taskId,
    required this.title,
    this.description,
    required this.status,
    required this.createdBy,
    required this.createdAt,
    this.redlineNote,
    this.redlinedAt,
  });

  BlueprintPin copyWith({
    String? id,
    double? x,
    double? y,
    String? taskId,
    String? title,
    String? description,
    PinStatus? status,
    String? createdBy,
    DateTime? createdAt,
    String? redlineNote,
    DateTime? redlinedAt,
  }) {
    return BlueprintPin(
      id: id ?? this.id,
      x: x ?? this.x,
      y: y ?? this.y,
      taskId: taskId ?? this.taskId,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      redlineNote: redlineNote ?? this.redlineNote,
      redlinedAt: redlinedAt ?? this.redlinedAt,
    );
  }
}

class Blueprint {
  final String id;
  final String name;
  final String projectId;
  final String projectName;
  final String? imageUrl;
  final List<BlueprintPin> pins;
  final DateTime uploadedAt;

  const Blueprint({
    required this.id,
    required this.name,
    required this.projectId,
    required this.projectName,
    this.imageUrl,
    this.pins = const [],
    required this.uploadedAt,
  });

  Blueprint copyWith({
    String? id,
    String? name,
    String? projectId,
    String? projectName,
    String? imageUrl,
    List<BlueprintPin>? pins,
    DateTime? uploadedAt,
  }) {
    return Blueprint(
      id: id ?? this.id,
      name: name ?? this.name,
      projectId: projectId ?? this.projectId,
      projectName: projectName ?? this.projectName,
      imageUrl: imageUrl ?? this.imageUrl,
      pins: pins ?? this.pins,
      uploadedAt: uploadedAt ?? this.uploadedAt,
    );
  }
}
