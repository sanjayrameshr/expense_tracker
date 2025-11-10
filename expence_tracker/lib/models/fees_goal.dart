import 'package:hive/hive.dart';

part 'fees_goal.g.dart';

@HiveType(typeId: 4)
class FeesGoal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double targetAmount;

  @HiveField(3)
  double currentAmount;

  @HiveField(4)
  DateTime dueDate;

  @HiveField(5)
  DateTime createdAt;

  FeesGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.dueDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Calculate remaining amount needed
  double get remainingAmount => targetAmount - currentAmount;

  /// Calculate months left until due date
  int get monthsLeft {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    return (difference.inDays / 30).ceil();
  }

  /// Calculate monthly saving required to meet goal
  double get requiredMonthlySaving {
    final months = monthsLeft;
    if (months <= 0) return remainingAmount;
    return remainingAmount / months;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'dueDate': dueDate.toIso8601String(),
    'createdAt': createdAt.toIso8601String(),
  };

  factory FeesGoal.fromJson(Map<String, dynamic> json) => FeesGoal(
    id: json['id'] as String,
    name: json['name'] as String,
    targetAmount: (json['targetAmount'] as num).toDouble(),
    currentAmount: (json['currentAmount'] as num).toDouble(),
    dueDate: DateTime.parse(json['dueDate'] as String),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}
