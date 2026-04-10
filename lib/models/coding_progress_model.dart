import 'package:hive/hive.dart';

part 'coding_progress_model.g.dart';

@HiveType(typeId: 3)
class CodingProgressModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String platform; // LeetCode, CodeChef, HackerRank

  @HiveField(2)
  int problemsSolved;

  @HiveField(3)
  int dailyGoal;

  @HiveField(4)
  int totalGoal;

  @HiveField(5)
  DateTime lastUpdated;

  @HiveField(6)
  List<int> weeklyHistory; // problems solved per day last 7 days

  CodingProgressModel({
    required this.id,
    required this.platform,
    this.problemsSolved = 0,
    this.dailyGoal = 2,
    this.totalGoal = 100,
    required this.lastUpdated,
    List<int>? weeklyHistory,
  }) : weeklyHistory = weeklyHistory ?? List.filled(7, 0);

  double get progressPercent =>
      totalGoal > 0 ? (problemsSolved / totalGoal).clamp(0.0, 1.0) : 0.0;

  double get dailyProgressPercent =>
      dailyGoal > 0
          ? ((weeklyHistory.isNotEmpty ? weeklyHistory.last : 0) / dailyGoal)
              .clamp(0.0, 1.0)
          : 0.0;
}
