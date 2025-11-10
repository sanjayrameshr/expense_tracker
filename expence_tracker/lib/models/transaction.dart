import 'package:hive/hive.dart';

part 'transaction.g.dart';

/// Transaction categories
enum TransactionCategory {
  income,
  spend,
  family,
  savingsDeposit,
  loanPayment,
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

  Transaction({
    required this.id,
    required this.amount,
    required this.category,
    required this.description,
    DateTime? date,
    this.loanId,
    this.interestPortion,
    this.principalPortion,
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
    interestPortion:
        json['interestPortion'] != null
            ? (json['interestPortion'] as num).toDouble()
            : null,
    principalPortion:
        json['principalPortion'] != null
            ? (json['principalPortion'] as num).toDouble()
            : null,
  );
}
