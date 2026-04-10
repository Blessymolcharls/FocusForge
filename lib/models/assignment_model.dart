import 'package:hive/hive.dart';

part 'assignment_model.g.dart';

@HiveType(typeId: 2)
class AssignmentModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String subjectName;

  @HiveField(2)
  String title;

  @HiveField(3)
  DateTime deadline;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  String notes;

  @HiveField(6)
  DateTime createdAt;

  AssignmentModel({
    required this.id,
    required this.subjectName,
    required this.title,
    required this.deadline,
    this.isCompleted = false,
    this.notes = '',
    required this.createdAt,
  });

  bool get isOverdue =>
      !isCompleted && deadline.isBefore(DateTime.now());

  int get daysUntilDeadline =>
      deadline.difference(DateTime.now()).inDays;
}
