import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task_model.dart';
import '../services/storage_service.dart';
import '../services/notification_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/common_widgets.dart';

class TaskPlannerScreen extends StatefulWidget {
  const TaskPlannerScreen({super.key});

  @override
  State<TaskPlannerScreen> createState() => _TaskPlannerScreenState();
}

class _TaskPlannerScreenState extends State<TaskPlannerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<TaskModel> _allTasks = [];
  String _filterCategory = 'All';

  final List<String> _categories = [
    'All', 'Study', 'Coding', 'Assignment', 'Personal'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadTasks() {
    setState(() {
      _allTasks = StorageService.getAllTasks();
    });
  }

  List<TaskModel> get _todayTasks {
    final today = StorageService.getTodayTasks();
    return _filterCategory == 'All'
        ? today
        : today.where((t) => t.category == _filterCategory).toList();
  }

  List<TaskModel> get _allFilteredTasks {
    return _filterCategory == 'All'
        ? _allTasks
        : _allTasks.where((t) => t.category == _filterCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Task Planner'),
        backgroundColor: AppTheme.surface,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
          tabs: const [
            Tab(text: "Today"),
            Tab(text: "All Tasks"),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList(_todayTasks, showEmpty: "No tasks for today!"),
                _buildTaskList(_allFilteredTasks, showEmpty: "No tasks found."),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      color: AppTheme.surface,
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final cat = _categories[i];
          final selected = cat == _filterCategory;
          return GestureDetector(
            onTap: () => setState(() => _filterCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primary : AppTheme.cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                cat,
                style: TextStyle(
                  color: selected ? Colors.white : AppTheme.textSecondary,
                  fontWeight:
                      selected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTaskList(List<TaskModel> tasks, {required String showEmpty}) {
    if (tasks.isEmpty) {
      return EmptyStateWidget(
        message: showEmpty,
        icon: Icons.check_circle_outline,
        actionLabel: 'Add Task',
        onAction: _showAddTaskDialog,
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadTasks(),
      color: AppTheme.primary,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: tasks.length,
        itemBuilder: (_, i) => _buildTaskCard(tasks[i]),
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    final catColor = AppTheme.categoryColor(task.category);
    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.accent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) async {
        await StorageService.deleteTask(task.id);
        _loadTasks();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border(left: BorderSide(color: catColor, width: 4)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _showTaskDetails(task),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _toggleComplete(task),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: task.isCompleted ? AppTheme.studyColor : Colors.transparent,
                      border: Border.all(
                        color: task.isCompleted ? AppTheme.studyColor : AppTheme.textSecondary,
                        width: 2,
                      ),
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 18)
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          color: task.isCompleted
                              ? AppTheme.textSecondary
                              : AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          CategoryBadge(category: task.category),
                          const SizedBox(width: 8),
                          Icon(Icons.access_time,
                              size: 12, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            '${task.estimatedMinutes}min',
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 11),
                          ),
                          const SizedBox(width: 8),
                          Icon(Icons.calendar_today,
                              size: 12, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM d').format(task.dueDate),
                            style: const TextStyle(
                                color: AppTheme.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  '+${task.xpReward}XP',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _toggleComplete(TaskModel task) async {
    if (!task.isCompleted) {
      await StorageService.completeTask(task.id);
    } else {
      task.isCompleted = false;
      await StorageService.updateTask(task);
    }
    _loadTasks();
  }

  void _showTaskDetails(TaskModel task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(task.title,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(children: [
              CategoryBadge(category: task.category),
              const SizedBox(width: 10),
              Text('${task.xpReward} XP reward',
                  style: const TextStyle(color: Colors.amber)),
            ]),
            const SizedBox(height: 16),
            _detailRow(Icons.calendar_today, 'Due',
                DateFormat('EEEE, MMM d, yyyy').format(task.dueDate)),
            const SizedBox(height: 8),
            _detailRow(Icons.access_time, 'Duration',
                '${task.estimatedMinutes} minutes'),
            if (task.reminderTime != null) ...[
              const SizedBox(height: 8),
              _detailRow(Icons.alarm, 'Reminder',
                  DateFormat('hh:mm a').format(task.reminderTime!)),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: task.isCompleted
                    ? null
                    : () async {
                        Navigator.pop(context);
                        await _toggleComplete(task);
                      },
                icon: const Icon(Icons.check_circle),
                label: Text(task.isCompleted ? 'Completed!' : 'Mark Complete'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primary, size: 18),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: AppTheme.textSecondary)),
        Text(value,
            style: const TextStyle(
                color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // ─── Add Task Dialog ──────────────────────────────────────────────────────────

  final _titleCtrl = TextEditingController();

  void _showAddTaskDialog() {
    _titleCtrl.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddTaskSheet(
        titleCtrl: _titleCtrl,
        onSave: _saveTask,
      ),
    );
  }

  Future<void> _saveTask({
    required String title,
    required String category,
    required DateTime dueDate,
    required int durationMinutes,
    required int xpReward,
    DateTime? reminderTime,
  }) async {
    final task = TaskModel(
      id: StorageService.generateId(),
      title: title,
      category: category,
      dueDate: dueDate,
      reminderTime: reminderTime,
      estimatedMinutes: durationMinutes,
      xpReward: xpReward,
      createdAt: DateTime.now(),
    );

    await StorageService.addTask(task);

    if (reminderTime != null && reminderTime.isAfter(DateTime.now())) {
      await NotificationService.scheduleTaskReminder(
        id: task.id.hashCode,
        taskTitle: title,
        reminderTime: reminderTime,
      );
    }

    _loadTasks();
  }
}

// ─── Add Task Sheet (stateful) ────────────────────────────────────────────────

class _AddTaskSheet extends StatefulWidget {
  final TextEditingController titleCtrl;
  final Future<void> Function({
    required String title,
    required String category,
    required DateTime dueDate,
    required int durationMinutes,
    required int xpReward,
    DateTime? reminderTime,
  }) onSave;

  const _AddTaskSheet({required this.titleCtrl, required this.onSave});

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  String _category = 'Study';
  DateTime _dueDate = DateTime.now();
  DateTime? _reminderTime;
  int _duration = 30;
  int _xp = 30;
  final _formKey = GlobalKey<FormState>();

  final List<String> _categories = ['Study', 'Coding', 'Assignment', 'Personal'];
  final Map<String, int> _xpMap = {
    'Study': 30, 'Coding': 20, 'Assignment': 40, 'Personal': 15
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('New Task',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextFormField(
                controller: widget.titleCtrl,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Task Title',
                  prefixIcon: Icon(Icons.edit, color: AppTheme.primary),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter a task title' : null,
              ),
              const SizedBox(height: 14),
              _label('Category'),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final sel = cat == _category;
                    final col = AppTheme.categoryColor(cat);
                    return GestureDetector(
                      onTap: () => setState(() {
                        _category = cat;
                        _xp = _xpMap[cat] ?? 30;
                      }),
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
                        child: Text(cat,
                            style: TextStyle(
                              color: sel ? Colors.white : col,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _infoTile(
                      icon: Icons.calendar_today,
                      label: 'Due Date',
                      value: DateFormat('MMM d').format(_dueDate),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _dueDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) setState(() => _dueDate = picked);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _infoTile(
                      icon: Icons.alarm,
                      label: 'Reminder',
                      value: _reminderTime != null
                          ? DateFormat('hh:mm a').format(_reminderTime!)
                          : 'None',
                      onTap: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (picked != null) {
                          final now = DateTime.now();
                          setState(() => _reminderTime = DateTime(
                              now.year, now.month, now.day,
                              picked.hour, picked.minute));
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _label('Duration: $_duration minutes'),
              Slider(
                value: _duration.toDouble(),
                min: 15,
                max: 180,
                divisions: 11,
                activeColor: AppTheme.primary,
                onChanged: (v) => setState(() => _duration = v.toInt()),
              ),
              const SizedBox(height: 4),
              Text('XP Reward: +$_xp',
                  style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Add Task'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(text,
            style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 13)),
      );

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.primary.withAlpha(80)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primary, size: 16),
                const SizedBox(width: 6),
                Text(label,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context);
    widget.onSave(
      title: widget.titleCtrl.text.trim(),
      category: _category,
      dueDate: _dueDate,
      durationMinutes: _duration,
      xpReward: _xp,
      reminderTime: _reminderTime,
    );
  }
}
