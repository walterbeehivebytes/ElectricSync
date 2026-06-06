import 'package:flutter/material.dart';
import '../../models/auth_user.dart';
import '../../models/task.dart';
import '../../models/user.dart';
import '../../services/task_service.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';
import '../blueprints/blueprint_viewer.dart';
import '../tasks/qc_signoff.dart';
import '../tasks/work_order_creator.dart';

class TeamLeadHome extends StatefulWidget {
  final AuthUser currentUser;
  const TeamLeadHome({super.key, required this.currentUser});

  @override
  State<TeamLeadHome> createState() => _TeamLeadHomeState();
}

class _TeamLeadHomeState extends State<TeamLeadHome> {
  final _taskService = TaskService();
  final _userService = UserService();

  List<Task> _tasks = [];
  List<User> _teamMembers = [];
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
        _taskService.getTasksByTeamLead(widget.currentUser.id),
        _userService.getUsersByRole('team_member'),
      ]);
      if (mounted) {
        setState(() {
          _tasks       = results[0] as List<Task>;
          _teamMembers = results[1] as List<User>;
          _loading     = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _error = 'Could not load data'; _loading = false; });
    }
  }

  // Tasks still owned by TL (not yet delegated)
  List<Task> get _myTasks =>
      _tasks.where((t) => t.assignedTo == widget.currentUser.id).toList();

  // Tasks delegated to a team member
  List<Task> get _crewTasks =>
      _tasks.where((t) => t.assignedTo != null && t.assignedTo != widget.currentUser.id).toList();

  String _memberName(String? id) {
    if (id == null) return 'Unassigned';
    return _teamMembers.firstWhere(
      (u) => u.id == id,
      orElse: () => User(id: id, name: id, role: UserRole.teamMember),
    ).name;
  }

  // ── Assign sheet ──────────────────────────────────────────────────────────

  Future<void> _showAssignSheet(Task task) async {
    User? selectedMember;
    TaskPriority selectedPriority = task.priority;
    final descCtrl = TextEditingController(text: task.description);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text(task.title, style: AppText.display(18, weight: FontWeight.w700)),
              const SizedBox(height: 16),
              TextField(
                controller: descCtrl,
                maxLines: 2,
                style: AppText.body(14),
                decoration: const InputDecoration(labelText: 'Additional Instructions'),
              ),
              const SizedBox(height: 18),
              Text('PRIORITY', style: AppText.display(11, color: AppColors.textSecondary, letterSpacing: 2, weight: FontWeight.w700)),
              const SizedBox(height: 8),
              _priorityChips(selectedPriority, (p) => setModal(() => selectedPriority = p)),
              const SizedBox(height: 18),
              Text('ASSIGN TO CREW', style: AppText.display(11, color: AppColors.textSecondary, letterSpacing: 2, weight: FontWeight.w700)),
              const SizedBox(height: 8),
              ..._teamMembers.map((m) => _memberRow(m, selectedMember, (v) => setModal(() => selectedMember = v))),
              const SizedBox(height: 16),
              PrimaryButton(
                label: selectedMember == null ? 'Select a Crew Member' : 'Assign to ${selectedMember!.name}',
                color: AppColors.tl,
                fullWidth: true,
                onPressed: selectedMember == null ? null : () async {
                  Navigator.pop(ctx);
                  await _assignToMember(task, selectedMember!, descCtrl.text.trim(), selectedPriority);
                },
              ),
            ],
          ),
        ),
      ),
    );
    descCtrl.dispose();
  }

  Future<void> _assignToMember(Task task, User member, String description, TaskPriority priority) async {
    try {
      await _taskService.updateTask(task.id, {
        'assigned_to': member.id,
        'priority': priority.name,
        if (description.isNotEmpty) 'description': description,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Assigned to ${member.name}', style: AppText.body(14)),
            backgroundColor: AppColors.tl.withValues(alpha: 0.9),
          ),
        );
        // Only reload tasks — member list is unchanged
        final tasks = await _taskService.getTasksByTeamLead(widget.currentUser.id);
        if (mounted) setState(() => _tasks = tasks);
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Assignment failed', style: AppText.body(14)), backgroundColor: AppColors.urgent.withValues(alpha: 0.9)),
        );
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: AppColors.tl,
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
              Expanded(child: PrimaryButton(
                label: 'QC Sign-off', icon: Icons.verified_outlined, color: AppColors.tl,
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => QCSignoff(currentUser: widget.currentUser),
                )),
              )),
              const SizedBox(width: 10),
              Expanded(child: GhostButton(
                label: 'Blueprints', icon: Icons.architecture,
                onPressed: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => const BlueprintViewer(userRole: UserRole.teamLead),
                )),
              )),
            ]),
            const SizedBox(height: 10),
            GhostButton(
              label: 'Create Task',
              icon: Icons.add_task,
              fullWidth: true,
              onPressed: () async {
                await Navigator.push(context, MaterialPageRoute(
                  builder: (_) => WorkOrderCreator(currentUser: widget.currentUser),
                ));
                _load();
              },
            ),
            const SizedBox(height: 24),

            if (_loading)
              const Center(child: Padding(padding: EdgeInsets.only(top: 48), child: CircularProgressIndicator(strokeWidth: 2)))
            else if (_error != null)
              _buildError()
            else ...[
              // My tasks
              SectionHeader('My Tasks', count: _myTasks.length, countColor: AppColors.high),
              if (_myTasks.isEmpty)
                const EmptyState(message: 'All tasks delegated', icon: Icons.check_circle_outline)
              else
                ..._myTasks.map(_buildMyTaskCard),

              const SizedBox(height: 8),
              Divider(color: AppColors.border, height: 32),

              // Crew tasks
              SectionHeader('Crew Tasks', count: _crewTasks.length, countColor: AppColors.tl),
              if (_crewTasks.isEmpty)
                const EmptyState(message: 'No crew tasks yet')
              else
                ..._crewTasks.map(_buildCrewTaskCard),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildError() => Padding(
    padding: const EdgeInsets.only(top: 32),
    child: Column(children: [
      const EmptyState(message: '', icon: Icons.error_outline),
      Text(_error!, style: AppText.body(14, color: AppColors.urgent)),
      const SizedBox(height: 8),
      GhostButton(label: 'Retry', onPressed: _load),
    ]),
  );

  Widget _buildMyTaskCard(Task task) {
    final pc = _priorityColor(task.priority);
    return AppCard(
      accentColor: pc,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(child: Text(task.title, style: AppText.body(14, weight: FontWeight.w600))),
            StatusChip(_priorityLabel(task.priority), color: pc),
          ]),
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(task.description, style: AppText.body(12, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 10),
          GhostButton(
            label: 'Assign to Crew Member',
            icon: Icons.person_add_outlined,
            fullWidth: true,
            color: AppColors.tl,
            onPressed: () => _showAssignSheet(task),
          ),
        ],
      ),
    );
  }

  Widget _buildCrewTaskCard(Task task) {
    final (statusLabel, statusColor) = _statusStyle(task.status);
    return AppCard(
      accentColor: _priorityColor(task.priority),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.tl.withValues(alpha: 0.15),
            child: Text(
              _memberName(task.assignedTo).substring(0, 1),
              style: AppText.display(13, color: AppColors.tl, weight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title, style: AppText.body(14, weight: FontWeight.w600)),
                Text(_memberName(task.assignedTo), style: AppText.body(12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          StatusChip(statusLabel, color: statusColor),
        ],
      ),
    );
  }

  // ── Shared helpers ────────────────────────────────────────────────────────

  Widget _priorityChips(TaskPriority selected, void Function(TaskPriority) onSelect) {
    return Wrap(
      spacing: 8,
      children: TaskPriority.values.map((p) {
        final isSelected = selected == p;
        final color = _priorityColor(p);
        return GestureDetector(
          onTap: () => onSelect(p),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isSelected ? color : AppColors.border),
            ),
            child: Text(_priorityLabel(p), style: AppText.body(13, weight: isSelected ? FontWeight.w700 : FontWeight.w400, color: isSelected ? color : AppColors.textSecondary)),
          ),
        );
      }).toList(),
    );
  }

  Widget _memberRow(User user, User? selected, void Function(User?) onSelect) {
    final isSelected = selected?.id == user.id;
    return GestureDetector(
      onTap: () => onSelect(user),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.tl.withValues(alpha: 0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? AppColors.tl.withValues(alpha: 0.4) : AppColors.border),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.tl.withValues(alpha: 0.15),
              child: Text(user.name.substring(0, 1), style: AppText.display(14, color: AppColors.tl, weight: FontWeight.w700)),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(user.name, style: AppText.body(14, weight: FontWeight.w500))),
            if (isSelected)
              Container(
                width: 20, height: 20,
                decoration: const BoxDecoration(color: AppColors.tl, shape: BoxShape.circle),
                child: const Icon(Icons.check, size: 13, color: Colors.black),
              )
            else
              Container(width: 20, height: 20, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.border))),
          ],
        ),
      ),
    );
  }

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

  (String, Color) _statusStyle(TaskStatus s) => switch (s) {
    TaskStatus.inProgress => ('In Progress', AppColors.sm),
    TaskStatus.completed  => ('Done',        AppColors.tl),
    TaskStatus.verified   => ('QC Review',   AppColors.tl),
    TaskStatus.assigned   => ('Assigned',    AppColors.high),
    TaskStatus.unassigned => ('Pending',     AppColors.textMuted),
  };
}
