import 'package:hive/hive.dart';

part 'goal_model.g.dart';

@HiveType(typeId: 1)
class GoalModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String category; // IBM, GATE, Coding, Assignments

  @HiveField(4)
  DateTime targetDate;

  @HiveField(5)
  double progress; // 0.0 to 1.0

  @HiveField(6)
  List<String> subtaskIds;

  @HiveField(7)
  bool isCompleted;

  @HiveField(8)
  DateTime createdAt;

  GoalModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.targetDate,
    this.progress = 0.0,
    List<String>? subtaskIds,
    this.isCompleted = false,
    required this.createdAt,
  }) : subtaskIds = subtaskIds ?? [];
}
