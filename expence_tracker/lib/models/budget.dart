import 'package:hive/hive.dart';
import 'transaction.dart';

part 'budget.g.dart';

@HiveType(typeId: 5)
class Budget extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  TransactionCategory category;

  @HiveField(2)
  double monthlyLimit;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  bool isActive;

  Budget({
    required this.id,
    required this.category,
    required this.monthlyLimit,
    DateTime? createdAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Calculate total spent in current month for this category
  double getCurrentMonthSpending(List<Transaction> transactions) {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return transactions
        .where(
          (t) =>
              t.category == category &&
              t.date.isAfter(monthStart) &&
              t.date.isBefore(monthEnd),
        )
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Check if over budget
  bool isOverBudget(List<Transaction> transactions) {
    return getCurrentMonthSpending(transactions) > monthlyLimit;
  }

  /// Get remaining budget amount
  double getRemainingBudget(List<Transaction> transactions) {
    final spent = getCurrentMonthSpending(transactions);
    return monthlyLimit - spent;
  }

  /// Get budget usage percentage (0.0 to 1.0+)
  double getUsagePercentage(List<Transaction> transactions) {
    final spent = getCurrentMonthSpending(transactions);
    if (monthlyLimit == 0) return 0.0;
    return spent / monthlyLimit;
  }

  /// Get budget status color
  String getStatusColor(List<Transaction> transactions) {
    final usage = getUsagePercentage(transactions);
    if (usage >= 1.0) return 'red'; // Over budget
    if (usage >= 0.8) return 'orange'; // Warning
    return 'green'; // Safe
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category.name,
    'monthlyLimit': monthlyLimit,
    'createdAt': createdAt.toIso8601String(),
    'isActive': isActive,
  };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
    id: json['id'] as String,
    category: TransactionCategory.values.firstWhere(
      (e) => e.name == json['category'],
    ),
    monthlyLimit: (json['monthlyLimit'] as num).toDouble(),
    createdAt: DateTime.parse(json['createdAt'] as String),
    isActive: json['isActive'] as bool,
  );
}
