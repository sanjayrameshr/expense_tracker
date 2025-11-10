import 'package:flutter/material.dart';
import '../../models/budget.dart';
import '../../models/transaction.dart';

/// Budget status card showing active budgets
class BudgetStatusCard extends StatelessWidget {
  final List<Budget> budgets;
  final List<Transaction> transactions;
  final VoidCallback onTap;

  const BudgetStatusCard({
    super.key,
    required this.budgets,
    required this.transactions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeBudgets = budgets.where((b) => b.isActive).toList();
    if (activeBudgets.isEmpty) return const SizedBox.shrink();

    final hasOverBudget =
        activeBudgets.any((b) => b.isOverBudget(transactions));

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color: hasOverBudget
                        ? Colors.red.shade400
                        : Colors.grey.shade700,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Budgets',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const Divider(height: 20),
              ...activeBudgets.take(3).map(
                    (b) => BudgetProgress(
                      budget: b,
                      transactions: transactions,
                    ),
                  ),
              if (activeBudgets.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '+${activeBudgets.length - 3} more',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Budget progress indicator
class BudgetProgress extends StatelessWidget {
  final Budget budget;
  final List<Transaction> transactions;

  const BudgetProgress({
    super.key,
    required this.budget,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = budget.getUsagePercentage(transactions);
    final color = switch (budget.getStatusColor(transactions)) {
      'green' => Colors.green.shade400,
      'orange' => Colors.orange.shade400,
      'red' => Colors.red.shade400,
      _ => Colors.grey.shade400,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _getCategoryName(budget.category),
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 6,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.spend:
        return 'Personal';
      case TransactionCategory.family:
        return 'Family';
      case TransactionCategory.savingsDeposit:
        return 'Savings';
      case TransactionCategory.loanPayment:
        return 'Loans';
      case TransactionCategory.feePayment:
        return 'Fees';
      case TransactionCategory.income:
        return 'Income';
    }
  }
}
