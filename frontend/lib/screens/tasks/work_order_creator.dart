import 'package:flutter/material.dart';
import '../../models/auth_user.dart';
import '../../models/task.dart';
import '../../models/user.dart';
import '../../services/api_service.dart';

class WorkOrderCreator extends StatefulWidget {
  final AuthUser? currentUser;
  const WorkOrderCreator({super.key, this.currentUser});

  @override
  State<WorkOrderCreator> createState() => _WorkOrderCreatorState();
}

class _WorkOrderCreatorState extends State<WorkOrderCreator> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _floorController = TextEditingController();
  final _roomController = TextEditingController();
  final _aiInputController = TextEditingController();
  final _api = ApiService();

  String _selectedProject = 'Office Building Rewiring';
  TaskPriority _selectedPriority = TaskPriority.medium;
  final List<String> _selectedMaterialKits = [];
  bool _aiLoading = false;
  bool _saving = false;
  Map<String, dynamic>? _aiResult;

  static const _projectIds = {
    'Office Building Rewiring': 'proj_001',
    'Warehouse Lighting Upgrade': 'proj_002',
    'Hospital Emergency Power': 'proj_003',
  };

  final List<String> _availableProjects = [
    'Office Building Rewiring',
    'Warehouse Lighting Upgrade',
    'Hospital Emergency Power',
  ];

  final List<String> _availableMaterialKits = [
    'Electrical Panel Kit',
    'Conduit & Fittings',
    'Wire Spools (12/2, 14/2)',
    'Receptacle & Switch Kit',
    'Lighting Fixtures',
    'Junction Boxes',
    'Cable Management',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _floorController.dispose();
    _roomController.dispose();
    _aiInputController.dispose();
    super.dispose();
  }

  Future<void> _generateWithAI() async {
    final input = _aiInputController.text.trim();
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Describe the work first'), backgroundColor: Colors.orange),
      );
      return;
    }
    setState(() { _aiLoading = true; _aiResult = null; });
    try {
      final result = await _api.post('/api/ai/generate-work-order', {'description': input});
      setState(() { _aiResult = result; _aiLoading = false; });
      _applyAIResult(result);
    } on ApiException catch (e) {
      setState(() => _aiLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() => _aiLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('AI unavailable — fill the form manually'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _applyAIResult(Map<String, dynamic> result) {
    _titleController.text = result['title'] as String? ?? '';
    final priority = result['overall_priority'] as String? ?? 'medium';
    _selectedPriority = _priorityFromString(priority);

    // Pre-fill description from first task if form description is empty
    final tasks = result['tasks'] as List<dynamic>? ?? [];
    if (tasks.isNotEmpty && _descriptionController.text.isEmpty) {
      final first = tasks.first as Map<String, dynamic>;
      _descriptionController.text = first['description'] as String? ?? '';
    }

    // Pre-fill materials from all tasks combined
    final allMaterials = <String>[];
    for (final task in tasks) {
      final mats = (task as Map<String, dynamic>)['materials'] as List<dynamic>? ?? [];
      allMaterials.addAll(mats.cast<String>());
    }
    // Match against available kits
    final matched = _availableMaterialKits.where((kit) {
      return allMaterials.any((m) => m.toLowerCase().contains(kit.split(' ').first.toLowerCase()));
    }).toList();
    setState(() => _selectedMaterialKits
      ..clear()
      ..addAll(matched));
  }

  TaskPriority _priorityFromString(String s) {
    switch (s) {
      case 'urgent': return TaskPriority.urgent;
      case 'high': return TaskPriority.high;
      case 'low': return TaskPriority.low;
      default: return TaskPriority.medium;
    }
  }

  Future<void> _createWorkOrder() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final location = '${_floorController.text.trim()}, ${_roomController.text.trim()}';
      final description = _descriptionController.text.trim();
      await _api.post('/api/tasks/', {
        'project_id': _projectIds[_selectedProject] ?? 'proj_001',
        'title': _titleController.text.trim(),
        'description': '$location: $description',
        'priority': _selectedPriority.name,
        'materials_needed': _selectedMaterialKits,
        // TL-created tasks auto-route to their own My Tasks via the backend,
        // but we also send team_lead_id so the frontend filter works immediately.
        if (widget.currentUser?.role == UserRole.teamLead)
          'team_lead_id': widget.currentUser!.id,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Work order created!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Work Order')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [

            // ── AI Generator ──────────────────────────────────────────────
            Card(
              color: Colors.amber[50],
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.amber[800], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Generate with AI',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber[900]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Describe the job in plain English — Claude will build the work order for you.',
                      style: TextStyle(fontSize: 13, color: Colors.amber[800]),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _aiInputController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'e.g. "Run conduit from panel B to floors 3-5 and pull #12 wire for 40 circuits"',
                        border: const OutlineInputBorder(),
                        fillColor: Colors.white,
                        filled: true,
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _aiLoading ? null : _generateWithAI,
                        icon: _aiLoading
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.auto_awesome),
                        label: Text(_aiLoading ? 'Generating…' : 'Generate Work Order'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    // Show AI task breakdown
                    if (_aiResult != null) ...[
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green[700], size: 18),
                          const SizedBox(width: 6),
                          Text('AI generated ${(_aiResult!['tasks'] as List).length} tasks — form pre-filled below',
                              style: TextStyle(color: Colors.green[700], fontWeight: FontWeight.w600, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...(_aiResult!['tasks'] as List).map((t) {
                        final task = t as Map<String, dynamic>;
                        return _buildAITaskPreview(task);
                      }),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Project ───────────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Project', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedProject,
                      decoration: const InputDecoration(border: OutlineInputBorder(), prefixIcon: Icon(Icons.folder)),
                      items: _availableProjects.map((p) => DropdownMenuItem(value: p, child: Text(p))).toList(),
                      onChanged: (v) => setState(() => _selectedProject = v!),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Task Details ──────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Task Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Task Title', border: OutlineInputBorder(), prefixIcon: Icon(Icons.title)),
                      validator: (v) => (v == null || v.isEmpty) ? 'Please enter a task title' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder(), prefixIcon: Icon(Icons.description)),
                      maxLines: 3,
                      validator: (v) => (v == null || v.isEmpty) ? 'Please enter a description' : null,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Location ──────────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.location_on, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _floorController,
                            decoration: const InputDecoration(labelText: 'Floor', border: OutlineInputBorder(), hintText: 'e.g., 2nd Floor'),
                            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _roomController,
                            decoration: const InputDecoration(labelText: 'Room', border: OutlineInputBorder(), hintText: 'e.g., Conference A'),
                            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Priority ──────────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Priority', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: TaskPriority.values.map((priority) {
                        final isSelected = _selectedPriority == priority;
                        final (color, label) = switch (priority) {
                          TaskPriority.low => (Colors.grey, 'Low'),
                          TaskPriority.medium => (Colors.blue, 'Medium'),
                          TaskPriority.high => (Colors.orange, 'High'),
                          TaskPriority.urgent => (Colors.red, 'Urgent'),
                        };
                        return ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          selectedColor: color,
                          labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
                          onSelected: (_) => setState(() => _selectedPriority = priority),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Material Kits ─────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Icon(Icons.inventory_2, color: Colors.orange),
                      SizedBox(width: 8),
                      Text('Material Kits', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableMaterialKits.map((kit) {
                        final isSelected = _selectedMaterialKits.contains(kit);
                        return FilterChip(
                          label: Text(kit),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              selected ? _selectedMaterialKits.add(kit) : _selectedMaterialKits.remove(kit);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Submit ────────────────────────────────────────────────────
            ElevatedButton.icon(
              onPressed: _saving ? null : _createWorkOrder,
              icon: _saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.add_task),
              label: Text(_saving ? 'Saving…' : 'Create Work Order'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[700],
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAITaskPreview(Map<String, dynamic> task) {
    final priority = task['priority'] as String? ?? 'medium';
    final hours = task['estimated_hours'];
    final materials = (task['materials'] as List<dynamic>?) ?? [];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(task['title'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Colors.amber[100], borderRadius: BorderRadius.circular(8)),
                child: Text(priority.toUpperCase(), style: TextStyle(fontSize: 10, color: Colors.amber[900], fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (hours != null) ...[
            const SizedBox(height: 4),
            Text('~$hours hrs', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
          if (materials.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('Materials: ${materials.take(3).join(", ")}${materials.length > 3 ? "…" : ""}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ],
        ],
      ),
    );
  }
}
