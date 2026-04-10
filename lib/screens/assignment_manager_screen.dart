import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/assignment_model.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/common_widgets.dart';

class AssignmentManagerScreen extends StatefulWidget {
  const AssignmentManagerScreen({super.key});

  @override
  State<AssignmentManagerScreen> createState() =>
      _AssignmentManagerScreenState();
}

class _AssignmentManagerScreenState extends State<AssignmentManagerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<AssignmentModel> _assignments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _load() {
    setState(() {
      _assignments = StorageService.getAllAssignments()
        ..sort((a, b) => a.deadline.compareTo(b.deadline));
    });
  }

  List<AssignmentModel> get _pending =>
      _assignments.where((a) => !a.isCompleted).toList();

  List<AssignmentModel> get _completed =>
      _assignments.where((a) => a.isCompleted).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Assignments'),
        backgroundColor: AppTheme.surface,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: [
            Tab(text: 'Pending (${_pending.length})'),
            Tab(text: 'Completed (${_completed.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildList(_pending, 'No pending assignments! 🎉'),
          _buildList(_completed, 'No completed assignments yet.'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDialog,
        backgroundColor: AppTheme.assignmentColor,
        icon: const Icon(Icons.add),
        label: const Text('Add Assignment'),
      ),
    );
  }

  Widget _buildList(List<AssignmentModel> items, String emptyMsg) {
    if (items.isEmpty) {
      return EmptyStateWidget(
        message: emptyMsg,
        icon: Icons.assignment_outlined,
        actionLabel: items.isEmpty ? 'Add Assignment' : null,
        onAction: items.isEmpty ? _showAddDialog : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _load(),
      color: AppTheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        itemCount: items.length,
        itemBuilder: (_, i) => _buildCard(items[i]),
      ),
    );
  }

  Widget _buildCard(AssignmentModel a) {
    final days = a.daysUntilDeadline;
    Color urgencyColor;
    String urgencyLabel;

    if (a.isCompleted) {
      urgencyColor = AppTheme.studyColor;
      urgencyLabel = 'Done';
    } else if (a.isOverdue) {
      urgencyColor = AppTheme.accent;
      urgencyLabel = 'Overdue!';
    } else if (days == 0) {
      urgencyColor = AppTheme.accent;
      urgencyLabel = 'Due Today!';
    } else if (days == 1) {
      urgencyColor = Colors.orange;
      urgencyLabel = 'Tomorrow';
    } else if (days <= 3) {
      urgencyColor = Colors.orange;
      urgencyLabel = 'In $days days';
    } else {
      urgencyColor = AppTheme.secondary;
      urgencyLabel = 'In $days days';
    }

    return Dismissible(
      key: Key(a.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.accent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) async {
        await StorageService.deleteAssignment(a.id);
        _load();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: urgencyColor, width: 4),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: urgencyColor.withAlpha(40),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.assignment, color: urgencyColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.title,
                          style: TextStyle(
                            color: a.isCompleted
                                ? AppTheme.textSecondary
                                : AppTheme.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            decoration: a.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          a.subjectName,
                          style: const TextStyle(
                              color: AppTheme.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: urgencyColor.withAlpha(40),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      urgencyLabel,
                      style: TextStyle(
                          color: urgencyColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.event, size: 14, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                    'Deadline: ${DateFormat('EEEE, MMM d, yyyy').format(a.deadline)}',
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12),
                  ),
                ],
              ),
              if (a.notes.isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.notes, size: 14, color: AppTheme.textSecondary),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(a.notes,
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12)),
                    ),
                  ],
                ),
              ],
              if (!a.isCompleted) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _markComplete(a),
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: const Text('Mark Complete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.studyColor,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton.icon(
                      onPressed: () => _showEditDialog(a),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textSecondary,
                        side: const BorderSide(color: AppTheme.textSecondary),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _markComplete(AssignmentModel a) async {
    await StorageService.completeAssignment(a.id);
    _load();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Assignment done! +40 XP earned 🎉'),
          backgroundColor: AppTheme.studyColor,
        ),
      );
    }
  }

  // ─── Add/Edit Dialog ──────────────────────────────────────────────────────────

  void _showAddDialog() => _showDialog(null);
  void _showEditDialog(AssignmentModel a) => _showDialog(a);

  void _showDialog(AssignmentModel? existing) {
    final subjectCtrl = TextEditingController(text: existing?.subjectName ?? '');
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    DateTime deadline = existing?.deadline ??
        DateTime.now().add(const Duration(days: 7));
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 20, right: 20, top: 20,
          ),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(existing == null ? 'New Assignment' : 'Edit Assignment',
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: subjectCtrl,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Subject Name',
                      prefixIcon: Icon(Icons.school, color: AppTheme.primary),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: titleCtrl,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Assignment Title',
                      prefixIcon: Icon(Icons.assignment, color: AppTheme.primary),
                    ),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: notesCtrl,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      prefixIcon: Icon(Icons.notes, color: AppTheme.primary),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: deadline,
                        firstDate: DateTime.now(),
                        lastDate:
                            DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) setS(() => deadline = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppTheme.primary.withAlpha(80)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event,
                              color: AppTheme.primary, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            'Deadline: ${DateFormat('EEE, MMM d, yyyy').format(deadline)}',
                            style: const TextStyle(
                                color: AppTheme.textPrimary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        Navigator.pop(ctx);

                        if (existing == null) {
                          final a = AssignmentModel(
                            id: StorageService.generateId(),
                            subjectName: subjectCtrl.text.trim(),
                            title: titleCtrl.text.trim(),
                            deadline: deadline,
                            notes: notesCtrl.text.trim(),
                            createdAt: DateTime.now(),
                          );
                          await StorageService.addAssignment(a);
                          await NotificationService.scheduleAssignmentAlert(
                            id: a.id.hashCode,
                            subject: a.subjectName,
                            title: a.title,
                            deadline: a.deadline,
                          );
                        } else {
                          existing.subjectName = subjectCtrl.text.trim();
                          existing.title = titleCtrl.text.trim();
                          existing.deadline = deadline;
                          existing.notes = notesCtrl.text.trim();
                          await StorageService.updateAssignment(existing);
                        }
                        _load();
                      },
                      child: Text(existing == null ? 'Add Assignment' : 'Save'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
