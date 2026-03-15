import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../models/user.dart';
import '../../services/task_service.dart';
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
    try {
      final tasks = await _taskService.getMyTasks();
      if (mounted) setState(() { _tasks = tasks; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Could not load tasks'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final current = _tasks.where((t) => t.status == TaskStatus.inProgress).toList();
    final upcoming = _tasks.where((t) => t.status == TaskStatus.assigned || t.status == TaskStatus.unassigned).toList();
    final completed = _tasks.where((t) => t.status == TaskStatus.completed).toList();

    return RefreshIndicator(
      onRefresh: _loadTasks,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('My Workspace', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('What am I doing right now?', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 16),

            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              _buildError()
            else ...[
              // Current Task
              if (current.isNotEmpty)
                _buildCurrentTaskCard(current.first)
              else
                _buildNoCurrentTask(),
              const SizedBox(height: 12),

              // Blueprint button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => const BlueprintViewer(userRole: UserRole.teamMember),
                  ));
                },
                icon: const Icon(Icons.map),
                label: const Text('View Blueprint - See Task Locations'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(16),
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
              const SizedBox(height: 24),

              // Up Next
              Text('Up Next (${upcoming.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (upcoming.isEmpty)
                Text('No upcoming tasks', style: TextStyle(color: Colors.grey[500]))
              else
                ...upcoming.map((t) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildTaskCard(t),
                )),
              const SizedBox(height: 24),

              // Completed
              Text('Completed (${completed.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (completed.isEmpty)
                Text('Nothing completed yet', style: TextStyle(color: Colors.grey[500]))
              else
                ...completed.map((t) => _buildCompletedTask(t)),
              const SizedBox(height: 24),

              // Stats
              const Text('My Stats', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildStatCard('Tasks\nDone', '${completed.length}', Icons.check_circle, Colors.green),
                  const SizedBox(width: 8),
                  _buildStatCard('In\nProgress', '${current.length}', Icons.timer, Colors.blue),
                  const SizedBox(width: 8),
                  _buildStatCard('Up\nNext', '${upcoming.length}', Icons.assignment, Colors.orange),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Card(
      color: Colors.red[50],
      child: ListTile(
        leading: Icon(Icons.error_outline, color: Colors.red[700]),
        title: Text(_error!, style: TextStyle(color: Colors.red[900])),
        subtitle: const Text('Pull down to retry'),
      ),
    );
  }

  Widget _buildCurrentTaskCard(Task task) {
    return Card(
      color: Colors.amber[50],
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.play_circle, color: Colors.amber[700], size: 28),
                const SizedBox(width: 12),
                const Text('Current Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(task.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(task.description, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const TaskDetailView()));
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open Task'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoCurrentTask() {
    return Card(
      color: Colors.grey[50],
      child: const ListTile(
        leading: Icon(Icons.check_circle_outline, color: Colors.green),
        title: Text('No task in progress'),
        subtitle: Text('Pick one from Up Next below'),
      ),
    );
  }

  Widget _buildTaskCard(Task task) {
    final color = _priorityColor(task.priority);
    final label = _priorityLabel(task.priority);
    return Card(
      child: ListTile(
        leading: Icon(Icons.assignment, color: Colors.blue[700]),
        title: Text(task.title),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildCompletedTask(Task task) {
    return ListTile(
      dense: true,
      leading: Icon(Icons.check_circle, color: Colors.green[700], size: 20),
      title: Text(task.title, style: const TextStyle(fontSize: 14)),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600]), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Color _priorityColor(TaskPriority p) {
    switch (p) {
      case TaskPriority.urgent: return Colors.red[900]!;
      case TaskPriority.high: return Colors.red;
      case TaskPriority.medium: return Colors.orange;
      case TaskPriority.low: return Colors.green;
    }
  }

  String _priorityLabel(TaskPriority p) {
    switch (p) {
      case TaskPriority.urgent: return 'Urgent';
      case TaskPriority.high: return 'High';
      case TaskPriority.medium: return 'Medium';
      case TaskPriority.low: return 'Low';
    }
  }
}
