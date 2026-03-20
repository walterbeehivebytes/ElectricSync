import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/task.dart';
import '../../services/task_service.dart';

class TaskDetailView extends StatefulWidget {
  final Task task;
  const TaskDetailView({super.key, required this.task});

  @override
  State<TaskDetailView> createState() => _TaskDetailViewState();
}

class _TaskDetailViewState extends State<TaskDetailView> {
  final _taskService = TaskService();
  late Task _task;
  bool _saving = false;
  bool _isRunning = false;
  int _elapsedSeconds = 0;
  Timer? _timer;
  final List<String> _uploadedPhotos = [];

  @override
  void initState() {
    super.initState();
    _task = widget.task;
    if (_task.status == TaskStatus.inProgress) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _elapsedSeconds++);
    });
  }

  void _toggleTimer() {
    if (_isRunning) {
      setState(() => _isRunning = false);
      _timer?.cancel();
    } else {
      _startTimer();
    }
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  Future<void> _startTask() async {
    setState(() => _saving = true);
    try {
      final updated = await _taskService.updateTask(_task.id, {'status': 'in_progress'});
      setState(() { _task = updated; _saving = false; });
      if (!_isRunning) _startTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task started!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not start task'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _completeTask() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete Task?'),
        content: const Text(
          'Mark this task as complete and send to your Team Lead for QC verification.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _saving = true);
              try {
                await _taskService.updateTask(_task.id, {'status': 'review'});
                if (mounted) Navigator.pop(context, true);
              } catch (e) {
                setState(() => _saving = false);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not complete task'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }

  void _uploadPhoto() {
    setState(() => _uploadedPhotos.add('photo_${_uploadedPhotos.length + 1}.jpg'));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Photo uploaded'), backgroundColor: Colors.green),
    );
  }

  void _requestHelp() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(children: [
          Icon(Icons.help_outline, color: Colors.orange),
          SizedBox(width: 12),
          Text('Request Help'),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('What do you need help with?'),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Describe the issue...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Help request sent to your Team Lead'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send Request'),
          ),
        ],
      ),
    );
  }

  (String, Color) _priorityStyle(TaskPriority p) => switch (p) {
    TaskPriority.urgent => ('Urgent', Colors.red),
    TaskPriority.high   => ('High',   Colors.orange),
    TaskPriority.medium => ('Medium', Colors.blue),
    TaskPriority.low    => ('Low',    Colors.grey),
  };

  @override
  Widget build(BuildContext context) {
    final (priorityLabel, priorityColor) = _priorityStyle(_task.priority);
    final isAssigned = _task.status == TaskStatus.assigned;
    final isInProgress = _task.status == TaskStatus.inProgress;

    return Scaffold(
      appBar: AppBar(title: const Text('Task Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Task Info
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _task.title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _task.projectName,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  if (_task.location != null) ...[
                    Row(children: [
                      Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(_task.location!),
                    ]),
                    const SizedBox(height: 4),
                  ],
                  if (_task.description.isNotEmpty) ...[
                    Text(
                      _task.description,
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: priorityColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$priorityLabel Priority',
                      style: TextStyle(
                        fontSize: 11,
                        color: priorityColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Timer
          Card(
            color: _isRunning ? Colors.green[50] : Colors.grey[50],
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    _isRunning ? Icons.timer : Icons.timer_off,
                    size: 48,
                    color: _isRunning ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _formatDuration(_elapsedSeconds),
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      color: _isRunning ? Colors.green[700] : Colors.grey[700],
                    ),
                  ),
                  if (isInProgress) ...[
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _toggleTimer,
                        icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                        label: Text(_isRunning ? 'PAUSE' : 'RESUME'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isRunning ? Colors.orange : Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(0, 64),
                          textStyle: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Work Photos
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Icon(Icons.photo_camera, color: Colors.blue),
                    SizedBox(width: 12),
                    Text(
                      'Work-in-Place Photos',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ]),
                  const SizedBox(height: 12),
                  if (_uploadedPhotos.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Column(children: [
                          Icon(Icons.add_photo_alternate, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text('No photos yet', style: TextStyle(color: Colors.grey[600])),
                        ]),
                      ),
                    )
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _uploadedPhotos.map((p) => Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Stack(children: [
                          Center(child: Icon(Icons.image, size: 40, color: Colors.grey[400])),
                          Positioned(
                            top: 4, right: 4,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.check, size: 16, color: Colors.white),
                            ),
                          ),
                        ]),
                      )).toList(),
                    ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _uploadPhoto,
                    icon: const Icon(Icons.add_a_photo),
                    label: const Text('Upload Photo'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Context-sensitive action buttons
          if (isAssigned)
            ElevatedButton.icon(
              onPressed: _saving ? null : _startTask,
              icon: _saving
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(_saving ? 'Starting…' : 'Start Task'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),

          if (isInProgress) ...[
            ElevatedButton.icon(
              onPressed: _requestHelp,
              icon: const Icon(Icons.help_outline),
              label: const Text('Request Help'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _saving ? null : _completeTask,
              icon: _saving
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_circle),
              label: Text(_saving ? 'Saving…' : 'Mark Complete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
