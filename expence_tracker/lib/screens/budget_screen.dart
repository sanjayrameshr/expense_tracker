import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import '../providers/finance_provider.dart';
import '../utils/currency_formatter.dart';

/// Elegant UI for managing monthly budgets by category
class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final background = const Color(0xFFF8F9FB);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: background,
        foregroundColor: Colors.grey.shade800,
        title: const Text(
          'Budgets',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, finance, _) {
          final budgets = finance.budgets;

          if (budgets.isEmpty) {
            return _EmptyBudgetState(
              onCreate: () => _showAddBudgetDialog(context, finance),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: budgets.length + 1,
            itemBuilder: (context, index) {
              if (index == budgets.length) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: OutlinedButton.icon(
                    onPressed: () => _showAddBudgetDialog(context, finance),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add New Budget'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade800,
                      side: BorderSide(color: Colors.grey.shade400),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
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
                style: TextButton.styleFrom(
                  foregroundColor: Colors.red.shade400,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
    );
  }
}

class _EmptyBudgetState extends StatelessWidget {
  final VoidCallback onCreate;

  const _EmptyBudgetState({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 70,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 20),
            Text(
              'No Budgets Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Set up monthly budgets to track your spending goals.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Budget'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
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
    final isOverBudget = budget.isOverBudget(transactions);

    final color =
        isOverBudget
            ? Colors.red.shade400
            : (percentage >= 80
                ? Colors.orange.shade400
                : Colors.green.shade400);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _iconForCategory(budget.category),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _getCategoryName(budget.category),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  color: Colors.grey.shade600,
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Colors.red.shade400,
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: (percentage / 100).clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _labelValue(
                  'Spent',
                  formatCurrency(spending),
                  color: color,
                  alignRight: false,
                ),
                _labelValue(
                  isOverBudget ? 'Over Budget' : 'Remaining',
                  formatCurrency(remaining.abs()),
                  color:
                      isOverBudget ? Colors.red.shade400 : Colors.grey.shade700,
                  alignRight: true,
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${percentage.toStringAsFixed(1)}% used',
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconForCategory(TransactionCategory category) {
    IconData icon;
    switch (category) {
      case TransactionCategory.family:
        icon = Icons.family_restroom;
        break;
      case TransactionCategory.loanPayment:
        icon = Icons.credit_card;
        break;
      case TransactionCategory.savingsDeposit:
        icon = Icons.savings_rounded;
        break;
      case TransactionCategory.feePayment:
        icon = Icons.school;
        break;
      case TransactionCategory.income:
        icon = Icons.trending_up;
        break;
      default:
        icon = Icons.shopping_bag_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: Colors.grey.shade700, size: 22),
    );
  }

  Widget _labelValue(
    String label,
    String value, {
    Color? color,
    bool alignRight = false,
  }) {
    return Column(
      crossAxisAlignment:
          alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: color ?? Colors.grey.shade800,
          ),
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
        return 'Savings';
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(
        widget.budget == null ? 'Add Budget' : 'Edit Budget',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<TransactionCategory>(
            value: _selectedCategory,
            decoration: InputDecoration(
              labelText: 'Category',
              filled: true,
              fillColor: const Color(0xFFF3F5F8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
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
              if (value != null) setState(() => _selectedCategory = value);
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _limitController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Monthly Limit (₹)',
              filled: true,
              fillColor: const Color(0xFFF3F5F8),
              prefixText: '₹ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
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
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade800,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
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
