import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/loan.dart';
import '../models/fees_goal.dart';
import '../models/budget.dart';
import '../services/storage_service.dart';

/// Manages all finance-related data and operations
class FinanceProvider extends ChangeNotifier {
  final StorageService _storage;

  List<Transaction> _transactions = [];
  List<Loan> _loans = [];
  List<FeesGoal> _feesGoals = [];
  List<Budget> _budgets = [];

  FinanceProvider(this._storage);

  List<Transaction> get transactions => _transactions;
  List<Loan> get loans => _loans;
  List<FeesGoal> get feesGoals => _feesGoals;
  List<Budget> get budgets => _budgets;

  /// Initialize data
  Future<void> initialize() async {
    await loadData();
  }

  /// Load all data from storage
  Future<void> loadData() async {
    _transactions = await _storage.getTransactions();
    _loans = await _storage.getLoans();
    _feesGoals = await _storage.getFeesGoals();
    _budgets = await _storage.getBudgets();
    notifyListeners();
  }

  /// Calculate current cash balance
  /// Balance = income + loan_payment (from external source) - spend - family - savings_deposit - loan_payment (actual) - fee_payment
  double get cashBalance {
    double balance = 0.0;
    for (var txn in _transactions) {
      switch (txn.category) {
        case TransactionCategory.income:
          balance += txn.amount;
          break;
        case TransactionCategory.spend:
        case TransactionCategory.family:
        case TransactionCategory.savingsDeposit:
        case TransactionCategory.loanPayment:
        case TransactionCategory.feePayment:
          balance -= txn.amount;
          break;
      }
    }
    return balance;
  }

  /// Add transaction
  Future<void> addTransaction(Transaction transaction) async {
    await _storage.saveTransaction(transaction);
    _transactions.add(transaction);

    // If it's a loan payment, update loan and create loan payment record
    if (transaction.category == TransactionCategory.loanPayment &&
        transaction.loanId != null) {
      final loan = _loans.firstWhere((l) => l.id == transaction.loanId);

      // Create loan payment record
      final loanPayment = LoanPayment(
        id: '${transaction.id}_payment',
        amount: transaction.amount,
        interestPortion: transaction.interestPortion ?? 0.0,
        principalPortion: transaction.principalPortion ?? 0.0,
        date: transaction.date,
        transactionId: transaction.id,
      );

      loan.payments.add(loanPayment);
      loan.currentPrincipal -= loanPayment.principalPortion;
      await _storage.updateLoan(loan);
    }

    // If it's a fee payment, update fees goal
    if (transaction.category == TransactionCategory.feePayment) {
      for (var goal in _feesGoals) {
        if (goal.remainingAmount > 0) {
          goal.currentAmount += transaction.amount;
          await _storage.updateFeesGoal(goal);
          break;
        }
      }
    }

    notifyListeners();
  }

  /// Calculate loan payment split (interest-first allocation)
  /// Returns [interestPortion, principalPortion]
  List<double> calculateLoanPaymentSplit(Loan loan, double paymentAmount) {
    // Calculate monthly interest on current principal
    final monthlyInterest = loan.calculateMonthlyInterest();

    // Interest-first: pay interest first, remainder goes to principal
    final interestPortion =
        monthlyInterest > paymentAmount ? paymentAmount : monthlyInterest;
    final principalPortion = paymentAmount - interestPortion;

    return [interestPortion, principalPortion];
  }

  /// Add or update loan
  Future<void> saveLoan(Loan loan) async {
    final index = _loans.indexWhere((l) => l.id == loan.id);
    if (index >= 0) {
      _loans[index] = loan;
      await _storage.updateLoan(loan);
    } else {
      _loans.add(loan);
      await _storage.saveLoan(loan);
    }
    notifyListeners();
  }

  /// Delete loan
  Future<void> deleteLoan(String loanId) async {
    _loans.removeWhere((l) => l.id == loanId);
    await _storage.deleteLoan(loanId);
    notifyListeners();
  }

  /// Add or update fees goal
  Future<void> saveFeesGoal(FeesGoal goal) async {
    final index = _feesGoals.indexWhere((g) => g.id == goal.id);
    if (index >= 0) {
      _feesGoals[index] = goal;
      await _storage.updateFeesGoal(goal);
    } else {
      _feesGoals.add(goal);
      await _storage.saveFeesGoal(goal);
    }
    notifyListeners();
  }

  /// Delete fees goal
  Future<void> deleteFeesGoal(String goalId) async {
    _feesGoals.removeWhere((g) => g.id == goalId);
    await _storage.deleteFeesGoal(goalId);
    notifyListeners();
  }

  /// Get transactions by category
  List<Transaction> getTransactionsByCategory(TransactionCategory category) {
    return _transactions.where((t) => t.category == category).toList();
  }

  /// Get total spent
  double get totalSpent {
    return _transactions
        .where((t) => t.category == TransactionCategory.spend)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Get total family expenses
  double get totalFamily {
    return _transactions
        .where((t) => t.category == TransactionCategory.family)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  /// Clear all data (for reset)
  Future<void> clearAllData() async {
    await _storage.clearAll();
    _transactions = [];
    _loans = [];
    _feesGoals = [];
    _budgets = [];
    notifyListeners();
  }

  /// Seed initial data (for first run)
  Future<void> seedInitialData() async {
    // Initial cash of 20,000 - only add if not already added
    final existingInitialStipend = _transactions
        .where((t) => t.description == 'Initial stipend')
        .firstOrNull;
    if (existingInitialStipend == null) {
      final initialCash = Transaction(
        id: 'initial_${DateTime.now().millisecondsSinceEpoch}',
        amount: 20000.0,
        category: TransactionCategory.income,
        description: 'Initial stipend',
        date: DateTime.now(),
      );
      await addTransaction(initialCash);
    }

    // Gold loan - only add if it doesn't exist
    final existingGoldLoan =
        _loans.where((l) => l.name == 'Gold Loan').firstOrNull;
    if (existingGoldLoan == null) {
      final goldLoan = Loan(
        id: 'loan_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Gold Loan',
        initialPrincipal: 110000.0,
        currentPrincipal: 110000.0,
        interestRateAnnual: 9.0,
        startDate: DateTime.now(),
      );
      await saveLoan(goldLoan);
    }

    // Fees goal (45k due April next year) - only add if it doesn't exist
    final existingFeesGoal =
        _feesGoals.where((f) => f.name == 'College Fees').firstOrNull;
    if (existingFeesGoal == null) {
      final feesGoal = FeesGoal(
        id: 'fees_${DateTime.now().millisecondsSinceEpoch}',
        name: 'College Fees',
        targetAmount: 45000.0,
        currentAmount: 0.0,
        dueDate: DateTime(2026, 4, 30),
      );
      await saveFeesGoal(feesGoal);
    }

    // Seed default budgets
    await _seedDefaultBudgets();

    notifyListeners();
  }

  /// Seed default budgets
  Future<void> _seedDefaultBudgets() async {
    final defaultBudgets = [
      Budget(
        id: 'budget_food_${DateTime.now().millisecondsSinceEpoch}',
        category: TransactionCategory.spend,
        monthlyLimit: 5000.0,
      ),
      Budget(
        id: 'budget_family_${DateTime.now().millisecondsSinceEpoch}',
        category: TransactionCategory.family,
        monthlyLimit: 3000.0,
      ),
    ];

    for (var budget in defaultBudgets) {
      await saveBudget(budget);
    }
  }

  // Budget Management
  /// Add or update budget
  Future<void> saveBudget(Budget budget) async {
    final index = _budgets.indexWhere((b) => b.id == budget.id);
    if (index >= 0) {
      _budgets[index] = budget;
      await _storage.updateBudget(budget);
    } else {
      _budgets.add(budget);
      await _storage.saveBudget(budget);
    }
    notifyListeners();
  }

  /// Delete budget
  Future<void> deleteBudget(String budgetId) async {
    _budgets.removeWhere((b) => b.id == budgetId);
    await _storage.deleteBudget(budgetId);
    notifyListeners();
  }

  /// Get budget for a category
  Budget? getBudgetForCategory(TransactionCategory category) {
    try {
      return _budgets.firstWhere((b) => b.category == category && b.isActive);
    } catch (e) {
      return null;
    }
  }

  /// Check if any budget is exceeded
  bool hasOverBudgetCategories() {
    return _budgets.any((budget) => budget.isOverBudget(_transactions));
  }

  /// Get expense breakdown by category (for current month)
  Map<TransactionCategory, double> getCurrentMonthExpenseBreakdown() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);

    final expenseCategories = [
      TransactionCategory.spend,
      TransactionCategory.family,
      TransactionCategory.savingsDeposit,
      TransactionCategory.loanPayment,
      TransactionCategory.feePayment,
    ];

    final breakdown = <TransactionCategory, double>{};

    for (var category in expenseCategories) {
      final total = _transactions
          .where((t) => t.category == category && t.date.isAfter(monthStart))
          .fold(0.0, (sum, t) => sum + t.amount);

      if (total > 0) {
        breakdown[category] = total;
      }
    }

    return breakdown;
  }

  /// Get total expenses for current month
  double getCurrentMonthTotalExpenses() {
    final breakdown = getCurrentMonthExpenseBreakdown();
    return breakdown.values.fold(0.0, (sum, amount) => sum + amount);
  }

  /// Get daily spending data for last N days
  List<double> getDailySpendingLast7Days() {
    final now = DateTime.now();
    final dailySpending = <double>[];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final nextDate = DateTime(now.year, now.month, now.day - i + 1);

      final dayTotal = _transactions
          .where(
            (t) =>
                (t.category == TransactionCategory.spend ||
                    t.category == TransactionCategory.family) &&
                t.date.isAfter(date) &&
                t.date.isBefore(nextDate),
          )
          .fold(0.0, (sum, t) => sum + t.amount);

      dailySpending.add(dayTotal);
    }

    return dailySpending;
  }
}
