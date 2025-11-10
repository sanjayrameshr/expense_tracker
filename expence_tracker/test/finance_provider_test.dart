import 'package:flutter_test/flutter_test.dart';
import 'package:expence_tracker/models/transaction.dart';
import 'package:expence_tracker/models/loan.dart';
import 'package:expence_tracker/providers/finance_provider.dart';
import 'package:expence_tracker/services/storage_service.dart';

// Mock StorageService for testing
class MockStorageService extends StorageService {
  final List<Transaction> _transactions = [];
  final List<Loan> _loans = [];

  @override
  Future<List<Transaction>> getTransactions() async => _transactions;

  @override
  Future<void> saveTransaction(Transaction transaction) async {
    _transactions.add(transaction);
  }

  @override
  Future<List<Loan>> getLoans() async => _loans;

  @override
  Future<void> saveLoan(Loan loan) async {
    _loans.add(loan);
  }

  @override
  Future<void> updateLoan(Loan loan) async {
    final index = _loans.indexWhere((l) => l.id == loan.id);
    if (index >= 0) {
      _loans[index] = loan;
    }
  }
}

void main() {
  group('FinanceProvider Tests', () {
    late FinanceProvider financeProvider;
    late MockStorageService mockStorage;

    setUp(() {
      mockStorage = MockStorageService();
      financeProvider = FinanceProvider(mockStorage);
    });

    test(
      'Cash balance should calculate correctly with income and expenses',
      () async {
        // Add income
        await financeProvider.addTransaction(
          Transaction(
            id: 'txn1',
            amount: 20000.0,
            category: TransactionCategory.income,
            description: 'Stipend',
          ),
        );

        // Add expense
        await financeProvider.addTransaction(
          Transaction(
            id: 'txn2',
            amount: 5000.0,
            category: TransactionCategory.spend,
            description: 'Shopping',
          ),
        );

        expect(financeProvider.cashBalance, 15000.0);
      },
    );

    test('Loan payment split should calculate interest-first correctly', () {
      final loan = Loan(
        id: 'loan1',
        name: 'Test Loan',
        initialPrincipal: 100000.0,
        currentPrincipal: 100000.0,
        interestRateAnnual: 12.0,
      );

      // Monthly interest = 100000 * 12% / 12 = 1000
      final split = financeProvider.calculateLoanPaymentSplit(loan, 2000.0);

      expect(split[0], 1000.0); // Interest portion
      expect(split[1], 1000.0); // Principal portion
    });

    test('Loan payment split with amount less than interest', () {
      final loan = Loan(
        id: 'loan1',
        name: 'Test Loan',
        initialPrincipal: 100000.0,
        currentPrincipal: 100000.0,
        interestRateAnnual: 12.0,
      );

      // Monthly interest = 1000
      // Payment = 500 (less than interest)
      final split = financeProvider.calculateLoanPaymentSplit(loan, 500.0);

      expect(split[0], 500.0); // All goes to interest
      expect(split[1], 0.0); // Nothing to principal
    });

    test('Total spent should sum all spend transactions', () async {
      await financeProvider.addTransaction(
        Transaction(
          id: 'txn1',
          amount: 1000.0,
          category: TransactionCategory.spend,
          description: 'Food',
        ),
      );

      await financeProvider.addTransaction(
        Transaction(
          id: 'txn2',
          amount: 2000.0,
          category: TransactionCategory.spend,
          description: 'Transport',
        ),
      );

      expect(financeProvider.totalSpent, 3000.0);
    });

    test('Total family expenses should sum correctly', () async {
      await financeProvider.addTransaction(
        Transaction(
          id: 'txn1',
          amount: 5000.0,
          category: TransactionCategory.family,
          description: 'Groceries',
        ),
      );

      await financeProvider.addTransaction(
        Transaction(
          id: 'txn2',
          amount: 3000.0,
          category: TransactionCategory.family,
          description: 'Medical',
        ),
      );

      expect(financeProvider.totalFamily, 8000.0);
    });

    test('Should filter transactions by category', () async {
      await financeProvider.addTransaction(
        Transaction(
          id: 'txn1',
          amount: 1000.0,
          category: TransactionCategory.income,
          description: 'Salary',
        ),
      );

      await financeProvider.addTransaction(
        Transaction(
          id: 'txn2',
          amount: 500.0,
          category: TransactionCategory.spend,
          description: 'Food',
        ),
      );

      final incomeTransactions = financeProvider.getTransactionsByCategory(
        TransactionCategory.income,
      );

      expect(incomeTransactions.length, 1);
      expect(incomeTransactions.first.description, 'Salary');
    });
  });
}
