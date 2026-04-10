import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/goal_model.dart';
import '../services/storage_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/common_widgets.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  List<GoalModel> _goals = [];

  final List<String> _goalCategories = ['IBM', 'GATE', 'Coding', 'Assignments', 'Personal'];

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  void _loadGoals() {
    setState(() {
      _goals = StorageService.getAllGoals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Goals'),
        backgroundColor: AppTheme.surface,
      ),
      body: _goals.isEmpty
          ? EmptyStateWidget(
              message: 'No goals yet.\nSet your targets and start forging!',
              icon: Icons.flag_outlined,
              actionLabel: 'Add Goal',
              onAction: _showAddGoalDialog,
            )
          : RefreshIndicator(
              onRefresh: () async => _loadGoals(),
              color: AppTheme.primary,
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                itemCount: _goals.length + 1,
                itemBuilder: (_, i) {
                  if (i == 0) return _buildHeader();
                  return _buildGoalCard(_goals[i - 1]);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGoalDialog,
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add),
        label: const Text('New Goal'),
      ),
    );
  }

  Widget _buildHeader() {
    final completed = _goals.where((g) => g.isCompleted).length;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GradientCard(
        colors: const [Color(0xFF1A1A2E), Color(0xFF16213E)],
        child: Row(
          children: [
            CircularProgressStat(
              label: 'Goals\nCompleted',
              progress: _goals.isEmpty ? 0 : completed / _goals.length,
              color: AppTheme.studyColor,
              centerText: '$completed/${_goals.length}',
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Your Targets',
                      style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ..._goalCategories.map((cat) {
                    final count = _goals.where((g) => g.category == cat).length;
                    if (count == 0) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.categoryColor(cat),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('$cat: $count',
                              style: const TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalCard(GoalModel goal) {
    final color = AppTheme.categoryColor(goal.category);
    final daysLeft = goal.targetDate.difference(DateTime.now()).inDays;

    return Dismissible(
      key: Key(goal.id),
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
        await StorageService.deleteGoal(goal.id);
        _loadGoals();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border(top: BorderSide(color: color, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_categoryIcon(goal.category), color: color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.title,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          CategoryBadge(category: goal.category),
                          const SizedBox(width: 8),
                          Text(
                            daysLeft > 0 ? '$daysLeft days left' : 'Overdue!',
                            style: TextStyle(
                              color: daysLeft < 7
                                  ? AppTheme.accent
                                  : AppTheme.textSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: AppTheme.textSecondary, size: 20),
                  onPressed: () => _showEditGoalDialog(goal),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (goal.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(goal.description,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13)),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
                Text(
                  '${(goal.progress * 100).toInt()}%',
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: goal.progress,
                backgroundColor: color.withAlpha(40),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.event, size: 14, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  'Target: ${DateFormat('MMM d, yyyy').format(goal.targetDate)}',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _updateProgress(goal),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: color.withAlpha(40),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Update Progress',
                      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case 'IBM': return Icons.business;
      case 'GATE': return Icons.school;
      case 'Coding': return Icons.code;
      case 'Assignments': return Icons.assignment;
      default: return Icons.flag;
    }
  }

  // ─── Update Progress Dialog ───────────────────────────────────────────────────

  void _updateProgress(GoalModel goal) {
    double progress = goal.progress;
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text('Update Progress',
              style: TextStyle(color: AppTheme.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${(progress * 100).toInt()}%',
                  style: const TextStyle(
                      color: AppTheme.primary, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Slider(
                value: progress,
                min: 0,
                max: 1,
                divisions: 100,
                activeColor: AppTheme.primary,
                onChanged: (v) => setS(() => progress = v),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                goal.progress = progress;
                if (progress >= 1.0) goal.isCompleted = true;
                await StorageService.updateGoal(goal);
                if (ctx.mounted) Navigator.pop(ctx);
                _loadGoals();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Add Goal Dialog ──────────────────────────────────────────────────────────

  void _showAddGoalDialog() => _showGoalDialog(null);
  void _showEditGoalDialog(GoalModel goal) => _showGoalDialog(goal);

  void _showGoalDialog(GoalModel? existing) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');
    String category = existing?.category ?? 'IBM';
    DateTime targetDate =
        existing?.targetDate ?? DateTime.now().add(const Duration(days: 60));
    double progress = existing?.progress ?? 0.0;
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
                  Text(existing == null ? 'New Goal' : 'Edit Goal',
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: titleCtrl,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(labelText: 'Goal Title'),
                    validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descCtrl,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 14),
                  const Text('Category', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _goalCategories.map((cat) {
                        final sel = cat == category;
                        final col = AppTheme.categoryColor(cat);
                        return GestureDetector(
                          onTap: () => setS(() => category = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: sel ? col : AppTheme.cardColor,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: col.withAlpha(120)),
                            ),
                            child: Text(cat, style: TextStyle(color: sel ? Colors.white : col, fontWeight: FontWeight.w600)),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  GestureDetector(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: targetDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 730)),
                      );
                      if (picked != null) setS(() => targetDate = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.primary.withAlpha(80)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event, color: AppTheme.primary, size: 18),
                          const SizedBox(width: 10),
                          Text('Target: ${DateFormat('MMM d, yyyy').format(targetDate)}',
                              style: const TextStyle(color: AppTheme.textPrimary)),
                        ],
                      ),
                    ),
                  ),
                  if (existing != null) ...[
                    const SizedBox(height: 14),
                    Text('Initial Progress: ${(progress * 100).toInt()}%',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    Slider(
                      value: progress,
                      min: 0,
                      max: 1,
                      divisions: 20,
                      activeColor: AppTheme.primary,
                      onChanged: (v) => setS(() => progress = v),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;
                        if (existing == null) {
                          final goal = GoalModel(
                            id: StorageService.generateId(),
                            title: titleCtrl.text.trim(),
                            description: descCtrl.text.trim(),
                            category: category,
                            targetDate: targetDate,
                            progress: progress,
                            createdAt: DateTime.now(),
                          );
                          await StorageService.addGoal(goal);
                        } else {
                          existing.title = titleCtrl.text.trim();
                          existing.description = descCtrl.text.trim();
                          existing.category = category;
                          existing.targetDate = targetDate;
                          existing.progress = progress;
                          await StorageService.updateGoal(existing);
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                        _loadGoals();
                      },
                      child: Text(existing == null ? 'Add Goal' : 'Save Changes'),
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
