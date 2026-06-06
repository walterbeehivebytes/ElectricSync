import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../models/user.dart';
import '../../services/project_service.dart';
import '../../services/task_service.dart';
import '../../theme/app_theme.dart';
import '../blueprints/blueprint_list.dart';
import '../tasks/work_order_creator.dart';

class ProjectManagerHome extends StatefulWidget {
  const ProjectManagerHome({super.key});

  @override
  State<ProjectManagerHome> createState() => _ProjectManagerHomeState();
}

class _ProjectManagerHomeState extends State<ProjectManagerHome> {
  final _projectService = ProjectService();
  final _taskService = TaskService();
  List<ApiProject> _projects = [];
  List<Task> _tasks = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        _projectService.getAllProjects(),
        _taskService.getAllTasks(),
      ]);
      if (mounted) {
        setState(() {
          _projects = results[0] as List<ApiProject>;
          _tasks    = results[1] as List<Task>;
          _loading  = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _error = 'Could not load data'; _loading = false; });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final active   = _projects.where((p) => p.status == 'in_progress').length;
    final planning = _projects.where((p) => p.status == 'planning').length;
    final onHold   = _projects.where((p) => p.status == 'on_hold').length;
    final done     = _projects.where((p) => p.status == 'completed').length;

    return RefreshIndicator(
      color: AppColors.pm,
      backgroundColor: AppColors.surfaceHigh,
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick actions
            Row(children: [
              Expanded(child: GhostButton(label: 'Blueprints', icon: Icons.architecture, onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BlueprintList(userRole: UserRole.projectManager))))),
              const SizedBox(width: 10),
              Expanded(child: PrimaryButton(label: 'New Task', icon: Icons.add, color: AppColors.pm, onPressed: () async { await Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkOrderCreator())); _load(); })),
            ]),
            const SizedBox(height: 24),

            if (_loading)
              const Center(child: Padding(padding: EdgeInsets.only(top: 48), child: CircularProgressIndicator()))
            else if (_error != null)
              _buildError()
            else ...[
              // Stats
              SectionHeader('Portfolio Health'),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  StatCard(value: '$active',   label: 'Active',   color: AppColors.pm),
                  const SizedBox(width: 10),
                  StatCard(value: '$planning', label: 'Planning', color: AppColors.sm),
                  const SizedBox(width: 10),
                  StatCard(value: '$onHold',   label: 'On Hold',  color: AppColors.high),
                  const SizedBox(width: 10),
                  StatCard(value: '$done',     label: 'Done',     color: AppColors.tl),
                ]),
              ),
              const SizedBox(height: 24),

              // Projects
              SectionHeader('Active Projects', count: _projects.length, countColor: AppColors.pm),
              if (_projects.isEmpty)
                const EmptyState(message: 'No projects yet', icon: Icons.folder_open)
              else
                ..._projects.map(_buildProjectCard),
              const SizedBox(height: 8),

              // All tasks
              SectionHeader('All Tasks', count: _tasks.length, countColor: AppColors.pm),
              if (_tasks.isEmpty)
                const EmptyState(message: 'No tasks yet', icon: Icons.assignment_outlined)
              else
                ..._tasks.map(_buildTaskCard),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        children: [
          const EmptyState(message: '', icon: Icons.error_outline),
          Text(_error!, style: AppText.body(14, color: AppColors.urgent)),
          const SizedBox(height: 8),
          GhostButton(label: 'Retry', onPressed: _load, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildProjectCard(ApiProject project) {
    final color = switch (project.status) {
      'in_progress' => AppColors.tl,
      'on_hold'     => AppColors.high,
      'planning'    => AppColors.sm,
      _             => AppColors.textMuted,
    };
    return AppCard(
      accentColor: color,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(project.name, style: AppText.body(14, weight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(project.location, style: AppText.body(12, color: AppColors.textSecondary)),
                if (project.clientName != null)
                  Text(project.clientName!, style: AppText.body(11, color: AppColors.textMuted)),
              ],
            ),
          ),
          StatusChip(project.statusDisplay, color: color),
        ],
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    final priorityColor = switch (task.priority) {
      TaskPriority.urgent => AppColors.urgent,
      TaskPriority.high   => AppColors.high,
      TaskPriority.medium => AppColors.medium,
      TaskPriority.low    => AppColors.low,
    };
    final (statusLabel, statusColor) = switch (task.status) {
      TaskStatus.inProgress => ('In Prog',  AppColors.sm),
      TaskStatus.completed  => ('Done',     AppColors.tl),
      TaskStatus.verified   => ('QC',       AppColors.tl),
      TaskStatus.assigned   => ('Assigned', AppColors.high),
      TaskStatus.unassigned => ('Pending',  AppColors.textMuted),
    };
    return AppCard(
      accentColor: priorityColor,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: AppText.body(14, weight: FontWeight.w600)),
                if (task.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Text(task.description, style: AppText.body(12, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
              ],
            ),
          ),
          StatusChip(statusLabel, color: statusColor),
        ],
      ),
    );
  }
}
