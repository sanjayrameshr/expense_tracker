import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_settings.dart';
import '../models/transaction.dart';
import '../models/loan.dart';
import '../models/fees_goal.dart';
import '../models/budget.dart';

/// Service for managing Hive storage
class StorageService {
  static const String _settingsBox = 'settings';
  static const String _transactionsBox = 'transactions';
  static const String _loansBox = 'loans';
  static const String _feesGoalsBox = 'feesGoals';
  static const String _budgetsBox = 'budgets';

  // User Settings
  Future<UserSettings?> getUserSettings() async {
    final box = await Hive.openBox<UserSettings>(_settingsBox);
    return box.get('user_settings');
  }

  Future<void> saveUserSettings(UserSettings settings) async {
    final box = await Hive.openBox<UserSettings>(_settingsBox);
    await box.put('user_settings', settings);
  }

  // Transactions
  Future<List<Transaction>> getTransactions() async {
    final box = await Hive.openBox<Transaction>(_transactionsBox);
    return box.values.toList();
  }

  Future<void> saveTransaction(Transaction transaction) async {
    final box = await Hive.openBox<Transaction>(_transactionsBox);
    await box.put(transaction.id, transaction);
  }

  Future<void> deleteTransaction(String id) async {
    final box = await Hive.openBox<Transaction>(_transactionsBox);
    await box.delete(id);
  }

  // Loans
  Future<List<Loan>> getLoans() async {
    final box = await Hive.openBox<Loan>(_loansBox);
    return box.values.toList();
  }

  Future<void> saveLoan(Loan loan) async {
    final box = await Hive.openBox<Loan>(_loansBox);
    await box.put(loan.id, loan);
  }

  Future<void> updateLoan(Loan loan) async {
    await saveLoan(loan);
  }

  Future<void> deleteLoan(String id) async {
    final box = await Hive.openBox<Loan>(_loansBox);
    await box.delete(id);
  }

  // Fees Goals
  Future<List<FeesGoal>> getFeesGoals() async {
    final box = await Hive.openBox<FeesGoal>(_feesGoalsBox);
    return box.values.toList();
  }

  Future<void> saveFeesGoal(FeesGoal goal) async {
    final box = await Hive.openBox<FeesGoal>(_feesGoalsBox);
    await box.put(goal.id, goal);
  }

  Future<void> updateFeesGoal(FeesGoal goal) async {
    await saveFeesGoal(goal);
  }

  Future<void> deleteFeesGoal(String id) async {
    final box = await Hive.openBox<FeesGoal>(_feesGoalsBox);
    await box.delete(id);
  }

  // Clear all data
  Future<void> clearAll() async {
    await Hive.deleteBoxFromDisk(_transactionsBox);
    await Hive.deleteBoxFromDisk(_loansBox);
    await Hive.deleteBoxFromDisk(_feesGoalsBox);
    await Hive.deleteBoxFromDisk(_budgetsBox);
  }

  // Budgets
  Future<List<Budget>> getBudgets() async {
    final box = await Hive.openBox<Budget>(_budgetsBox);
    return box.values.toList();
  }

  Future<void> saveBudget(Budget budget) async {
    final box = await Hive.openBox<Budget>(_budgetsBox);
    await box.put(budget.id, budget);
  }

  Future<void> updateBudget(Budget budget) async {
    await saveBudget(budget);
  }

  Future<void> deleteBudget(String id) async {
    final box = await Hive.openBox<Budget>(_budgetsBox);
    await box.delete(id);
  }
}
