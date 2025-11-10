import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import '../providers/finance_provider.dart';
import '../utils/currency_formatter.dart';

/// Screen for managing monthly budgets by category
class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: Consumer<FinanceProvider>(
        builder: (context, finance, _) {
          final budgets = finance.budgets;

          if (budgets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No budgets set',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Create a budget to track your spending',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _showAddBudgetDialog(context, finance),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Budget'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: budgets.length + 1,
            itemBuilder: (context, index) {
              if (index == budgets.length) {
                // Add new budget button at the end
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddBudgetDialog(context, finance),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Budget'),
                  ),
                );
              }

              final budget = budgets[index];
              return _BudgetCard(
                budget: budget,
                transactions: finance.transactions,
                onEdit: () => _showEditBudgetDialog(context, finance, budget),
                onDelete: () => _confirmDelete(context, finance, budget),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddBudgetDialog(BuildContext context, FinanceProvider finance) {
    showDialog(
      context: context,
      builder:
          (_) => _BudgetDialog(
            finance: finance,
            onSave: (category, limit) {
              final budget = Budget(
                id: 'budget_${DateTime.now().millisecondsSinceEpoch}',
                category: category,
                monthlyLimit: limit,
              );
              finance.saveBudget(budget);
            },
          ),
    );
  }

  void _showEditBudgetDialog(
    BuildContext context,
    FinanceProvider finance,
    Budget budget,
  ) {
    showDialog(
      context: context,
      builder:
          (_) => _BudgetDialog(
            finance: finance,
            budget: budget,
            onSave: (category, limit) {
              final updated = Budget(
                id: budget.id,
                category: category,
                monthlyLimit: limit,
                isActive: budget.isActive,
              );
              finance.saveBudget(updated);
            },
          ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    FinanceProvider finance,
    Budget budget,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Delete Budget'),
            content: const Text('Are you sure you want to delete this budget?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  finance.deleteBudget(budget.id);
                  Navigator.pop(ctx);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final Budget budget;
  final List<Transaction> transactions;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BudgetCard({
    required this.budget,
    required this.transactions,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final spending = budget.getCurrentMonthSpending(transactions);
    final remaining = budget.getRemainingBudget(transactions);
    final percentage = budget.getUsagePercentage(transactions);
    final statusColor = _getStatusColor(budget.getStatusColor(transactions));
    final isOverBudget = budget.isOverBudget(transactions);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getCategoryName(budget.category),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Monthly Limit: ${formatCurrency(budget.monthlyLimit)}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 12,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(statusColor),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Spent', style: Theme.of(context).textTheme.bodySmall),
                    Text(
                      formatCurrency(spending),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      isOverBudget ? 'Over Budget' : 'Remaining',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      formatCurrency(remaining.abs()),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isOverBudget ? Colors.red : Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${percentage.toStringAsFixed(1)}% used',
              style: TextStyle(
                fontSize: 12,
                color: statusColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getCategoryName(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.spend:
        return 'Personal Spending';
      case TransactionCategory.family:
        return 'Family Expenses';
      case TransactionCategory.savingsDeposit:
        return 'Savings Deposits';
      case TransactionCategory.loanPayment:
        return 'Loan Payments';
      case TransactionCategory.feePayment:
        return 'Fee Payments';
      case TransactionCategory.income:
        return 'Income';
    }
  }
}

class _BudgetDialog extends StatefulWidget {
  final FinanceProvider finance;
  final Budget? budget;
  final Function(TransactionCategory, double) onSave;

  const _BudgetDialog({
    required this.finance,
    this.budget,
    required this.onSave,
  });

  @override
  State<_BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<_BudgetDialog> {
  late TransactionCategory _selectedCategory;
  late TextEditingController _limitController;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.budget?.category ?? TransactionCategory.spend;
    _limitController = TextEditingController(
      text: widget.budget?.monthlyLimit.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.budget == null ? 'Add Budget' : 'Edit Budget'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<TransactionCategory>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items:
                [
                  TransactionCategory.spend,
                  TransactionCategory.family,
                  TransactionCategory.savingsDeposit,
                  TransactionCategory.loanPayment,
                  TransactionCategory.feePayment,
                ].map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(_getCategoryName(category)),
                  );
                }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => _selectedCategory = value);
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _limitController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Monthly Limit (₹)',
              border: OutlineInputBorder(),
              prefixText: '₹ ',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final limit = double.tryParse(_limitController.text);
            if (limit != null && limit > 0) {
              widget.onSave(_selectedCategory, limit);
              Navigator.pop(context);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  String _getCategoryName(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.spend:
        return 'Personal Spending';
      case TransactionCategory.family:
        return 'Family Expenses';
      case TransactionCategory.savingsDeposit:
        return 'Savings Deposits';
      case TransactionCategory.loanPayment:
        return 'Loan Payments';
      case TransactionCategory.feePayment:
        return 'Fee Payments';
      case TransactionCategory.income:
        return 'Income';
    }
  }
}
