import 'package:hive/hive.dart';

part 'task_model.g.dart';

@HiveType(typeId: 0)
class TaskModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String category; // Study, Coding, Assignment, Personal

  @HiveField(3)
  DateTime dueDate;

  @HiveField(4)
  DateTime? reminderTime;

  @HiveField(5)
  int estimatedMinutes;

  @HiveField(6)
  bool isCompleted;

  @HiveField(7)
  int xpReward;

  @HiveField(8)
  DateTime createdAt;

  TaskModel({
    required this.id,
    required this.title,
    required this.category,
    required this.dueDate,
    this.reminderTime,
    this.estimatedMinutes = 30,
    this.isCompleted = false,
    this.xpReward = 20,
    required this.createdAt,
  });
}
