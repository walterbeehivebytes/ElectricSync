import 'package:flutter/material.dart';
import '../../models/user.dart';
import 'blueprint_viewer.dart';

class BlueprintList extends StatefulWidget {
  final UserRole userRole;

  const BlueprintList({super.key, required this.userRole});

  @override
  State<BlueprintList> createState() => _BlueprintListState();
}

class _BlueprintListState extends State<BlueprintList> {
  final List<Map<String, dynamic>> _blueprints = [
    {
      'id': 'bp1',
      'name': 'Floor 2 - Electrical Layout',
      'area': 'Office Building Rewiring',
      'floor': 'Floor 2',
      'uploadDate': 'Mar 1, 2026',
      'pinCount': 4,
      'status': 'Active',
    },
    {
      'id': 'bp2',
      'name': 'Warehouse - Main Distribution',
      'area': 'Warehouse Lighting Upgrade',
      'floor': 'Ground Floor',
      'uploadDate': 'Feb 20, 2026',
      'pinCount': 7,
      'status': 'Active',
    },
    {
      'id': 'bp3',
      'name': 'Hospital - Emergency Power',
      'area': 'Hospital Emergency Power',
      'floor': 'Basement & Floor 1',
      'uploadDate': 'Jan 15, 2026',
      'pinCount': 12,
      'status': 'Active',
    },
  ];

  void _showAddBlueprintDialog() {
    final nameController = TextEditingController();
    final areaController = TextEditingController();
    final floorController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.architecture, color: Colors.purple),
            SizedBox(width: 12),
            Text('Add Blueprint'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Blueprint Name',
                border: OutlineInputBorder(),
                hintText: 'e.g., Floor 3 - Electrical Layout',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: areaController,
              decoration: const InputDecoration(
                labelText: 'Project / Area',
                border: OutlineInputBorder(),
                hintText: 'e.g., Office Building Rewiring',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: floorController,
              decoration: const InputDecoration(
                labelText: 'Floor / Zone',
                border: OutlineInputBorder(),
                hintText: 'e.g., Floor 3',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  _blueprints.add({
                    'id': 'bp${_blueprints.length + 1}',
                    'name': nameController.text,
                    'area': areaController.text.isNotEmpty
                        ? areaController.text
                        : 'Unassigned',
                    'floor': floorController.text.isNotEmpty
                        ? floorController.text
                        : 'TBD',
                    'uploadDate': 'Mar 5, 2026',
                    'pinCount': 0,
                    'status': 'Active',
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Blueprint added successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[700],
              foregroundColor: Colors.white,
            ),
            child: const Text('Add Blueprint'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Blueprints'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddBlueprintDialog,
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Blueprint'),
      ),
      body: Column(
        children: [
          // Header banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.purple[50],
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.purple[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Open a blueprint to define tasks by tapping on the floor plan.',
                    style: TextStyle(color: Colors.purple[900]),
                  ),
                ),
              ],
            ),
          ),

          // Blueprint list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _blueprints.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final bp = _blueprints[index];
                return _buildBlueprintCard(bp);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlueprintCard(Map<String, dynamic> bp) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.architecture, color: Colors.purple[700], size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        bp['name'] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        bp['area'] as String,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    bp['status'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.layers, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Text(
                  bp['floor'] as String,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.push_pin, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Text(
                  '${bp['pinCount']} task pins',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 6),
                Text(
                  bp['uploadDate'] as String,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlueprintViewer(
                        userRole: widget.userRole,
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open & Define Tasks'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
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
}
