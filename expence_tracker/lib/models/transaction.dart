import 'package:hive/hive.dart';

part 'transaction.g.dart';

/// Transaction categories
@HiveType(typeId: 10)
enum TransactionCategory {
  @HiveField(0)
  income,
  @HiveField(1)
  spend,
  @HiveField(2)
  family,
  @HiveField(3)
  savingsDeposit,
  @HiveField(4)
  loanPayment,
  @HiveField(5)
  feePayment,
}

@HiveType(typeId: 1)
class Transaction extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double amount;

  @HiveField(2)
  TransactionCategory category;

  @HiveField(3)
  String description;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  String? loanId; // Reference to loan if category is loanPayment

  @HiveField(6)
  double? interestPortion; // For loan payments: interest amount

  @HiveField(7)
  double? principalPortion; // For loan payments: principal amount

  // --- NEW FIELD ---
  @HiveField(8)
  String? feesGoalId; // Reference to fees goal if category is feePayment

  Transaction({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
    DateTime? date,
    this.loanId,
    this.interestPortion,
    this.principalPortion,
    this.feesGoalId, // Added to constructor
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'category': category.name,
        'description': description,
        'date': date.toIso8601String(),
        'loanId': loanId,
        'interestPortion': interestPortion,
        'principalPortion': principalPortion,
        'feesGoalId': feesGoalId, // Added to JSON
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        category: TransactionCategory.values.firstWhere(
          (e) => e.name == json['category'],
        ),
        description: json['description'] as String,
        date: DateTime.parse(json['date'] as String),
        loanId: json['loanId'] as String?,
        interestPortion: json['interestPortion'] != null
            ? (json['interestPortion'] as num).toDouble()
            : null,
        principalPortion: json['principalPortion'] != null
            ? (json['principalPortion'] as num).toDouble()
            : null,
        feesGoalId: json['feesGoalId'] as String?, // Added from JSON
      );
}
