import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/storage_service.dart';
import '../models/task_model.dart';
import '../models/assignment_model.dart';
import '../widgets/app_theme.dart';
import '../widgets/common_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _totalXP = 0;
  int _streak = 0;
  List<TaskModel> _todayTasks = [];
  List<AssignmentModel> _upcomingAssignments = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final xp = await StorageService.getTotalXP();
    final streak = await StorageService.getStreak();
    setState(() {
      _totalXP = xp;
      _streak = streak;
      _todayTasks = StorageService.getTodayTasks();
      _upcomingAssignments = StorageService.getUpcomingAssignments().take(3).toList();
    });
  }

  int get _completedToday =>
      _todayTasks.where((t) => t.isCompleted).length;

  double get _dailyProgress =>
      _todayTasks.isEmpty ? 0 : _completedToday / _todayTasks.length;

  String get _level {
    if (_totalXP < 500) return 'Beginner';
    if (_totalXP < 1500) return 'Learner';
    if (_totalXP < 3000) return 'Scholar';
    if (_totalXP < 6000) return 'Expert';
    return 'Master';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: RefreshIndicator(
        onRefresh: _load,
        color: AppTheme.primary,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const MotivationalBanner(),
                  const SizedBox(height: 20),
                  _buildStatsRow(),
                  const SizedBox(height: 20),
                  _buildDailyProgress(),
                  const SizedBox(height: 20),
                  _buildGoalsOverview(),
                  const SizedBox(height: 20),
                  _buildTodayTasks(),
                  const SizedBox(height: 20),
                  _buildUpcomingDeadlines(),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    final now = DateTime.now();
    return SliverAppBar(
      expandedHeight: 140,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primary, AppTheme.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Good ${_greeting()}, Blessy! 👋',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEEE, MMMM d').format(now),
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.military_tech,
                          color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '$_level • $_totalXP XP',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.local_fire_department,
                          color: Colors.orange, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '$_streak day streak',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  Widget _buildStatsRow() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        StatCard(
          title: 'Tasks Today',
          value: '$_completedToday/${_todayTasks.length}',
          icon: Icons.task_alt,
          color: AppTheme.studyColor,
        ),
        StatCard(
          title: 'Total XP',
          value: '$_totalXP',
          icon: Icons.star,
          color: Colors.amber,
        ),
        StatCard(
          title: 'Day Streak',
          value: '$_streak 🔥',
          icon: Icons.local_fire_department,
          color: Colors.orange,
        ),
        StatCard(
          title: 'Deadlines',
          value: '${_upcomingAssignments.length}',
          icon: Icons.assignment_late,
          color: AppTheme.accent,
        ),
      ],
    );
  }

  Widget _buildDailyProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Daily Progress'),
        const SizedBox(height: 12),
        ProgressBarCard(
          label: "Today's Productivity",
          progress: _dailyProgress,
          color: AppTheme.primary,
          subtitle: '$_completedToday of ${_todayTasks.length} tasks done',
        ),
      ],
    );
  }

  Widget _buildGoalsOverview() {
    final goals = StorageService.getAllGoals();
    if (goals.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Goals Overview'),
        const SizedBox(height: 12),
        ...goals.take(3).map(
              (g) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: ProgressBarCard(
                  label: g.title,
                  progress: g.progress,
                  color: AppTheme.categoryColor(g.category),
                  subtitle: g.category,
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildTodayTasks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: "Today's Tasks"),
        const SizedBox(height: 12),
        if (_todayTasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text(
                'No tasks for today. Add some!',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          )
        else
          ...(_todayTasks.take(4).map((task) => _buildTaskTile(task))),
      ],
    );
  }

  Widget _buildTaskTile(TaskModel task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(
            color: AppTheme.categoryColor(task.category),
            width: 3,
          ),
        ),
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: GestureDetector(
          onTap: () => _toggleTask(task),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: task.isCompleted
                  ? AppTheme.studyColor
                  : Colors.transparent,
              border: Border.all(
                color: task.isCompleted
                    ? AppTheme.studyColor
                    : AppTheme.textSecondary,
                width: 2,
              ),
            ),
            child: task.isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            color: task.isCompleted
                ? AppTheme.textSecondary
                : AppTheme.textPrimary,
            decoration:
                task.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Row(
          children: [
            CategoryBadge(category: task.category),
            const SizedBox(width: 8),
            Text(
              '~${task.estimatedMinutes}min',
              style: const TextStyle(
                  color: AppTheme.textSecondary, fontSize: 11),
            ),
          ],
        ),
        trailing: Text(
          '+${task.xpReward} XP',
          style: TextStyle(
            color: Colors.amber.withAlpha(180),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _toggleTask(TaskModel task) async {
    if (!task.isCompleted) {
      await StorageService.completeTask(task.id);
    } else {
      task.isCompleted = false;
      await StorageService.updateTask(task);
    }
    await _load();
  }

  Widget _buildUpcomingDeadlines() {
    if (_upcomingAssignments.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Upcoming Deadlines'),
        const SizedBox(height: 12),
        ..._upcomingAssignments.map((a) => _buildDeadlineTile(a)),
      ],
    );
  }

  Widget _buildDeadlineTile(AssignmentModel a) {
    final days = a.daysUntilDeadline;
    final urgentColor =
        days <= 1 ? AppTheme.accent : days <= 3 ? Colors.orange : AppTheme.secondary;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: urgentColor.withAlpha(40),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.assignment, color: urgentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.title,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  a.subjectName,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: urgentColor.withAlpha(40),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              days == 0
                  ? 'Today!'
                  : days == 1
                      ? 'Tomorrow'
                      : 'In $days days',
              style: TextStyle(
                color: urgentColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
