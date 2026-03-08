import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../models/user.dart';
import '../blueprints/blueprint_viewer.dart';
import '../tasks/task_detail_view.dart';

class TeamMemberHome extends StatelessWidget {
  const TeamMemberHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'My Workspace',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'What am I doing right now?',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // Current Task Card
          Card(
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
                      const Text(
                        'Current Task',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Install main electrical panel',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Office Building Rewiring · Floor 2',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TaskDetailView()),
                        );
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
          ),
          const SizedBox(height: 12),

          // Blueprint button
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BlueprintViewer(userRole: UserRole.teamMember),
                ),
              );
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
          const Text(
            'Up Next',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildTaskCard('Wire termination - Panel A', TaskPriority.high),
          const SizedBox(height: 8),
          _buildTaskCard('Install receptacles - Conference room', TaskPriority.medium),
          const SizedBox(height: 24),

          // Completed Today
          const Text(
            'Completed Today',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildCompletedTask('Run conduit - Floor 2', '2 hours ago'),
          _buildCompletedTask('Rough-in inspection prep', '4 hours ago'),
          const SizedBox(height: 24),

          // My Stats This Week
          const Text(
            'My Stats This Week',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard('Tasks\nDone', '7', Icons.check_circle, Colors.green),
              const SizedBox(width: 8),
              _buildStatCard('Hours\nLogged', '38', Icons.timer, Colors.blue),
              const SizedBox(width: 8),
              _buildStatCard('Help\nRequests', '1', Icons.help, Colors.orange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(String title, TaskPriority priority) {
    Color priorityColor;
    String priorityLabel;
    switch (priority) {
      case TaskPriority.high:
        priorityColor = Colors.red;
        priorityLabel = 'High';
      case TaskPriority.medium:
        priorityColor = Colors.orange;
        priorityLabel = 'Medium';
      case TaskPriority.low:
        priorityColor = Colors.green;
        priorityLabel = 'Low';
      case TaskPriority.urgent:
        priorityColor = Colors.red[900]!;
        priorityLabel = 'Urgent';
    }

    return Card(
      child: ListTile(
        leading: Icon(Icons.assignment, color: Colors.blue[700]),
        title: Text(title),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: priorityColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            priorityLabel,
            style: TextStyle(
              fontSize: 12,
              color: priorityColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildCompletedTask(String title, String timeAgo) {
    return ListTile(
      dense: true,
      leading: Icon(Icons.check_circle, color: Colors.green[700], size: 20),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: Text(timeAgo, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
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
              Text(
                value,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
              ),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

