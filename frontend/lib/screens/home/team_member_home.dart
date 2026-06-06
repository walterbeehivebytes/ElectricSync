import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../models/user.dart';
import '../../services/task_service.dart';
import '../../theme/app_theme.dart';
import '../blueprints/blueprint_viewer.dart';
import '../tasks/task_detail_view.dart';

class TeamMemberHome extends StatefulWidget {
  const TeamMemberHome({super.key});

  @override
  State<TeamMemberHome> createState() => _TeamMemberHomeState();
}

class _TeamMemberHomeState extends State<TeamMemberHome> {
  final _taskService = TaskService();
  List<Task> _tasks = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() { _loading = true; _error = null; });
    try {
      final tasks = await _taskService.getMyTasks();
      if (mounted) setState(() { _tasks = tasks; _loading = false; });
    } catch (_) {
      if (mounted) setState(() { _error = 'Could not load tasks'; _loading = false; });
    }
  }

  int _priorityOrder(TaskPriority p) => switch (p) {
    TaskPriority.urgent => 0,
    TaskPriority.high   => 1,
    TaskPriority.medium => 2,
    TaskPriority.low    => 3,
  };

  Color _priorityColor(TaskPriority p) => switch (p) {
    TaskPriority.urgent => AppColors.urgent,
    TaskPriority.high   => AppColors.high,
    TaskPriority.medium => AppColors.medium,
    TaskPriority.low    => AppColors.low,
  };

  String _priorityLabel(TaskPriority p) => switch (p) {
    TaskPriority.urgent => 'Urgent',
    TaskPriority.high   => 'High',
    TaskPriority.medium => 'Medium',
    TaskPriority.low    => 'Low',
  };

  @override
  Widget build(BuildContext context) {
    final current   = _tasks.where((t) => t.status == TaskStatus.inProgress).toList();
    final upcoming  = (_tasks
        .where((t) => t.status == TaskStatus.assigned || t.status == TaskStatus.unassigned)
        .toList()
      ..sort((a, b) => _priorityOrder(a.priority).compareTo(_priorityOrder(b.priority))));
    final completed = _tasks.where((t) => t.status == TaskStatus.completed).toList();

    return RefreshIndicator(
      color: AppColors.tm,
      backgroundColor: AppColors.surfaceHigh,
      onRefresh: _loadTasks,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_loading)
              const Center(child: Padding(padding: EdgeInsets.only(top: 48), child: CircularProgressIndicator(strokeWidth: 2)))
            else if (_error != null)
              _buildError()
            else ...[
              // Current task
              _buildCurrentSection(current),
              const SizedBox(height: 16),

              // Blueprint button
              GhostButton(
                label: 'View Blueprint — Task Locations',
                icon: Icons.map_outlined,
                fullWidth: true,
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const BlueprintViewer(userRole: UserRole.teamMember),
                )),
              ),
              const SizedBox(height: 24),

              // Stats row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  StatCard(value: '${completed.length}', label: 'Done',      color: AppColors.tl),
                  const SizedBox(width: 10),
                  StatCard(value: '${current.length}',   label: 'Active',    color: AppColors.tm),
                  const SizedBox(width: 10),
                  StatCard(value: '${upcoming.length}',  label: 'Up Next',   color: AppColors.pm),
                ]),
              ),
              const SizedBox(height: 24),

              // Up next
              SectionHeader('Up Next', count: upcoming.length, countColor: AppColors.pm),
              if (upcoming.isEmpty)
                const EmptyState(message: 'No upcoming tasks', icon: Icons.assignment_outlined)
              else
                ...upcoming.map((t) => _buildUpNextCard(t)),
              const SizedBox(height: 8),

              // Completed
              if (completed.isNotEmpty) ...[
                Divider(color: AppColors.border, height: 32),
                SectionHeader('Completed', count: completed.length, countColor: AppColors.tl),
                ...completed.map((t) => _buildCompletedRow(t)),
              ],
            ],
          ],
        ),
      ),
    );
  }

  // ── Sections ──────────────────────────────────────────────────────────────

  Widget _buildCurrentSection(List<Task> current) {
    if (current.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          const Icon(Icons.check_circle_outline, color: AppColors.tl, size: 22),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('No task in progress', style: AppText.body(14, weight: FontWeight.w600)),
            Text('Pick one from Up Next below', style: AppText.body(12, color: AppColors.textSecondary)),
          ]),
        ]),
      );
    }
    final task = current.first;
    return _buildActiveTaskCard(task);
  }

  Widget _buildActiveTaskCard(Task task) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.tm.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(color: AppColors.tm.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.tm.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
              border: Border(bottom: BorderSide(color: AppColors.tm.withValues(alpha: 0.2))),
            ),
            child: Row(children: [
              Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(color: AppColors.tm, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text('NOW WORKING', style: AppText.display(11, color: AppColors.tm, letterSpacing: 2, weight: FontWeight.w700)),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: AppText.display(22, weight: FontWeight.w700)),
                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(task.description, style: AppText.body(13, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () async {
                      final updated = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => TaskDetailView(task: task)));
                      if (updated == true && mounted) _loadTasks();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: AppColors.tm.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.tm.withValues(alpha: 0.35)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Open Task', style: AppText.body(14, weight: FontWeight.w600, color: AppColors.tm)),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward, size: 16, color: AppColors.tm),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpNextCard(Task task) {
    final color = _priorityColor(task.priority);
    return AppCard(
      accentColor: color,
      onTap: () async {
        final updated = await Navigator.push<bool>(context, MaterialPageRoute(builder: (_) => TaskDetailView(task: task)));
        if (updated == true && mounted) _loadTasks();
      },
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
          StatusChip(_priorityLabel(task.priority), color: color),
        ],
      ),
    );
  }

  Widget _buildCompletedRow(Task task) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => TaskDetailView(task: task))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.tl, size: 16),
            const SizedBox(width: 10),
            Expanded(child: Text(task.title, style: AppText.body(13, color: AppColors.textSecondary))),
            const Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.urgent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.urgent.withValues(alpha: 0.25)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline, color: AppColors.urgent, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_error!, style: AppText.body(14, color: AppColors.urgent)),
          Text('Pull down to retry', style: AppText.body(12, color: AppColors.textSecondary)),
        ])),
      ]),
    );
  }
}
