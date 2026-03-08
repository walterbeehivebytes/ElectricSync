import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../blueprints/blueprint_viewer.dart';
import '../tasks/work_order_creator.dart';
import '../tasks/crew_dispatch.dart';

class SiteManagerHome extends StatelessWidget {
  const SiteManagerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Site Operations',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Coordinate crews, materials, and daily approvals',
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
                      MaterialPageRoute(builder: (context) => const WorkOrderCreator()),
                    );
                  },
                  icon: const Icon(Icons.add_task),
                  label: const Text('Create Work Order'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
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
                      MaterialPageRoute(builder: (context) => const CrewDispatch()),
                    );
                  },
                  icon: const Icon(Icons.people),
                  label: const Text('Crew Dispatch'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
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
                  builder: (context) => const BlueprintViewer(userRole: UserRole.siteManager),
                ),
              );
            },
            icon: const Icon(Icons.architecture),
            label: const Text('View Blueprints - Add Task Pins'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
              minimumSize: const Size(double.infinity, 56),
            ),
          ),
          const SizedBox(height: 24),

          // Today's Site Summary
          const Text(
            "Today's Site Summary",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard('Crews\nOn-site', '3', Icons.groups, Colors.blue),
              const SizedBox(width: 8),
              _buildStatCard('Tasks\nActive', '12', Icons.assignment, Colors.amber),
              const SizedBox(width: 8),
              _buildStatCard('Blocked', '2', Icons.block, Colors.red),
              const SizedBox(width: 8),
              _buildStatCard('Done\nToday', '7', Icons.check_circle, Colors.green),
            ],
          ),
          const SizedBox(height: 24),

          // Pending Approvals
          const Text(
            'Pending Approvals',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildApprovalCard(
            'Material Delivery - Conduit order #4421',
            Icons.local_shipping,
            'Approve',
            Colors.blue,
          ),
          const SizedBox(height: 8),
          _buildApprovalCard(
            'Scope Change - Additional receptacles, Unit 3',
            Icons.change_circle,
            'Review',
            Colors.orange,
          ),
          const SizedBox(height: 24),

          // Crew Status by Team Lead
          const Text(
            'Crew Status by Team Lead',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildCrewCard('James Park', 4, 'Office Rewiring', Colors.green, 'Active'),
          const SizedBox(height: 8),
          _buildCrewCard('Carmen Ortiz', 3, 'Warehouse Project', Colors.green, 'Active'),
          const SizedBox(height: 8),
          _buildCrewCard('Tony Nguyen', 3, 'Hospital Project', Colors.orange, '1 blocked'),
          const SizedBox(height: 24),

          // Materials & Logistics
          const Text(
            'Materials & Logistics',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildLogisticsCard('Conduit delivery: ETA 2pm today', Icons.local_shipping, Colors.green),
          const SizedBox(height: 8),
          _buildLogisticsCard('Panel A: In staging, ready for install', Icons.inventory, Colors.blue),
          const SizedBox(height: 8),
          _buildLogisticsCard('Wire spools: Low stock - reorder needed', Icons.warning, Colors.orange),
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

  Widget _buildApprovalCard(String title, IconData icon, String actionLabel, Color actionColor) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: actionColor),
        title: Text(title, style: const TextStyle(fontSize: 14)),
        trailing: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: actionColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
          child: Text(actionLabel, style: const TextStyle(fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildCrewCard(String leadName, int members, String project, Color statusColor, String statusText) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: Icon(Icons.person, color: Colors.blue[700]),
        ),
        title: Text('$leadName (Team Lead)'),
        subtitle: Text('$members members · $project'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            statusText,
            style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildLogisticsCard(String message, IconData icon, Color color) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(message, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}
