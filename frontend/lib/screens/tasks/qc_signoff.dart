import 'package:flutter/material.dart';
import '../../models/auth_user.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../theme/app_theme.dart';

class QCSignoff extends StatefulWidget {
  final AuthUser currentUser;
  const QCSignoff({super.key, required this.currentUser});

  @override
  State<QCSignoff> createState() => _QCSignoffState();
}

class _QCSignoffState extends State<QCSignoff> {
  final _taskService = TaskService();
  List<Task> _pendingQC = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final tasks = await _taskService.getTasksByTeamLead(widget.currentUser.id);
      if (mounted) {
        setState(() {
          _pendingQC = tasks.where((t) => t.status == TaskStatus.verified).toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { _error = 'Could not load tasks'; _loading = false; });
    }
  }

  Future<void> _approve(Task task) async {
    try {
      await _taskService.updateTask(task.id, {'status': 'completed'});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${task.title} approved', style: AppText.body(14)),
            backgroundColor: AppColors.tl.withValues(alpha: 0.9),
          ),
        );
        _load();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Approval failed', style: AppText.body(14)), backgroundColor: AppColors.urgent.withValues(alpha: 0.9)),
        );
      }
    }
  }

  void _showRejectSheet(Task task) {
    final notesCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, _) => Padding(
          padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Row(children: [
                const Icon(Icons.cancel_outlined, color: AppColors.urgent, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('Reject: ${task.title}', style: AppText.display(16, weight: FontWeight.w700))),
              ]),
              const SizedBox(height: 6),
              Text('Task will be sent back to the crew member.', style: AppText.body(13, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              TextField(
                controller: notesCtrl,
                maxLines: 3,
                autofocus: true,
                style: AppText.body(14),
                decoration: const InputDecoration(labelText: 'Rejection notes (required)'),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Send Back to Crew',
                icon: Icons.undo,
                color: AppColors.urgent,
                fullWidth: true,
                onPressed: () async {
                  final notes = notesCtrl.text.trim();
                  if (notes.isEmpty) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('Add rejection notes first', style: AppText.body(14)), backgroundColor: AppColors.high.withValues(alpha: 0.9)),
                    );
                    return;
                  }
                  Navigator.pop(ctx);
                  notesCtrl.dispose();
                  try {
                    await _taskService.updateTask(task.id, {
                      'status': 'in_progress',
                      'description': '${task.description}\n[Rejected: $notes]',
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${task.title} sent back to crew', style: AppText.body(14)), backgroundColor: AppColors.high.withValues(alpha: 0.9)),
                      );
                      _load();
                    }
                  } catch (_) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Rejection failed', style: AppText.body(14)), backgroundColor: AppColors.urgent.withValues(alpha: 0.9)),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),
      ),
    ).whenComplete(() => notesCtrl.dispose());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.textSecondary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(children: [
          RoleBadge('TL', color: AppColors.tl),
          const SizedBox(width: 10),
          Text('QC Sign-off', style: AppText.body(16, weight: FontWeight.w600)),
        ]),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: AppIconButton(Icons.refresh, onPressed: _load),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.tl, strokeWidth: 2))
          : _error != null
              ? Center(child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(_error!, style: AppText.body(14, color: AppColors.urgent)),
                    const SizedBox(height: 12),
                    GhostButton(label: 'Retry', onPressed: _load),
                  ],
                ))
              : RefreshIndicator(
                  color: AppColors.tl,
                  backgroundColor: AppColors.surfaceHigh,
                  onRefresh: _load,
                  child: _pendingQC.isEmpty
                      ? ListView(children: [
                          const SizedBox(height: 80),
                          Center(child: Column(children: [
                            Container(
                              width: 72, height: 72,
                              decoration: BoxDecoration(
                                color: AppColors.tl.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.tl.withValues(alpha: 0.2)),
                              ),
                              child: const Icon(Icons.check_circle_outline, size: 36, color: AppColors.tl),
                            ),
                            const SizedBox(height: 16),
                            Text('All clear', style: AppText.display(22, weight: FontWeight.w700, color: AppColors.tl)),
                            const SizedBox(height: 6),
                            Text('No tasks awaiting QC review', style: AppText.body(14, color: AppColors.textSecondary)),
                            const SizedBox(height: 8),
                            Text('Tasks appear here when crew marks them complete.', style: AppText.body(13, color: AppColors.textMuted)),
                          ])),
                        ])
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _pendingQC.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 8),
                          itemBuilder: (_, i) => _buildQCCard(_pendingQC[i]),
                        ),
                ),
    );
  }

  Widget _buildQCCard(Task task) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: AppColors.tl, width: 3)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.pending_actions, color: AppColors.tl, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(task.title, style: AppText.body(15, weight: FontWeight.w600))),
            const StatusChip('QC REVIEW', color: AppColors.tl),
          ]),
          if (task.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(task.description, style: AppText.body(13, color: AppColors.textSecondary), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: GhostButton(
                label: 'Reject',
                icon: Icons.cancel_outlined,
                color: AppColors.urgent,
                fullWidth: true,
                onPressed: () => _showRejectSheet(task),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: PrimaryButton(
                label: 'Approve',
                icon: Icons.check_circle_outline,
                color: AppColors.tl,
                fullWidth: true,
                onPressed: () => _approve(task),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}
