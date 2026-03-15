import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/project_service.dart';
import '../blueprints/blueprint_list.dart';
import '../tasks/work_order_creator.dart';

class ProjectManagerHome extends StatefulWidget {
  const ProjectManagerHome({super.key});

  @override
  State<ProjectManagerHome> createState() => _ProjectManagerHomeState();
}

class _ProjectManagerHomeState extends State<ProjectManagerHome> {
  final _projectService = ProjectService();
  List<ApiProject> _projects = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    try {
      final projects = await _projectService.getAllProjects();
      if (mounted) setState(() { _projects = projects; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _error = 'Could not load projects'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final active = _projects.where((p) => p.status == 'in_progress').length;
    final planning = _projects.where((p) => p.status == 'planning').length;
    final onHold = _projects.where((p) => p.status == 'on_hold').length;
    final done = _projects.where((p) => p.status == 'completed').length;

    return RefreshIndicator(
      onRefresh: _loadProjects,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Portfolio Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Real-time overview across all active projects', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 16),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const BlueprintList(userRole: UserRole.projectManager),
                      ));
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
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => const WorkOrderCreator(),
                      ));
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

            // Portfolio Health stats
            const Text('Portfolio Health', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            if (_loading)
              const Center(child: CircularProgressIndicator())
            else if (_error != null)
              _buildError()
            else ...[
              Row(
                children: [
                  _buildStatCard('Active', '$active', Icons.folder_open, Colors.purple),
                  const SizedBox(width: 8),
                  _buildStatCard('Planning', '$planning', Icons.edit_note, Colors.blue),
                  const SizedBox(width: 8),
                  _buildStatCard('On Hold', '$onHold', Icons.pause_circle, Colors.orange),
                  const SizedBox(width: 8),
                  _buildStatCard('Done', '$done', Icons.check_circle, Colors.green),
                ],
              ),
              const SizedBox(height: 24),

              // Active Projects list from API
              const Text('Active Projects', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (_projects.isEmpty)
                Text('No projects found', style: TextStyle(color: Colors.grey[500]))
              else
                ..._projects.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _buildProjectCard(p),
                )),
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

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600]), textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectCard(ApiProject project) {
    Color statusColor;
    switch (project.status) {
      case 'in_progress':
        statusColor = Colors.green;
        break;
      case 'on_hold':
        statusColor = Colors.orange;
        break;
      case 'planning':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.2),
          child: Icon(Icons.business, color: statusColor),
        ),
        title: Text(project.name),
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
                    project.statusDisplay,
                    style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600),
                  ),
                ),
                if (project.clientName != null) ...[
                  const SizedBox(width: 8),
                  Text(project.clientName!, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                ],
              ],
            ),
            const SizedBox(height: 2),
            Text(project.location, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
