import 'package:flutter/material.dart';
import '../../models/task.dart';

class CrewDispatch extends StatefulWidget {
  const CrewDispatch({super.key});

  @override
  State<CrewDispatch> createState() => _CrewDispatchState();
}

class _CrewDispatchState extends State<CrewDispatch> {
  // Mock data - in production this would come from state management/backend
  final List<Map<String, dynamic>> _unassignedTasks = [
    {
      'id': '1',
      'title': 'Install main panel',
      'location': 'Floor 2, Room 201',
      'priority': TaskPriority.high,
    },
    {
      'id': '2',
      'title': 'Run conduit - Conference rooms',
      'location': 'Floor 3, Rooms 301-305',
      'priority': TaskPriority.medium,
    },
    {
      'id': '3',
      'title': 'Wire termination',
      'location': 'Floor 1, Main lobby',
      'priority': TaskPriority.urgent,
    },
  ];

  final List<Map<String, dynamic>> _electricians = [
    {
      'id': 'e1',
      'name': 'Mike Johnson',
      'tasks': 2,
      'available': true,
    },
    {
      'id': 'e2',
      'name': 'Sarah Williams',
      'tasks': 1,
      'available': true,
    },
    {
      'id': 'e3',
      'name': 'David Chen',
      'tasks': 3,
      'available': false,
    },
    {
      'id': 'e4',
      'name': 'Lisa Rodriguez',
      'tasks': 0,
      'available': true,
    },
  ];

  void _assignTask(Map<String, dynamic> task, Map<String, dynamic> electrician) {
    setState(() {
      _unassignedTasks.remove(task);
      electrician['tasks']++;
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
            Text(
              'Assign: ${task['title']}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Electrician:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            ..._electricians.map((electrician) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: electrician['available']
                      ? Colors.green[100]
                      : Colors.grey[300],
                  child: Icon(
                    Icons.person,
                    color: electrician['available']
                        ? Colors.green[700]
                        : Colors.grey[600],
                  ),
                ),
                title: Text(electrician['name']),
                subtitle: Text(
                  '${electrician['tasks']} active tasks • ${electrician['available'] ? 'Available' : 'Busy'}',
                ),
                trailing: electrician['available']
                    ? const Icon(Icons.arrow_forward, color: Colors.green)
                    : null,
                enabled: electrician['available'],
                onTap: electrician['available']
                    ? () {
                        Navigator.pop(context);
                        _assignTask(task, electrician);
                      }
                    : null,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return Colors.grey;
      case TaskPriority.medium:
        return Colors.blue;
      case TaskPriority.high:
        return Colors.orange;
      case TaskPriority.urgent:
        return Colors.red;
    }
  }

  String _getPriorityLabel(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.low:
        return 'Low';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.high:
        return 'High';
      case TaskPriority.urgent:
        return 'Urgent';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crew Dispatch'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Use tabs for narrow screens (mobile), side-by-side for wide screens
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
                      Tab(
                        icon: const Icon(Icons.inbox),
                        text: 'Unassigned (${_unassignedTasks.length})',
                      ),
                      const Tab(
                        icon: Icon(Icons.groups),
                        text: 'Team Members',
                      ),
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
                Expanded(
                  flex: 3,
                  child: _buildUnassignedTasksList(),
                ),
                Expanded(
                  flex: 2,
                  child: _buildElectriciansList(),
                ),
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
                border: Border(
                  right: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.inbox, color: Colors.orange),
                        const SizedBox(width: 12),
                        const Text(
                          'Unassigned Tasks',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_unassignedTasks.length}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[900],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _unassignedTasks.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 64,
                                  color: Colors.green,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'All tasks assigned!',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
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
                                    child: Icon(
                                      Icons.assignment,
                                      color: _getPriorityColor(priority),
                                    ),
                                  ),
                                  title: Text(
                                    task['title'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(task['location']),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getPriorityColor(priority).withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          _getPriorityLabel(priority),
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: _getPriorityColor(priority),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: ElevatedButton(
                                    onPressed: () => _showAssignDialog(task),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber[700],
                                      foregroundColor: Colors.white,
                                    ),
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

  Widget _buildElectriciansList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: const Row(
            children: [
              Icon(Icons.groups, color: Colors.blue),
              SizedBox(width: 12),
              Text(
                'Team Members',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                color: electrician['available']
                    ? Colors.white
                    : Colors.grey[100],
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: electrician['available']
                        ? Colors.green[100]
                        : Colors.grey[300],
                    child: Icon(
                      Icons.person,
                      color: electrician['available']
                          ? Colors.green[700]
                          : Colors.grey[600],
                    ),
                  ),
                  title: Text(
                    electrician['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${electrician['tasks']} active tasks',
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: electrician['available']
                          ? Colors.green[100]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      electrician['available'] ? 'Available' : 'Busy',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: electrician['available']
                            ? Colors.green[700]
                            : Colors.grey[700],
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
