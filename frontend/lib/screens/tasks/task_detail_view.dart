import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../theme/app_theme.dart';

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
    if (_task.status == TaskStatus.inProgress) _startTimer();
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

  String _formatDuration(int s) {
    final h = s ~/ 3600;
    final m = (s % 3600) ~/ 60;
    final sec = s % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  Future<void> _startTask() async {
    setState(() => _saving = true);
    try {
      final updated = await _taskService.updateTask(_task.id, {'status': 'in_progress'});
      setState(() { _task = updated; _saving = false; });
      if (!_isRunning) _startTimer();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task started', style: AppText.body(14)), backgroundColor: AppColors.tl.withValues(alpha: 0.9)),
        );
      }
    } catch (_) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not start task', style: AppText.body(14)), backgroundColor: AppColors.urgent.withValues(alpha: 0.9)),
        );
      }
    }
  }

  void _completeTask() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        title: Text('Complete Task?', style: AppText.display(18, weight: FontWeight.w700)),
        content: Text(
          'Mark as complete and send to your Team Lead for QC review.',
          style: AppText.body(14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppText.body(14, color: AppColors.textSecondary)),
          ),
          GestureDetector(
            onTap: () async {
              Navigator.pop(ctx);
              setState(() => _saving = true);
              try {
                await _taskService.updateTask(_task.id, {'status': 'review'});
                if (mounted) Navigator.pop(context, true);
              } catch (_) {
                setState(() => _saving = false);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Could not complete task', style: AppText.body(14)), backgroundColor: AppColors.urgent.withValues(alpha: 0.9)),
                  );
                }
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(color: AppColors.tl, borderRadius: BorderRadius.circular(8)),
              child: Text('Mark Complete', style: AppText.body(14, weight: FontWeight.w700, color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }

  void _uploadPhoto() {
    setState(() => _uploadedPhotos.add('photo_${_uploadedPhotos.length + 1}.jpg'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Photo uploaded', style: AppText.body(14)), backgroundColor: AppColors.tl.withValues(alpha: 0.9)),
    );
  }

  void _requestHelp() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceHigh,
        title: Row(children: [
          const Icon(Icons.help_outline, color: AppColors.high, size: 20),
          const SizedBox(width: 10),
          Text('Request Help', style: AppText.display(18, weight: FontWeight.w700)),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('What do you need help with?', style: AppText.body(14, color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              style: AppText.body(14),
              decoration: const InputDecoration(hintText: 'Describe the issue…'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: AppText.body(14, color: AppColors.textSecondary)),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(ctx);
              ctrl.dispose();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Help request sent to your Team Lead', style: AppText.body(14)), backgroundColor: AppColors.high.withValues(alpha: 0.9)),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(color: AppColors.high, borderRadius: BorderRadius.circular(8)),
              child: Text('Send', style: AppText.body(14, weight: FontWeight.w700, color: Colors.black)),
            ),
          ),
        ],
      ),
    );
  }

  Color _priorityColor(TaskPriority p) => switch (p) {
    TaskPriority.urgent => AppColors.urgent,
    TaskPriority.high   => AppColors.high,
    TaskPriority.medium => AppColors.medium,
    TaskPriority.low    => AppColors.low,
  };

  String _priorityLabel(TaskPriority p) => switch (p) {
    TaskPriority.urgent => 'Urgent',
    TaskPriority.high   => 'High',
    TaskPriority.medium => 'Medium',
    TaskPriority.low    => 'Low',
  };

  @override
  Widget build(BuildContext context) {
    final pc = _priorityColor(_task.priority);
    final isAssigned   = _task.status == TaskStatus.assigned;
    final isInProgress = _task.status == TaskStatus.inProgress;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Task Details', style: AppText.display(18, weight: FontWeight.w700)),
        actions: [
          if (!_task.status.toString().contains('completed') && !_task.status.toString().contains('verified'))
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: _requestHelp,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.high.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.high.withValues(alpha: 0.3)),
                  ),
                  child: Text('Help', style: AppText.body(13, weight: FontWeight.w600, color: AppColors.high)),
                ),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // ── Task info card ────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border(left: BorderSide(color: pc, width: 3)),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(_task.title, style: AppText.display(20, weight: FontWeight.w700))),
                    StatusChip(_priorityLabel(_task.priority), color: pc),
                  ],
                ),
                const SizedBox(height: 6),
                Text(_task.projectName, style: AppText.body(13, color: AppColors.textSecondary)),
                if (_task.location != null) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.location_on_outlined, size: 13, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(_task.location!, style: AppText.body(12, color: AppColors.textMuted)),
                  ]),
                ],
                if (_task.description.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(_task.description, style: AppText.body(13, color: AppColors.textSecondary)),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Timer card ────────────────────────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isRunning
                    ? AppColors.tm.withValues(alpha: 0.3)
                    : AppColors.border,
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _isRunning ? Icons.timer : Icons.timer_off_outlined,
                      size: 18,
                      color: _isRunning ? AppColors.tm : AppColors.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _isRunning ? 'RUNNING' : 'PAUSED',
                      style: AppText.display(11,
                        color: _isRunning ? AppColors.tm : AppColors.textMuted,
                        letterSpacing: 2,
                        weight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _formatDuration(_elapsedSeconds),
                  style: AppText.display(52,
                    color: _isRunning ? AppColors.tm : AppColors.textMuted,
                    weight: FontWeight.w700,
                    letterSpacing: 3,
                  ),
                ),
                if (isInProgress) ...[
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: _isRunning ? 'Pause' : 'Resume',
                    icon: _isRunning ? Icons.pause : Icons.play_arrow,
                    color: _isRunning ? AppColors.high : AppColors.tl,
                    fullWidth: true,
                    onPressed: _toggleTimer,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          // ── Safety requirements ───────────────────────────────────────────
          if (_task.materialKits.isNotEmpty) ...[
            _sectionCard(
              icon: Icons.inventory_2_outlined,
              title: 'Materials',
              child: Wrap(
                spacing: 8,
                runSpacing: 6,
                children: _task.materialKits.map((m) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(m, style: AppText.body(12, color: AppColors.textSecondary)),
                )).toList(),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // ── Photos ────────────────────────────────────────────────────────
          _sectionCard(
            icon: Icons.photo_camera_outlined,
            title: 'Work-in-Place Photos',
            action: GhostButton(label: 'Upload', icon: Icons.add_a_photo_outlined, onPressed: _uploadPhoto, color: AppColors.sm),
            child: _uploadedPhotos.isEmpty
                ? Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Column(children: [
                      Icon(Icons.add_photo_alternate_outlined, size: 36, color: AppColors.textMuted),
                      SizedBox(height: 8),
                      Text('No photos yet', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                    ]),
                  )
                : Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _uploadedPhotos.map((p) => Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.tl.withValues(alpha: 0.3)),
                      ),
                      child: Stack(children: [
                        Center(child: Icon(Icons.image_outlined, size: 36, color: AppColors.textMuted)),
                        Positioned(
                          top: 4, right: 4,
                          child: Container(
                            padding: const EdgeInsets.all(3),
                            decoration: const BoxDecoration(color: AppColors.tl, shape: BoxShape.circle),
                            child: const Icon(Icons.check, size: 12, color: Colors.black),
                          ),
                        ),
                      ]),
                    )).toList(),
                  ),
          ),
          const SizedBox(height: 24),

          // ── CTA buttons ───────────────────────────────────────────────────
          if (isAssigned)
            PrimaryButton(
              label: _saving ? 'Starting…' : 'Start Task',
              icon: Icons.play_arrow,
              color: AppColors.tm,
              fullWidth: true,
              loading: _saving,
              onPressed: _startTask,
            ),
          if (isInProgress)
            PrimaryButton(
              label: _saving ? 'Submitting…' : 'Mark Complete',
              icon: Icons.check_circle_outline,
              color: AppColors.tl,
              fullWidth: true,
              loading: _saving,
              onPressed: _completeTask,
            ),
        ],
      ),
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required String title,
    required Widget child,
    Widget? action,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: AppText.body(14, weight: FontWeight.w600))),
            if (action != null) action,
          ]),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
