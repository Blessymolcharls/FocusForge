import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../models/goal_model.dart';
import '../models/assignment_model.dart';
import '../models/coding_progress_model.dart';

class StorageService {
  static const String _taskBoxName = 'tasks';
  static const String _goalBoxName = 'goals';
  static const String _assignmentBoxName = 'assignments';
  static const String _codingBoxName = 'coding_progress';
  static const String _xpKey = 'total_xp';
  static const String _streakKey = 'productivity_streak';
  static const String _lastActiveKey = 'last_active_date';

  static final _uuid = const Uuid();

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(TaskModelAdapter());
    Hive.registerAdapter(GoalModelAdapter());
    Hive.registerAdapter(AssignmentModelAdapter());
    Hive.registerAdapter(CodingProgressModelAdapter());

    await Hive.openBox<TaskModel>(_taskBoxName);
    await Hive.openBox<GoalModel>(_goalBoxName);
    await Hive.openBox<AssignmentModel>(_assignmentBoxName);
    await Hive.openBox<CodingProgressModel>(_codingBoxName);

    await _seedSampleData();
    await _updateStreak();
  }

  // ─── Task Operations ────────────────────────────────────────────────────────

  static Box<TaskModel> get _taskBox => Hive.box<TaskModel>(_taskBoxName);

  static List<TaskModel> getAllTasks() => _taskBox.values.toList();

  static List<TaskModel> getTodayTasks() {
    final now = DateTime.now();
    return _taskBox.values.where((t) {
      final d = t.dueDate;
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }).toList();
  }

  static Future<void> addTask(TaskModel task) async {
    await _taskBox.put(task.id, task);
  }

  static Future<void> updateTask(TaskModel task) async {
    await task.save();
  }

  static Future<void> completeTask(String id) async {
    final task = _taskBox.get(id);
    if (task != null && !task.isCompleted) {
      task.isCompleted = true;
      await task.save();
      await addXP(task.xpReward);
    }
  }

  static Future<void> deleteTask(String id) async {
    await _taskBox.delete(id);
  }

  // ─── Goal Operations ─────────────────────────────────────────────────────────

  static Box<GoalModel> get _goalBox => Hive.box<GoalModel>(_goalBoxName);

  static List<GoalModel> getAllGoals() => _goalBox.values.toList();

  static Future<void> addGoal(GoalModel goal) async {
    await _goalBox.put(goal.id, goal);
  }

  static Future<void> updateGoal(GoalModel goal) async {
    await goal.save();
  }

  static Future<void> deleteGoal(String id) async {
    await _goalBox.delete(id);
  }

  // ─── Assignment Operations ───────────────────────────────────────────────────

  static Box<AssignmentModel> get _assignmentBox =>
      Hive.box<AssignmentModel>(_assignmentBoxName);

  static List<AssignmentModel> getAllAssignments() =>
      _assignmentBox.values.toList();

  static List<AssignmentModel> getUpcomingAssignments() {
    final now = DateTime.now();
    return _assignmentBox.values
        .where((a) => !a.isCompleted && a.deadline.isAfter(now))
        .toList()
      ..sort((a, b) => a.deadline.compareTo(b.deadline));
  }

  static Future<void> addAssignment(AssignmentModel assignment) async {
    await _assignmentBox.put(assignment.id, assignment);
  }

  static Future<void> updateAssignment(AssignmentModel assignment) async {
    await assignment.save();
  }

  static Future<void> completeAssignment(String id) async {
    final a = _assignmentBox.get(id);
    if (a != null && !a.isCompleted) {
      a.isCompleted = true;
      await a.save();
      await addXP(40);
    }
  }

  static Future<void> deleteAssignment(String id) async {
    await _assignmentBox.delete(id);
  }

  // ─── Coding Progress Operations ──────────────────────────────────────────────

  static Box<CodingProgressModel> get _codingBox =>
      Hive.box<CodingProgressModel>(_codingBoxName);

  static List<CodingProgressModel> getAllCodingProgress() =>
      _codingBox.values.toList();

  static Future<void> addCodingProgress(CodingProgressModel model) async {
    await _codingBox.put(model.id, model);
  }

  static Future<void> updateCodingProgress(CodingProgressModel model) async {
    await model.save();
    await addXP(20);
  }

  static Future<void> deleteCodingProgress(String id) async {
    await _codingBox.delete(id);
  }

  // ─── XP & Streak ─────────────────────────────────────────────────────────────

  static Future<int> getTotalXP() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_xpKey) ?? 0;
  }

  static Future<void> addXP(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_xpKey) ?? 0;
    await prefs.setInt(_xpKey, current + amount);
  }

  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_streakKey) ?? 0;
  }

  static Future<void> _updateStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastActiveStr = prefs.getString(_lastActiveKey);
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    if (lastActiveStr == null) {
      await prefs.setInt(_streakKey, 1);
      await prefs.setString(_lastActiveKey, todayStr);
      return;
    }

    if (lastActiveStr == todayStr) return;

    final lastActive = DateTime.parse(lastActiveStr);
    final diff = now.difference(lastActive).inDays;
    final currentStreak = prefs.getInt(_streakKey) ?? 0;

    if (diff == 1) {
      await prefs.setInt(_streakKey, currentStreak + 1);
    } else {
      await prefs.setInt(_streakKey, 1);
    }
    await prefs.setString(_lastActiveKey, todayStr);
  }

  // ─── Daily Productivity ───────────────────────────────────────────────────────

  static double getDailyProductivity() {
    final today = getTodayTasks();
    if (today.isEmpty) return 0.0;
    final completed = today.where((t) => t.isCompleted).length;
    return completed / today.length;
  }

  // ─── Sample Data Seeder ───────────────────────────────────────────────────────

  static Future<void> _seedSampleData() async {
    if (_taskBox.isNotEmpty) return; // Already seeded

    final now = DateTime.now();

    // Sample Tasks
    final sampleTasks = [
      TaskModel(
        id: _uuid.v4(),
        title: 'Solve 2 LeetCode problems',
        category: 'Coding',
        dueDate: now,
        estimatedMinutes: 60,
        xpReward: 20,
        createdAt: now,
      ),
      TaskModel(
        id: _uuid.v4(),
        title: 'Study GATE Data Structures',
        category: 'Study',
        dueDate: now,
        estimatedMinutes: 90,
        xpReward: 30,
        createdAt: now,
      ),
      TaskModel(
        id: _uuid.v4(),
        title: 'Complete OS Assignment',
        category: 'Assignment',
        dueDate: now.add(const Duration(days: 2)),
        estimatedMinutes: 45,
        xpReward: 40,
        createdAt: now,
      ),
      TaskModel(
        id: _uuid.v4(),
        title: 'Mock Interview Practice',
        category: 'Study',
        dueDate: now,
        estimatedMinutes: 60,
        xpReward: 30,
        createdAt: now,
        isCompleted: true,
      ),
    ];

    for (final task in sampleTasks) {
      await _taskBox.put(task.id, task);
    }

    // Sample Goals
    final sampleGoals = [
      GoalModel(
        id: _uuid.v4(),
        title: 'IBM Placement Prep',
        description: 'Prepare for IBM campus placement exams and interviews',
        category: 'IBM',
        targetDate: now.add(const Duration(days: 90)),
        progress: 0.3,
        createdAt: now,
      ),
      GoalModel(
        id: _uuid.v4(),
        title: 'GATE 2026 Preparation',
        description: 'Complete GATE CS syllabus and practice previous papers',
        category: 'GATE',
        targetDate: DateTime(2026, 2, 1),
        progress: 0.2,
        createdAt: now,
      ),
      GoalModel(
        id: _uuid.v4(),
        title: 'LeetCode 150 Problems',
        description: 'Solve top 150 interview problems on LeetCode',
        category: 'Coding',
        targetDate: now.add(const Duration(days: 60)),
        progress: 0.15,
        createdAt: now,
      ),
      GoalModel(
        id: _uuid.v4(),
        title: 'Complete Semester Assignments',
        description: 'Submit all pending college assignments on time',
        category: 'Assignments',
        targetDate: now.add(const Duration(days: 30)),
        progress: 0.5,
        createdAt: now,
      ),
    ];

    for (final goal in sampleGoals) {
      await _goalBox.put(goal.id, goal);
    }

    // Sample Assignments
    final sampleAssignments = [
      AssignmentModel(
        id: _uuid.v4(),
        subjectName: 'Operating Systems',
        title: 'Process Scheduling Report',
        deadline: now.add(const Duration(days: 3)),
        createdAt: now,
      ),
      AssignmentModel(
        id: _uuid.v4(),
        subjectName: 'Database Management',
        title: 'ER Diagram Submission',
        deadline: now.add(const Duration(days: 7)),
        createdAt: now,
      ),
      AssignmentModel(
        id: _uuid.v4(),
        subjectName: 'Computer Networks',
        title: 'TCP/IP Lab Report',
        deadline: now.add(const Duration(days: 1)),
        createdAt: now,
      ),
      AssignmentModel(
        id: _uuid.v4(),
        subjectName: 'Software Engineering',
        title: 'UML Design Document',
        deadline: now.add(const Duration(days: 14)),
        createdAt: now,
      ),
    ];

    for (final a in sampleAssignments) {
      await _assignmentBox.put(a.id, a);
    }

    // Sample Coding Progress
    final sampleCoding = [
      CodingProgressModel(
        id: _uuid.v4(),
        platform: 'LeetCode',
        problemsSolved: 45,
        dailyGoal: 2,
        totalGoal: 150,
        lastUpdated: now,
        weeklyHistory: [1, 2, 3, 2, 1, 3, 2],
      ),
      CodingProgressModel(
        id: _uuid.v4(),
        platform: 'CodeChef',
        problemsSolved: 30,
        dailyGoal: 1,
        totalGoal: 100,
        lastUpdated: now,
        weeklyHistory: [1, 0, 1, 2, 1, 0, 1],
      ),
      CodingProgressModel(
        id: _uuid.v4(),
        platform: 'HackerRank',
        problemsSolved: 52,
        dailyGoal: 2,
        totalGoal: 100,
        lastUpdated: now,
        weeklyHistory: [2, 2, 1, 3, 2, 1, 2],
      ),
    ];

    for (final c in sampleCoding) {
      await _codingBox.put(c.id, c);
    }

    // Give some initial XP
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_xpKey)) {
      await prefs.setInt(_xpKey, 350);
      await prefs.setInt(_streakKey, 5);
    }
  }

  static String generateId() => _uuid.v4();
}
