import 'package:flutter/material.dart';
import '../../models/task.dart';

class WorkOrderCreator extends StatefulWidget {
  const WorkOrderCreator({super.key});

  @override
  State<WorkOrderCreator> createState() => _WorkOrderCreatorState();
}

class _WorkOrderCreatorState extends State<WorkOrderCreator> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _floorController = TextEditingController();
  final _roomController = TextEditingController();

  String _selectedProject = 'Office Building Rewiring';
  TaskPriority _selectedPriority = TaskPriority.medium;
  final List<String> _selectedMaterialKits = [];

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
    super.dispose();
  }

  void _createWorkOrder() {
    if (_formKey.currentState!.validate()) {
      // In production, this would save to a backend
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Work order created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Work Order'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Project Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Project',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedProject,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.folder),
                      ),
                      items: _availableProjects.map((project) {
                        return DropdownMenuItem(
                          value: project,
                          child: Text(project),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedProject = value!);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Task Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Task Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Task Title',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a task title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Location
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Location',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _floorController,
                            decoration: const InputDecoration(
                              labelText: 'Floor',
                              border: OutlineInputBorder(),
                              hintText: 'e.g., 2nd Floor',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _roomController,
                            decoration: const InputDecoration(
                              labelText: 'Room',
                              border: OutlineInputBorder(),
                              hintText: 'e.g., Conference A',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Priority
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Priority',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: TaskPriority.values.map((priority) {
                        final isSelected = _selectedPriority == priority;
                        Color color;
                        String label;

                        switch (priority) {
                          case TaskPriority.low:
                            color = Colors.grey;
                            label = 'Low';
                            break;
                          case TaskPriority.medium:
                            color = Colors.blue;
                            label = 'Medium';
                            break;
                          case TaskPriority.high:
                            color = Colors.orange;
                            label = 'High';
                            break;
                          case TaskPriority.urgent:
                            color = Colors.red;
                            label = 'Urgent';
                            break;
                        }

                        return ChoiceChip(
                          label: Text(label),
                          selected: isSelected,
                          selectedColor: color,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                          onSelected: (selected) {
                            setState(() => _selectedPriority = priority);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Material Kits
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.inventory_2, color: Colors.orange),
                        SizedBox(width: 8),
                        Text(
                          'Material Kits',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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
                              if (selected) {
                                _selectedMaterialKits.add(kit);
                              } else {
                                _selectedMaterialKits.remove(kit);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Blueprint Upload
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.architecture, color: Colors.purple),
                        SizedBox(width: 8),
                        Text(
                          'Blueprint',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        // In production, this would open file picker
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Blueprint upload coming soon'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.upload_file),
                      label: const Text('Upload Blueprint'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Create Button
            ElevatedButton.icon(
              onPressed: _createWorkOrder,
              icon: const Icon(Icons.add_task),
              label: const Text('Create Work Order'),
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
}
