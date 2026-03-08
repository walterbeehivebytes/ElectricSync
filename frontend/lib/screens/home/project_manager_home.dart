import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../blueprints/blueprint_list.dart';
import '../tasks/work_order_creator.dart';

class ProjectManagerHome extends StatelessWidget {
  const ProjectManagerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Portfolio Dashboard',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Real-time overview across all active projects',
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
                      MaterialPageRoute(
                        builder: (context) => const BlueprintList(
                          userRole: UserRole.projectManager,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.architecture),
                  label: const Text('Manage Blueprints'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[700],
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
                      MaterialPageRoute(
                        builder: (context) => const WorkOrderCreator(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_task),
                  label: const Text('Define Tasks'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Portfolio Health
          const Text(
            'Portfolio Health',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard('Active', '4', Icons.folder_open, Colors.purple),
              const SizedBox(width: 8),
              _buildStatCard('On Track', '2', Icons.check_circle, Colors.green),
              const SizedBox(width: 8),
              _buildStatCard('At Risk', '1', Icons.warning, Colors.orange),
              const SizedBox(width: 8),
              _buildStatCard('Behind', '1', Icons.cancel, Colors.red),
            ],
          ),
          const SizedBox(height: 24),

          // Budget vs Actual
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.account_balance, color: Colors.purple[700], size: 32),
                      const SizedBox(width: 12),
                      const Text(
                        'Budget vs Actual',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildBudgetBar('Company-wide Labor', 734, 1200, Colors.blue),
                  const SizedBox(height: 12),
                  _buildBudgetBar('Company-wide Budget (\$k)', 287, 450, Colors.green),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Active Projects
          const Text(
            'Active Projects',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildProjectCard('Office Building Rewiring', 'On Track', Colors.green, 78, 'Phase: Rough-in / 3 phases', Icons.business),
          const SizedBox(height: 8),
          _buildProjectCard('Warehouse Lighting Upgrade', 'At Risk', Colors.orange, 45, 'Phase: Installation / 2 phases', Icons.warehouse),
          const SizedBox(height: 8),
          _buildProjectCard('Hospital Emergency Power', 'Behind Schedule', Colors.red, 92, 'Phase: Inspection / 3 phases', Icons.local_hospital),
          const SizedBox(height: 8),
          _buildProjectCard('Retail Strip Mall', 'On Track', Colors.green, 31, 'Phase: Rough-in / 2 phases', Icons.store),
          const SizedBox(height: 24),

          // Open Issues
          const Text(
            'Open Issues Requiring Escalation',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildIssueCard('Warehouse: Conduit materials delayed 3 days', Icons.inventory_2),
          const SizedBox(height: 8),
          _buildIssueCard('Hospital: Inspection hold, awaiting GC sign-off', Icons.pending_actions),
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

  Widget _buildBudgetBar(String label, double used, double total, Color color) {
    final percentage = (used / total * 100).toInt();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            Text('$used / $total', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: used / total,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
        const SizedBox(height: 4),
        Text('$percentage% utilized', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildProjectCard(String title, String status, Color statusColor, int progress, String phase, IconData icon) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.2),
          child: Icon(icon, color: statusColor),
        ),
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 8),
                Text('$progress%', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 2),
            Text(phase, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }

  Widget _buildIssueCard(String message, IconData icon) {
    return Card(
      color: Colors.red[50],
      child: ListTile(
        leading: Icon(icon, color: Colors.red[700]),
        title: Text(message, style: TextStyle(fontSize: 14, color: Colors.red[900])),
      ),
    );
  }
}
