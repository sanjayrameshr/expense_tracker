import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/finance_provider.dart';
import '../utils/currency_formatter.dart';

/// Transaction History Screen with Monthly Summary Bar
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  TransactionCategory? _filterCategory;

  /// --- NEW: Groups transactions by date ---
  Map<String, List<Transaction>> _groupTransactions(
      List<Transaction> transactions) {
    final grouped = <String, List<Transaction>>{};
    final now = DateTime.now();
    final today = DateUtils.dateOnly(now);
    final yesterday = DateUtils.dateOnly(now.subtract(const Duration(days: 1)));

    for (final txn in transactions) {
      final date = DateUtils.dateOnly(txn.date);
      String key;
      if (date == today) {
        key = 'Today';
      } else if (date == yesterday) {
        key = 'Yesterday';
      } else {
        key = DateFormat('MMMM d, yyyy').format(date);
      }

      if (grouped[key] == null) {
        grouped[key] = [];
      }
      grouped[key]!.add(txn);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final background = const Color(0xFFF8F9FB);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: const Text(
          'Transactions',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        foregroundColor: Colors.grey.shade800,
        actions: [
          PopupMenuButton<TransactionCategory?>(
            icon: const Icon(Icons.filter_list_rounded),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            onSelected: (category) =>
                setState(() => _filterCategory = category),
            itemBuilder: (context) => [
              const PopupMenuItem(value: null, child: Text('All')),
              ...TransactionCategory.values.map(
                (c) => PopupMenuItem(value: c, child: Text(_categoryName(c))),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, finance, _) {
          var transactions = finance.transactions;

          // Filter by category
          if (_filterCategory != null) {
            transactions = transactions
                .where((t) => t.category == _filterCategory)
                .toList();
          }

          // Sort by newest first
          transactions.sort((a, b) => b.date.compareTo(a.date));

          // Monthly summary calculations
          final now = DateTime.now();
          final monthTxns = transactions
              .where(
                  (t) => t.date.year == now.year && t.date.month == now.month)
              .toList();
          final totalIncome = monthTxns
              .where((t) => t.category == TransactionCategory.income)
              .fold(0.0, (sum, t) => sum + t.amount);
          final totalExpense = monthTxns
              .where((t) => t.category != TransactionCategory.income)
              .fold(0.0, (sum, t) => sum + t.amount);
          final balance = totalIncome - totalExpense;

          // --- NEW: Grouping logic ---
          final groupedTransactions = _groupTransactions(transactions);
          final displayList = [];
          groupedTransactions.forEach((key, txns) {
            displayList.add(key); // Add date header
            displayList.addAll(txns); // Add all transactions for that date
          });

          return Column(
            children: [
              _SummaryCard(
                income: totalIncome,
                expense: totalExpense,
                balance: balance,
              ),
              const SizedBox(height: 8),
              Expanded(
                child: transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_rounded,
                                size: 70, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              'No transactions yet',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 15),
                            ),
                          ],
                        ),
                      )
                    // --- MODIFIED: Use grouped list ---
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        itemCount: displayList.length,
                        itemBuilder: (context, index) {
                          final item = displayList[index];

                          if (item is String) {
                            return _DateHeader(title: item);
                          }
                          if (item is Transaction) {
                            return _TransactionCard(transaction: item);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _filterCategory != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey.shade100,
              child: Row(
                children: [
                  const Icon(Icons.filter_alt_rounded,
                      size: 18, color: Colors.black54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Filtered by: ${_categoryName(_filterCategory!)}',
                      style:
                          TextStyle(color: Colors.grey.shade700, fontSize: 13),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _filterCategory = null),
                    child: const Text('Clear'),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  String _categoryName(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.income:
        return 'Income';
      case TransactionCategory.spend:
        return 'Personal';
      case TransactionCategory.family:
        return 'Family';
      case TransactionCategory.savingsDeposit:
        return 'Savings';
      case TransactionCategory.loanPayment:
        return 'Loan Payment';
      case TransactionCategory.feePayment:
        return 'Fee Payment';
    }
  }
}

// --- NEW: Date Header Widget ---
class _DateHeader extends StatelessWidget {
  final String title;
  const _DateHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }
}

/// --- Summary Card Widget ---
class _SummaryCard extends StatelessWidget {
  final double income;
  final double expense;
  final double balance;

  const _SummaryCard({
    required this.income,
    required this.expense,
    required this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1.5,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            _summaryItem(
                'Income', formatCurrency(income), Colors.green.shade700),
            _verticalDivider(),
            _summaryItem('Spent', formatCurrency(expense), Colors.red.shade700),
            _verticalDivider(),
            _summaryItem('Balance', formatCurrency(balance),
                balance >= 0 ? Colors.blueGrey.shade800 : Colors.red.shade800),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String title, String value, Color color) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(title,
              style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  fontSize: 13)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              )),
        ],
      ),
    );
  }

  Widget _verticalDivider() {
    return Container(
      height: 28,
      width: 1,
      color: Colors.grey.shade200,
      margin: const EdgeInsets.symmetric(horizontal: 12),
    );
  }
}

/// --- Transaction Card Widget ---
class _TransactionCard extends StatelessWidget {
  final Transaction transaction;
  const _TransactionCard({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.category == TransactionCategory.income;
    final color = isIncome ? Colors.green.shade700 : Colors.red.shade700;
    final icon = _getIcon(transaction.category);

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(transaction.description,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(
                    // --- MODIFIED: Show category name, not date (date is in header) ---
                    _categoryName(transaction.category),
                    style:
                        TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
                  ),
                  if (transaction.interestPortion != null &&
                      transaction.principalPortion != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Int: ${formatCurrency(transaction.interestPortion!)} | '
                        'Prin: ${formatCurrency(transaction.principalPortion!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueGrey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Amount
            Text(
              '${isIncome ? '+' : '-'}${formatCurrency(transaction.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 15.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.income:
        return Icons.arrow_downward_rounded;
      case TransactionCategory.spend:
        return Icons.shopping_bag_rounded;
      case TransactionCategory.family:
        return Icons.family_restroom_rounded;
      case TransactionCategory.savingsDeposit:
        return Icons.savings_rounded;
      case TransactionCategory.loanPayment:
        return Icons.account_balance_rounded;
      case TransactionCategory.feePayment:
        return Icons.school_rounded;
    }
  }

  String _categoryName(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.income:
        return 'Income';
      case TransactionCategory.spend:
        return 'Personal';
      case TransactionCategory.family:
        return 'Family';
      case TransactionCategory.savingsDeposit:
        return 'Savings';
      case TransactionCategory.loanPayment:
        return 'Loan Payment';
      case TransactionCategory.feePayment:
        return 'Fee Payment';
    }
  }
}
