import 'package:flutter/material.dart';
import '../../models/auth_user.dart';
import '../../models/task.dart';
import '../../models/user.dart';
import '../../services/task_service.dart';
import '../../services/user_service.dart';
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
          _tasks = results[0] as List<Task>;
          _teamMembers = results[1] as List<User>;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Could not load data'; _loading = false; });
    }
  }

  /// Tasks still assigned to the TL (not yet delegated to crew)
  List<Task> get _myTasks =>
      _tasks.where((t) => t.assignedTo == widget.currentUser.id).toList();

  /// Tasks delegated to a team member
  List<Task> get _crewTasks =>
      _tasks.where((t) => t.assignedTo != widget.currentUser.id).toList();

  String _memberName(String? memberId) {
    if (memberId == null) return 'Unassigned';
    final member = _teamMembers.firstWhere(
      (u) => u.id == memberId,
      orElse: () => User(id: memberId, name: memberId, role: UserRole.teamMember),
    );
    return member.name;
  }

  Future<void> _showAssignSheet(Task task) async {
    User? selectedMember;
    TaskPriority selectedPriority = task.priority;
    final descController = TextEditingController(text: task.description);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.fromLTRB(
            16, 16, 16, MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Additional Details / Instructions',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Confirm Priority', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: TaskPriority.values.map((p) {
                  final isSelected = selectedPriority == p;
                  final (color, label) = switch (p) {
                    TaskPriority.low    => (Colors.grey,   'Low'),
                    TaskPriority.medium => (Colors.blue,   'Medium'),
                    TaskPriority.high   => (Colors.orange, 'High'),
                    TaskPriority.urgent => (Colors.red,    'Urgent'),
                  };
                  return ChoiceChip(
                    label: Text(label),
                    selected: isSelected,
                    selectedColor: color,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                    onSelected: (_) => setModal(() => selectedPriority = p),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              const Text('Assign to Team Member', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              ..._teamMembers.map((member) => RadioListTile<User>(
                value: member,
                groupValue: selectedMember,
                title: Text(member.name),
                onChanged: (v) => setModal(() => selectedMember = v),
              )),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedMember == null
                      ? null
                      : () async {
                          Navigator.pop(ctx);
                          await _assignToMember(
                            task, selectedMember!, descController.text.trim(), selectedPriority,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Assign to Crew Member'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    descController.dispose();
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
          SnackBar(content: Text('Assigned to ${member.name}'), backgroundColor: Colors.green),
        );
        _load();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Assignment failed'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Crew Status Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Manage your crew and resolve blockers',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QCSignoff(currentUser: widget.currentUser),
                      ),
                    ),
                    icon: const Icon(Icons.verified),
                    label: const Text('QC Sign-off'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const BlueprintViewer(userRole: UserRole.teamLead),
                      ),
                    ),
                    icon: const Icon(Icons.architecture),
                    label: const Text('Blueprints'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WorkOrderCreator(currentUser: widget.currentUser),
                  ),
                );
                _load();
              },
              icon: const Icon(Icons.add_task),
              label: const Text('Create Task'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
            const SizedBox(height: 24),

            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              Center(
                child: Column(
                  children: [
                    Text(_error!, style: const TextStyle(color: Colors.red)),
                    TextButton(onPressed: _load, child: const Text('Retry')),
                  ],
                ),
              )
            else ...[
              // My tasks (not yet delegated)
              Row(
                children: [
                  const Text(
                    'My Tasks',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  if (_myTasks.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_myTasks.length}',
                        style: TextStyle(
                          color: Colors.orange[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (_myTasks.isEmpty)
                Card(
                  child: ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green[700]),
                    title: const Text('All tasks delegated to crew'),
                  ),
                )
              else
                ..._myTasks.map((task) => _buildMyTaskCard(task)),

              const SizedBox(height: 24),

              // Crew tasks (delegated to TMs)
              Row(
                children: [
                  const Text(
                    'Crew Tasks',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  if (_crewTasks.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_crewTasks.length}',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (_crewTasks.isEmpty)
                Card(
                  child: ListTile(
                    leading: Icon(Icons.info_outline, color: Colors.grey[600]),
                    title: const Text('No tasks assigned to crew yet'),
                  ),
                )
              else
                ..._crewTasks.map((task) => _buildCrewTaskCard(task)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMyTaskCard(Task task) {
    final (priorityLabel, priorityColor) = _priorityStyle(task.priority);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    task.title,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    priorityLabel,
                    style: TextStyle(fontSize: 11, color: priorityColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                task.description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _showAssignSheet(task),
                icon: const Icon(Icons.person_add, size: 16),
                label: const Text('Assign to Team Member'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue[800],
                  side: BorderSide(color: Colors.blue[700]!),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrewTaskCard(Task task) {
    final (statusLabel, statusColor) = _statusStyle(task.status);
    final (priorityLabel, priorityColor) = _priorityStyle(task.priority);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Icon(Icons.person, color: Colors.green[700]),
        ),
        title: Text(task.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(
          'Assigned to: ${_memberName(task.assignedTo)}',
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: priorityColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                priorityLabel,
                style: TextStyle(fontSize: 10, color: priorityColor, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  (String, Color) _statusStyle(TaskStatus s) => switch (s) {
    TaskStatus.inProgress => ('In Progress', Colors.blue),
    TaskStatus.completed  => ('Completed',   Colors.green),
    TaskStatus.verified   => ('Needs QC',    Colors.teal),
    TaskStatus.assigned   => ('Assigned',    Colors.orange),
    TaskStatus.unassigned => ('Unassigned',  Colors.grey),
  };

  (String, Color) _priorityStyle(TaskPriority p) => switch (p) {
    TaskPriority.urgent => ('Urgent', Colors.red),
    TaskPriority.high   => ('High',   Colors.orange),
    TaskPriority.medium => ('Medium', Colors.blue),
    TaskPriority.low    => ('Low',    Colors.grey),
  };
}
