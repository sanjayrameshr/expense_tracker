import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/budget.dart';
import '../models/transaction.dart';
import '../providers/finance_provider.dart';
import '../utils/currency_formatter.dart';
import '../widgets/charts.dart';
import '../widgets/quick_add_buttons.dart';
import 'add_transaction_screen.dart';
import 'budget_screen.dart';
import 'loans_screen.dart';
import 'fees_screen.dart';
import 'transactions_screen.dart';
import 'settings_screen.dart';

/// Main dashboard showing financial overview
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PocketPlan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, finance, _) {
          final cashBalance = finance.cashBalance;
          final loans = finance.loans;
          final feesGoals = finance.feesGoals;

          // Calculate total loan remaining
          final totalLoanRemaining = loans.fold<double>(
            0.0,
            (sum, loan) => sum + loan.currentPrincipal,
          );

          // Calculate next month's interest estimate
          final totalMonthlyInterest = loans.fold<double>(
            0.0,
            (sum, loan) => sum + loan.calculateMonthlyInterest(),
          );

          // Calculate fees remaining
          final totalFeesRemaining = feesGoals.fold<double>(
            0.0,
            (sum, goal) => sum + goal.remainingAmount,
          );

          return RefreshIndicator(
            onRefresh: () => finance.loadData(),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Cash Balance Card
                _DashboardCard(
                  title: 'Cash Balance',
                  value: formatCurrency(cashBalance),
                  icon: Icons.account_balance_wallet,
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TransactionsScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Loan Remaining Card
                _DashboardCard(
                  title: 'Loan Remaining',
                  value: formatCurrency(totalLoanRemaining),
                  subtitle:
                      'Est. next month interest: ${formatCurrency(totalMonthlyInterest)}',
                  icon: Icons.credit_card,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoansScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Fees Remaining Card
                _DashboardCard(
                  title: 'Fees Remaining',
                  value: formatCurrency(totalFeesRemaining),
                  subtitle:
                      feesGoals.isNotEmpty
                          ? 'Required monthly: ${formatCurrency(feesGoals.first.requiredMonthlySaving)}'
                          : null,
                  icon: Icons.school,
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const FeesScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Budget Status Card
                if (finance.budgets.isNotEmpty)
                  _BudgetStatusCard(
                    budgets: finance.budgets,
                    transactions: finance.transactions,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const BudgetScreen()),
                      );
                    },
                  ),
                if (finance.budgets.isNotEmpty) const SizedBox(height: 16),

                // Quick Add Buttons
                const QuickAddButtonsRow(),
                const SizedBox(height: 16),

                // Expense Breakdown Chart
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Expense Breakdown',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Divider(),
                        SizedBox(
                          height: 300,
                          child:
                              finance.getCurrentMonthExpenseBreakdown().isEmpty
                                  ? const Center(
                                    child: Text('No expenses this month'),
                                  )
                                  : Column(
                                    children: [
                                      Expanded(
                                        child: ExpensePieChart(
                                          categoryData:
                                              finance
                                                  .getCurrentMonthExpenseBreakdown(),
                                          totalAmount:
                                              finance
                                                  .getCurrentMonthTotalExpenses(),
                                        ),
                                      ),
                                      ChartLegend(
                                        categoryData:
                                            finance
                                                .getCurrentMonthExpenseBreakdown(),
                                      ),
                                    ],
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Spending Trend Chart
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Spending Trend (Last 7 Days)',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Divider(),
                        SizedBox(
                          height: 200,
                          child: SpendingTrendChart(
                            dailySpending: finance.getDailySpendingLast7Days(),
                            labels: _getLast7DaysLabels(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Quick Stats
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quick Stats',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const Divider(),
                        _StatRow(
                          label: 'Total Spent',
                          value: formatCurrency(finance.totalSpent),
                        ),
                        _StatRow(
                          label: 'Family Expenses',
                          value: formatCurrency(finance.totalFamily),
                        ),
                        _StatRow(
                          label: 'Active Loans',
                          value: loans.length.toString(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Transaction'),
      ),
    );
  }

  /// Generate labels for the last 7 days
  List<String> _getLast7DaysLabels() {
    final now = DateTime.now();
    final labels = <String>[];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day - i);
      final dayName =
          ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday - 1];
      labels.add(dayName);
    }

    return labels;
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 4),
                    Text(
                      value,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold, color: color),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _BudgetStatusCard extends StatelessWidget {
  final List<Budget> budgets;
  final List<Transaction> transactions;
  final VoidCallback onTap;

  const _BudgetStatusCard({
    required this.budgets,
    required this.transactions,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeBudgets = budgets.where((b) => b.isActive).toList();
    if (activeBudgets.isEmpty) return const SizedBox.shrink();

    // Show warning if any budget is over
    final hasOverBudget = activeBudgets.any(
      (b) => b.isOverBudget(transactions),
    );

    return Card(
      color: hasOverBudget ? Colors.red.shade50 : null,
      elevation: hasOverBudget ? 4 : 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          hasOverBudget
                              ? Colors.red.shade100
                              : Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet,
                      color: hasOverBudget ? Colors.red : Colors.purple,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budgets',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        if (hasOverBudget)
                          Text(
                            'Over budget!',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        else
                          Text(
                            '${activeBudgets.length} active',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const Divider(height: 24),
              ...activeBudgets.take(3).map((budget) {
                final percentage = budget.getUsagePercentage(transactions);
                final statusColor = _getStatusColor(
                  budget.getStatusColor(transactions),
                );

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
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
                              color: statusColor,
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
                          valueColor: AlwaysStoppedAnimation(statusColor),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              if (activeBudgets.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '+${activeBudgets.length - 3} more',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
            ],
          ),
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
