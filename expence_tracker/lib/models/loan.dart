import 'package:hive/hive.dart';

part 'loan.g.dart';

@HiveType(typeId: 2)
class Loan extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double initialPrincipal;

  @HiveField(3)
  double currentPrincipal;

  @HiveField(4)
  double interestRateAnnual; // e.g., 9.0 for 9%

  @HiveField(5)
  DateTime startDate;

  @HiveField(6)
  List<LoanPayment> payments;

  Loan({
    required this.id,
    required this.name,
    required this.initialPrincipal,
    required this.currentPrincipal,
    required this.interestRateAnnual,
    DateTime? startDate,
    List<LoanPayment>? payments,
  }) : startDate = startDate ?? DateTime.now(),
       payments = payments ?? [];

  /// Calculate monthly interest on current principal
  double calculateMonthlyInterest() {
    return (currentPrincipal * interestRateAnnual / 100) / 12;
  }

  /// Calculate interest for a given month (30 days)
  double calculateInterestForMonth() {
    return calculateMonthlyInterest();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'initialPrincipal': initialPrincipal,
    'currentPrincipal': currentPrincipal,
    'interestRateAnnual': interestRateAnnual,
    'startDate': startDate.toIso8601String(),
    'payments': payments.map((p) => p.toJson()).toList(),
  };

  factory Loan.fromJson(Map<String, dynamic> json) => Loan(
    id: json['id'] as String,
    name: json['name'] as String,
    initialPrincipal: (json['initialPrincipal'] as num).toDouble(),
    currentPrincipal: (json['currentPrincipal'] as num).toDouble(),
    interestRateAnnual: (json['interestRateAnnual'] as num).toDouble(),
    startDate: DateTime.parse(json['startDate'] as String),
    payments:
        (json['payments'] as List)
            .map((p) => LoanPayment.fromJson(p as Map<String, dynamic>))
            .toList(),
  );
}

@HiveType(typeId: 3)
class LoanPayment extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  double amount;

  @HiveField(2)
  double interestPortion;

  @HiveField(3)
  double principalPortion;

  @HiveField(4)
  DateTime date;

  @HiveField(5)
  String transactionId; // Link back to transaction

  LoanPayment({
    required this.id,
    required this.amount,
    required this.interestPortion,
    required this.principalPortion,
    DateTime? date,
    required this.transactionId,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'amount': amount,
    'interestPortion': interestPortion,
    'principalPortion': principalPortion,
    'date': date.toIso8601String(),
    'transactionId': transactionId,
  };

  factory LoanPayment.fromJson(Map<String, dynamic> json) => LoanPayment(
    id: json['id'] as String,
    amount: (json['amount'] as num).toDouble(),
    interestPortion: (json['interestPortion'] as num).toDouble(),
    principalPortion: (json['principalPortion'] as num).toDouble(),
    date: DateTime.parse(json['date'] as String),
    transactionId: json['transactionId'] as String,
  );
}
