import 'package:flutter_test/flutter_test.dart';
import 'package:expence_tracker/models/loan.dart';
import 'package:expence_tracker/models/fees_goal.dart';

void main() {
  group('Loan Model Tests', () {
    test('Loan should calculate monthly interest correctly', () {
      final loan = Loan(
        id: 'test_loan',
        name: 'Test Loan',
        initialPrincipal: 100000.0,
        currentPrincipal: 100000.0,
        interestRateAnnual: 12.0,
      );

      final monthlyInterest = loan.calculateMonthlyInterest();
      expect(monthlyInterest, 1000.0); // 100000 * 12% / 12 months = 1000
    });

    test('Loan should calculate interest for month correctly', () {
      final loan = Loan(
        id: 'test_loan',
        name: 'Gold Loan',
        initialPrincipal: 110000.0,
        currentPrincipal: 110000.0,
        interestRateAnnual: 9.0,
      );

      final interest = loan.calculateInterestForMonth();
      expect(interest, 825.0); // 110000 * 9% / 12 = 825
    });

    test('Loan toJson and fromJson should work correctly', () {
      final loan = Loan(
        id: 'test_loan',
        name: 'Test Loan',
        initialPrincipal: 50000.0,
        currentPrincipal: 40000.0,
        interestRateAnnual: 10.0,
        startDate: DateTime(2024, 1, 1),
      );

      final json = loan.toJson();
      final parsedLoan = Loan.fromJson(json);

      expect(parsedLoan.id, loan.id);
      expect(parsedLoan.name, loan.name);
      expect(parsedLoan.initialPrincipal, loan.initialPrincipal);
      expect(parsedLoan.currentPrincipal, loan.currentPrincipal);
      expect(parsedLoan.interestRateAnnual, loan.interestRateAnnual);
    });
  });

  group('FeesGoal Model Tests', () {
    test('FeesGoal should calculate remaining amount correctly', () {
      final goal = FeesGoal(
        id: 'test_goal',
        name: 'College Fees',
        targetAmount: 50000.0,
        currentAmount: 20000.0,
        dueDate: DateTime.now().add(const Duration(days: 180)),
      );

      expect(goal.remainingAmount, 30000.0);
    });

    test('FeesGoal should calculate months left correctly', () {
      final goal = FeesGoal(
        id: 'test_goal',
        name: 'College Fees',
        targetAmount: 50000.0,
        dueDate: DateTime.now().add(const Duration(days: 90)),
      );

      expect(goal.monthsLeft, greaterThanOrEqualTo(3));
    });

    test('FeesGoal should calculate required monthly saving', () {
      final goal = FeesGoal(
        id: 'test_goal',
        name: 'College Fees',
        targetAmount: 60000.0,
        currentAmount: 0.0,
        dueDate: DateTime.now().add(const Duration(days: 180)), // ~6 months
      );

      final requiredSaving = goal.requiredMonthlySaving;
      expect(requiredSaving, greaterThan(0));
      expect(requiredSaving, lessThanOrEqualTo(10000.0));
    });

    test('FeesGoal toJson and fromJson should work correctly', () {
      final goal = FeesGoal(
        id: 'test_goal',
        name: 'Test Goal',
        targetAmount: 45000.0,
        currentAmount: 5000.0,
        dueDate: DateTime(2026, 4, 30),
        createdAt: DateTime(2025, 1, 1),
      );

      final json = goal.toJson();
      final parsedGoal = FeesGoal.fromJson(json);

      expect(parsedGoal.id, goal.id);
      expect(parsedGoal.name, goal.name);
      expect(parsedGoal.targetAmount, goal.targetAmount);
      expect(parsedGoal.currentAmount, goal.currentAmount);
    });
  });
}
