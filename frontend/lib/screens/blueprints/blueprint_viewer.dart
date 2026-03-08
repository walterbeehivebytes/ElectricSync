import 'package:flutter/material.dart';
import '../../models/blueprint.dart';
import '../../models/user.dart';

class BlueprintViewer extends StatefulWidget {
  final UserRole userRole;

  const BlueprintViewer({
    super.key,
    required this.userRole,
  });

  @override
  State<BlueprintViewer> createState() => _BlueprintViewerState();
}

class _BlueprintViewerState extends State<BlueprintViewer> {
  // Mock blueprint data
  final List<BlueprintPin> _pins = [
    BlueprintPin(
      id: 'pin1',
      x: 0.3,
      y: 0.4,
      taskId: 'task1',
      title: 'Install Panel A',
      description: 'Main electrical panel installation',
      status: PinStatus.inProgress,
      createdBy: 'Project Manager',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    BlueprintPin(
      id: 'pin2',
      x: 0.6,
      y: 0.3,
      taskId: 'task2',
      title: 'Conduit Run - East Wing',
      description: 'Run 2" conduit from panel to junction box',
      status: PinStatus.pending,
      createdBy: 'Project Manager',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    BlueprintPin(
      id: 'pin3',
      x: 0.5,
      y: 0.7,
      taskId: 'task3',
      title: 'Junction Box Installation',
      description: 'Install 4x4 junction box',
      status: PinStatus.completed,
      createdBy: 'Project Manager',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    BlueprintPin(
      id: 'pin4',
      x: 0.7,
      y: 0.5,
      taskId: 'task4',
      title: 'Receptacle Installation',
      description: '20A receptacles per spec',
      status: PinStatus.redlined,
      createdBy: 'Project Manager',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      redlineNote: 'Moved 6" lower per site conditions',
      redlinedAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  double _scale = 1.0;
  Offset _offset = Offset.zero;
  BlueprintPin? _selectedPin;

  Color _getPinColor(PinStatus status) {
    switch (status) {
      case PinStatus.pending:
        return Colors.grey;
      case PinStatus.inProgress:
        return Colors.blue;
      case PinStatus.completed:
        return Colors.green;
      case PinStatus.redlined:
        return Colors.orange;
    }
  }

  IconData _getPinIcon(PinStatus status) {
    switch (status) {
      case PinStatus.pending:
        return Icons.radio_button_unchecked;
      case PinStatus.inProgress:
        return Icons.play_circle;
      case PinStatus.completed:
        return Icons.check_circle;
      case PinStatus.redlined:
        return Icons.warning;
    }
  }

  String _getPinStatusLabel(PinStatus status) {
    switch (status) {
      case PinStatus.pending:
        return 'Pending';
      case PinStatus.inProgress:
        return 'In Progress';
      case PinStatus.completed:
        return 'Completed';
      case PinStatus.redlined:
        return 'Redlined';
    }
  }

  void _handleBlueprintTap(TapDownDetails details, Size blueprintSize) {
    if (widget.userRole != UserRole.projectManager &&
        widget.userRole != UserRole.siteManager) return;

    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(details.globalPosition);

    // Calculate relative position (0.0 to 1.0)
    final relativeX = (localPosition.dx - _offset.dx) / (blueprintSize.width * _scale);
    final relativeY = (localPosition.dy - _offset.dy) / (blueprintSize.height * _scale);

    if (relativeX >= 0 && relativeX <= 1 && relativeY >= 0 && relativeY <= 1) {
      _showCreatePinDialog(relativeX, relativeY);
    }
  }

  void _showCreatePinDialog(double x, double y) {
    final titleController = TextEditingController();
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.push_pin, color: Colors.blue),
            SizedBox(width: 12),
            Text('Create Task Pin'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
              if (titleController.text.isNotEmpty) {
                setState(() {
                  _pins.add(
                    BlueprintPin(
                      id: 'pin${_pins.length + 1}',
                      x: x,
                      y: y,
                      taskId: 'task${_pins.length + 1}',
                      title: titleController.text,
                      description: descController.text.isNotEmpty
                          ? descController.text
                          : null,
                      status: PinStatus.pending,
                      createdBy: widget.userRole == UserRole.projectManager
                          ? 'Project Manager'
                          : 'Site Manager',
                      createdAt: DateTime.now(),
                    ),
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Task pin created'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Create Pin'),
          ),
        ],
      ),
    );
  }

  void _showPinDetails(BlueprintPin pin) {
    setState(() => _selectedPin = pin);

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_getPinIcon(pin.status), color: _getPinColor(pin.status)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    pin.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getPinColor(pin.status).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getPinStatusLabel(pin.status),
                    style: TextStyle(
                      color: _getPinColor(pin.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (pin.description != null) ...[
              const SizedBox(height: 12),
              Text(
                pin.description!,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
            const SizedBox(height: 16),
            if (pin.status == PinStatus.redlined && pin.redlineNote != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.05),
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.warning, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Redline Note',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(pin.redlineNote!),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                if (widget.userRole == UserRole.teamMember) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Opening task: ${pin.title}'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Open Task'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
                if (widget.userRole == UserRole.teamLead &&
                    pin.status != PinStatus.redlined) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showRedlineDialog(pin);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Mark as Redlined'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
                if (widget.userRole == UserRole.projectManager ||
                    widget.userRole == UserRole.siteManager) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          _pins.removeWhere((p) => p.id == pin.id);
                        });
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pin deleted'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete Pin'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    ).then((_) => setState(() => _selectedPin = null));
  }

  void _showRedlineDialog(BlueprintPin pin) {
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 12),
            Text('Mark as Redlined'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Document how the field installation differs from the drawing:',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: 'Redline Note',
                border: OutlineInputBorder(),
                hintText: 'e.g., Moved 6" lower due to beam interference',
              ),
              maxLines: 3,
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
              if (noteController.text.isNotEmpty) {
                setState(() {
                  final index = _pins.indexWhere((p) => p.id == pin.id);
                  _pins[index] = pin.copyWith(
                    status: PinStatus.redlined,
                    redlineNote: noteController.text,
                    redlinedAt: DateTime.now(),
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pin marked as redlined'),
                    backgroundColor: Colors.orange,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Mark Redlined'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blueprint Viewer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              setState(() => _scale = (_scale * 1.2).clamp(0.5, 3.0));
            },
          ),
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              setState(() => _scale = (_scale / 1.2).clamp(0.5, 3.0));
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _scale = 1.0;
                _offset = Offset.zero;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showLegend(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Role instruction banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.blue.withValues(alpha: 0.05),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue[700]),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getRoleInstruction(),
                    style: TextStyle(color: Colors.blue[900]),
                  ),
                ),
              ],
            ),
          ),

          // Blueprint viewer
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const blueprintWidth = 800.0;
                const blueprintHeight = 600.0;

                return GestureDetector(
                  onTapDown: (details) =>
                      _handleBlueprintTap(details, const Size(blueprintWidth, blueprintHeight)),
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 3.0,
                    boundaryMargin: const EdgeInsets.all(50),
                    child: Center(
                      child: SizedBox(
                        width: blueprintWidth,
                        height: blueprintHeight,
                        child: Stack(
                          children: [
                            // Blueprint background
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                border: Border.all(color: Colors.grey[300]!),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: CustomPaint(
                                painter: BlueprintGridPainter(),
                                size: const Size(blueprintWidth, blueprintHeight),
                              ),
                            ),

                            // Pins
                            ..._pins.map((pin) {
                              final isSelected = _selectedPin?.id == pin.id;
                              return Positioned(
                                left: pin.x * blueprintWidth - 20,
                                top: pin.y * blueprintHeight - 40,
                                child: GestureDetector(
                                  onTap: () => _showPinDetails(pin),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: _getPinColor(pin.status),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: isSelected ? 3 : 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.5),
                                              blurRadius: isSelected ? 8 : 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          _getPinIcon(pin.status),
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      if (isSelected)
                                        Container(
                                          margin: const EdgeInsets.only(top: 4),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(4),
                                            boxShadow: [
                                              BoxShadow(
                                                color: isSelected ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2) : Colors.transparent,
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            pin.title,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Pin count summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatusCount(PinStatus.pending),
                _buildStatusCount(PinStatus.inProgress),
                _buildStatusCount(PinStatus.completed),
                _buildStatusCount(PinStatus.redlined),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleInstruction() {
    switch (widget.userRole) {
      case UserRole.projectManager:
        return 'Tap anywhere on blueprint to create task pins. Tap a pin to delete it.';
      case UserRole.siteManager:
        return 'Tap anywhere on the blueprint to create a task pin';
      case UserRole.teamLead:
        return 'Tap on pins to mark as redlined if field install differs from drawing';
      case UserRole.teamMember:
        return 'Tap on pins to view task details and your work location';
    }
  }

  Widget _buildStatusCount(PinStatus status) {
    final count = _pins.where((p) => p.status == status).length;
    return Row(
      children: [
        Icon(_getPinIcon(status), color: _getPinColor(status), size: 20),
        const SizedBox(width: 6),
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showLegend() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pin Legend'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLegendItem(PinStatus.pending, 'Task not yet started'),
            _buildLegendItem(PinStatus.inProgress, 'Work in progress'),
            _buildLegendItem(PinStatus.completed, 'Task completed'),
            _buildLegendItem(PinStatus.redlined, 'Field install differs from drawing'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(PinStatus status, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(_getPinIcon(status), color: _getPinColor(status)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getPinStatusLabel(status),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BlueprintGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    // Draw grid
    const gridSpacing = 50.0;
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw mock floor plan elements
    final wallPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Outer walls
    canvas.drawRect(
      Rect.fromLTWH(50, 50, size.width - 100, size.height - 100),
      wallPaint,
    );

    // Internal walls
    canvas.drawLine(
      Offset(size.width / 2, 50),
      Offset(size.width / 2, size.height - 50),
      wallPaint,
    );

    // Add labels
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'Floor 2 - Electrical Layout',
        style: TextStyle(
          color: Colors.black54,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(size.width / 2 - 100, 20));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
