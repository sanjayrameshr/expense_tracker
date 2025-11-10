import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/finance_provider.dart';
import '../utils/currency_formatter.dart';

/// Screen showing all transactions with filters
class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  TransactionCategory? _filterCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          PopupMenuButton<TransactionCategory?>(
            icon: const Icon(Icons.filter_list),
            onSelected: (category) {
              setState(() {
                _filterCategory = category;
              });
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: null, child: Text('All')),
                  ...TransactionCategory.values.map(
                    (category) => PopupMenuItem(
                      value: category,
                      child: Text(_categoryName(category)),
                    ),
                  ),
                ],
          ),
        ],
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, finance, _) {
          var transactions = finance.transactions;

          // Apply filter
          if (_filterCategory != null) {
            transactions =
                transactions
                    .where((t) => t.category == _filterCategory)
                    .toList();
          }

          // Sort by date (newest first)
          transactions.sort((a, b) => b.date.compareTo(a.date));

          if (transactions.isEmpty) {
            return const Center(child: Text('No transactions yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return _TransactionTile(transaction: transaction);
            },
          );
        },
      ),
    );
  }

  String _categoryName(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.income:
        return 'Income';
      case TransactionCategory.spend:
        return 'Spend';
      case TransactionCategory.family:
        return 'Family';
      case TransactionCategory.savingsDeposit:
        return 'Savings Deposit';
      case TransactionCategory.loanPayment:
        return 'Loan Payment';
      case TransactionCategory.feePayment:
        return 'Fee Payment';
    }
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction transaction;

  const _TransactionTile({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.category == TransactionCategory.income;
    final color = isIncome ? Colors.green : Colors.red;
    final icon = _getIcon(transaction.category);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(transaction.description),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_categoryName(transaction.category)),
            Text(
              formatDate(transaction.date),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (transaction.interestPortion != null &&
                transaction.principalPortion != null)
              Text(
                'Int: ${formatCurrency(transaction.interestPortion!)} | '
                'Prin: ${formatCurrency(transaction.principalPortion!)}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.blue),
              ),
          ],
        ),
        trailing: Text(
          '${isIncome ? '+' : '-'}${formatCurrency(transaction.amount)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  IconData _getIcon(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.income:
        return Icons.arrow_downward;
      case TransactionCategory.spend:
        return Icons.shopping_cart;
      case TransactionCategory.family:
        return Icons.family_restroom;
      case TransactionCategory.savingsDeposit:
        return Icons.savings;
      case TransactionCategory.loanPayment:
        return Icons.payment;
      case TransactionCategory.feePayment:
        return Icons.school;
    }
  }

  String _categoryName(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.income:
        return 'Income';
      case TransactionCategory.spend:
        return 'Spend';
      case TransactionCategory.family:
        return 'Family';
      case TransactionCategory.savingsDeposit:
        return 'Savings Deposit';
      case TransactionCategory.loanPayment:
        return 'Loan Payment';
      case TransactionCategory.feePayment:
        return 'Fee Payment';
    }
  }
}
