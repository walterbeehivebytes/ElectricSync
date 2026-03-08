import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../blueprints/blueprint_viewer.dart';
import '../tasks/crew_dispatch.dart';
import '../tasks/qc_signoff.dart';

class TeamLeadHome extends StatelessWidget {
  const TeamLeadHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CrewDispatch()),
                    );
                  },
                  icon: const Icon(Icons.assignment),
                  label: const Text('Assign Tasks'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const QCSignoff()),
                    );
                  },
                  icon: const Icon(Icons.verified),
                  label: const Text('QC Sign-off'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BlueprintViewer(userRole: UserRole.teamLead),
                ),
              );
            },
            icon: const Icon(Icons.architecture),
            label: const Text('View Blueprints - Mark Redlines'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
          const SizedBox(height: 24),

          // My Crew Stats
          const Text(
            'My Crew',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard('On-site', '5', Icons.person, Colors.green),
              const SizedBox(width: 8),
              _buildStatCard('Assigned', '8', Icons.assignment, Colors.blue),
              const SizedBox(width: 8),
              _buildStatCard('Blocked', '1', Icons.block, Colors.red),
              const SizedBox(width: 8),
              _buildStatCard('Pending\nQC', '2', Icons.pending, Colors.orange),
            ],
          ),
          const SizedBox(height: 24),

          // Requires Attention
          const Text(
            'Requires Attention',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildBlockedItem(
            'Missing conduit for panel install',
            'Mike Johnson',
            'Warehouse Project',
          ),
          const SizedBox(height: 8),
          _buildBlockedItem(
            'Waiting for inspector approval',
            'Sarah Williams',
            'Office Rewiring',
          ),
          const SizedBox(height: 24),

          // Crew Members
          const Text(
            'Crew Members',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildCrewMember('Mike Johnson', 'Installing main panel', 'Warehouse', true),
          _buildCrewMember('Sarah Williams', 'Running conduit 3rd floor', 'Office Rewiring', false),
          _buildCrewMember('David Chen', 'Wire termination', 'Office Rewiring', false),
          _buildCrewMember('Lisa Rodriguez', 'Panel labeling', 'Hospital', false),
          _buildCrewMember('Tom Baker', 'Receptacle install', 'Warehouse', false),
          const SizedBox(height: 24),

          // Pending QC Review
          const Text(
            'Pending My QC Review',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildQCItem(context, 'Panel A installation', 'Mike Johnson', '2 hrs ago'),
          const SizedBox(height: 8),
          _buildQCItem(context, 'Junction box B4', 'David Chen', '4 hrs ago'),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
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

  Widget _buildBlockedItem(String issue, String memberName, String project) {
    return Card(
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.block, color: Colors.red[700], size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(issue, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(
                    '$memberName · $project',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: const Text('Resolve', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrewMember(String name, String task, String project, bool isBlocked) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isBlocked ? Colors.red[100] : Colors.green[100],
          child: Icon(
            Icons.person,
            color: isBlocked ? Colors.red[700] : Colors.green[700],
          ),
        ),
        title: Text(name),
        subtitle: Text('$task · $project', style: const TextStyle(fontSize: 12)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isBlocked ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isBlocked ? 'Blocked' : 'Active',
            style: TextStyle(
              fontSize: 12,
              color: isBlocked ? Colors.red[700] : Colors.green[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQCItem(BuildContext context, String taskName, String memberName, String timeAgo) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.pending, color: Colors.green[700]),
        title: Text(taskName),
        subtitle: Text('$memberName · $timeAgo', style: const TextStyle(fontSize: 12)),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const QCSignoff()),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: const Text('Review', style: TextStyle(fontSize: 12)),
        ),
      ),
    );
  }
}
