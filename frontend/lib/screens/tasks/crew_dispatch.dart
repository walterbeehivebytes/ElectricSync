import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/api_service.dart';

class CrewDispatch extends StatefulWidget {
  const CrewDispatch({super.key});

  @override
  State<CrewDispatch> createState() => _CrewDispatchState();
}

class _CrewDispatchState extends State<CrewDispatch> {
  final _api = ApiService();

  final List<Map<String, dynamic>> _unassignedTasks = [
    {'id': 'task_001', 'title': 'Install main panel', 'location': 'Floor 2, Room 201', 'priority': TaskPriority.high},
    {'id': 'task_002', 'title': 'Run conduit - Conference rooms', 'location': 'Floor 3, Rooms 301-305', 'priority': TaskPriority.medium},
    {'id': 'task_003', 'title': 'Wire termination', 'location': 'Floor 1, Main lobby', 'priority': TaskPriority.urgent},
  ];

  final List<Map<String, dynamic>> _electricians = [
    {'id': 'user_003', 'name': 'Carmen Ortiz', 'tasks': 2, 'available': true},
    {'id': 'user_004', 'name': 'Mike Rodriguez', 'tasks': 1, 'available': true},
    {'id': 'e3', 'name': 'David Chen', 'tasks': 3, 'available': false},
    {'id': 'e4', 'name': 'Lisa Rodriguez', 'tasks': 0, 'available': true},
  ];

  bool _aiLoading = false;
  List<Map<String, dynamic>>? _aiAssignments;
  String? _aiSummary;

  Future<void> _getAIRecommendations() async {
    if (_unassignedTasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No unassigned tasks to dispatch'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() { _aiLoading = true; _aiAssignments = null; _aiSummary = null; });
    try {
      final tasks = _unassignedTasks.map((t) => {
        'id': t['id'],
        'title': t['title'],
        'location': t['location'],
        'priority': _getPriorityLabel(t['priority'] as TaskPriority).toLowerCase(),
      }).toList();
      final crew = _electricians.where((e) => e['available'] == true).map((e) => {
        'id': e['id'],
        'name': e['name'],
        'role': 'team_member',
        'active_tasks': e['tasks'],
      }).toList();

      final result = await _api.post('/api/ai/dispatch-recommend', {'tasks': tasks, 'crew': crew});
      final assignments = (result['assignments'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();
      setState(() {
        _aiAssignments = assignments;
        _aiSummary = result['summary'] as String?;
        _aiLoading = false;
      });
    } on ApiException catch (e) {
      setState(() => _aiLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (_) {
      setState(() => _aiLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('AI unavailable — assign manually below'), backgroundColor: Colors.orange),
        );
      }
    }
  }

  void _acceptAIAssignment(Map<String, dynamic> assignment) {
    final taskId = assignment['task_id'] as String?;
    final crewId = assignment['recommended_user_id'] as String?;
    final taskIndex = _unassignedTasks.indexWhere((t) => t['id'] == taskId);
    final crewIndex = _electricians.indexWhere((e) => e['id'] == crewId);
    if (taskIndex == -1) return;

    final taskTitle = _unassignedTasks[taskIndex]['title'];
    final crewName = crewIndex != -1 ? _electricians[crewIndex]['name'] : assignment['recommended_user_name'];

    setState(() {
      _unassignedTasks.removeAt(taskIndex);
      if (crewIndex != -1) _electricians[crewIndex]['tasks']++;
      _aiAssignments?.remove(assignment);
      if (_aiAssignments?.isEmpty ?? false) _aiAssignments = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Assigned "$taskTitle" to $crewName'), backgroundColor: Colors.green, duration: const Duration(seconds: 2)),
    );
  }

  void _assignTask(Map<String, dynamic> task, Map<String, dynamic> electrician) {
    setState(() {
      _unassignedTasks.remove(task);
      electrician['tasks']++;
      _aiAssignments?.removeWhere((a) => a['task_id'] == task['id']);
      if (_aiAssignments?.isEmpty ?? false) _aiAssignments = null;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Assigned "${task['title']}" to ${electrician['name']}'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAssignDialog(Map<String, dynamic> task) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Assign: ${task['title']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Select Electrician:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 12),
            ..._electricians.map((electrician) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: electrician['available'] ? Colors.green[100] : Colors.grey[300],
                  child: Icon(Icons.person, color: electrician['available'] ? Colors.green[700] : Colors.grey[600]),
                ),
                title: Text(electrician['name']),
                subtitle: Text('${electrician['tasks']} active tasks • ${electrician['available'] ? 'Available' : 'Busy'}'),
                trailing: electrician['available'] ? const Icon(Icons.arrow_forward, color: Colors.green) : null,
                enabled: electrician['available'],
                onTap: electrician['available']
                    ? () { Navigator.pop(context); _assignTask(task, electrician); }
                    : null,
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low: return Colors.grey;
      case TaskPriority.medium: return Colors.blue;
      case TaskPriority.high: return Colors.orange;
      case TaskPriority.urgent: return Colors.red;
    }
  }

  String _getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low: return 'Low';
      case TaskPriority.medium: return 'Medium';
      case TaskPriority.high: return 'High';
      case TaskPriority.urgent: return 'Urgent';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crew Dispatch')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 600;
          if (isNarrow) {
            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    labelColor: Colors.amber[700],
                    indicatorColor: Colors.amber[700],
                    tabs: [
                      Tab(icon: const Icon(Icons.inbox), text: 'Unassigned (${_unassignedTasks.length})'),
                      const Tab(icon: Icon(Icons.groups), text: 'Team Members'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildUnassignedTasksList(),
                        _buildElectriciansList(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Row(
              children: [
                Expanded(flex: 3, child: _buildUnassignedTasksList()),
                Expanded(flex: 2, child: _buildElectriciansList()),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildUnassignedTasksList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        border: Border(right: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── AI Dispatch Panel ──────────────────────────────────────────
          _buildAIPanel(),

          // ── Header ────────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                const Icon(Icons.inbox, color: Colors.orange),
                const SizedBox(width: 12),
                const Text('Unassigned Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.orange[100], borderRadius: BorderRadius.circular(12)),
                  child: Text('${_unassignedTasks.length}',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[900])),
                ),
              ],
            ),
          ),

          // ── Task List ─────────────────────────────────────────────────
          Expanded(
            child: _unassignedTasks.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                        SizedBox(height: 16),
                        Text('All tasks assigned!', style: TextStyle(fontSize: 18, color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _unassignedTasks.length,
                    itemBuilder: (context, index) {
                      final task = _unassignedTasks[index];
                      final priority = task['priority'] as TaskPriority;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _getPriorityColor(priority).withValues(alpha: 0.2),
                            child: Icon(Icons.assignment, color: _getPriorityColor(priority)),
                          ),
                          title: Text(task['title'], style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(children: [
                                Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(task['location']),
                              ]),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(priority).withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(_getPriorityLabel(priority),
                                    style: TextStyle(fontSize: 11, color: _getPriorityColor(priority), fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => _showAssignDialog(task),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700], foregroundColor: Colors.white),
                            child: const Text('Assign'),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIPanel() {
    return Card(
      margin: const EdgeInsets.all(12),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.blue[800], size: 20),
                const SizedBox(width: 8),
                Text('AI Dispatch Assistant',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue[900])),
              ],
            ),
            const SizedBox(height: 6),
            Text('Claude analyzes task priorities and crew availability to recommend optimal assignments.',
                style: TextStyle(fontSize: 13, color: Colors.blue[800])),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _aiLoading ? null : _getAIRecommendations,
                icon: _aiLoading
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.auto_awesome),
                label: Text(_aiLoading ? 'Analyzing crew…' : 'Get AI Recommendations'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[700],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (_aiSummary != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(8)),
                child: Text(_aiSummary!, style: TextStyle(fontSize: 13, color: Colors.blue[900])),
              ),
            ],
            if (_aiAssignments != null && _aiAssignments!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green[700], size: 18),
                  const SizedBox(width: 6),
                  Text('${_aiAssignments!.length} recommendations — tap Accept to apply',
                      style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600, fontSize: 13)),
                ],
              ),
              const SizedBox(height: 8),
              ..._aiAssignments!.map((a) => _buildAIAssignmentCard(a)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAIAssignmentCard(Map<String, dynamic> assignment) {
    final taskTitle = assignment['task_title'] as String? ?? assignment['task_id'] as String? ?? '?';
    final crewName = assignment['recommended_user_name'] as String? ?? assignment['recommended_user_id'] as String? ?? '?';
    final reasoning = assignment['reasoning'] as String? ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                    children: [
                      TextSpan(text: taskTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const TextSpan(text: '  →  '),
                      TextSpan(text: crewName, style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _acceptAIAssignment(assignment),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.green[50],
                  foregroundColor: Colors.green[800],
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                child: const Text('Accept', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (reasoning.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(reasoning, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ],
      ),
    );
  }

  Widget _buildElectriciansList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: const Row(
            children: [
              Icon(Icons.groups, color: Colors.blue),
              SizedBox(width: 12),
              Text('Team Members', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _electricians.length,
            itemBuilder: (context, index) {
              final electrician = _electricians[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: electrician['available'] ? Colors.white : Colors.grey[100],
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: electrician['available'] ? Colors.green[100] : Colors.grey[300],
                    child: Icon(Icons.person,
                        color: electrician['available'] ? Colors.green[700] : Colors.grey[600]),
                  ),
                  title: Text(electrician['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('${electrician['tasks']} active tasks'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: electrician['available'] ? Colors.green[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      electrician['available'] ? 'Available' : 'Busy',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: electrician['available'] ? Colors.green[700] : Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
