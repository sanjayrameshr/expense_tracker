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
    final theme = Theme.of(context);
    final textColor = Colors.grey.shade800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text(
          'PocketPlan',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFFF8F9FB),
        foregroundColor: Colors.grey.shade900,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
          ),
        ],
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, finance, _) {
          final cashBalance = finance.cashBalance;
          final loans = finance.loans;
          final feesGoals = finance.feesGoals;

          final totalLoanRemaining = loans.fold<double>(
            0.0,
            (sum, loan) => sum + loan.currentPrincipal,
          );
          final totalMonthlyInterest = loans.fold<double>(
            0.0,
            (sum, loan) => sum + loan.calculateMonthlyInterest(),
          );
          final totalFeesRemaining = feesGoals.fold<double>(
            0.0,
            (sum, goal) => sum + goal.remainingAmount,
          );

          return RefreshIndicator(
            onRefresh: () => finance.loadData(),
            color: Colors.grey.shade600,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _MainBalanceCard(
                  balance: cashBalance,
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TransactionsScreen(),
                        ),
                      ),
                ),
                const SizedBox(height: 20),
                const QuickAddButtonsRow(),
                const SizedBox(height: 20),

                _sectionHeader(context, 'Overview'),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _CompactCard(
                        title: 'Loans',
                        value: formatCurrency(totalLoanRemaining),
                        subtitle:
                            'Int: ${formatCurrency(totalMonthlyInterest)}/mo',
                        icon: Icons.credit_card_rounded,
                        color: const Color(0xFFBFAE8D),
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoansScreen(),
                              ),
                            ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CompactCard(
                        title: 'Fees Due',
                        value: formatCurrency(totalFeesRemaining),
                        subtitle:
                            feesGoals.isNotEmpty
                                ? '${formatCurrency(feesGoals.first.requiredMonthlySaving)}/mo'
                                : 'No goals',
                        icon: Icons.school_rounded,
                        color: const Color(0xFFA7B6C2),
                        onTap:
                            () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const FeesScreen(),
                              ),
                            ),
                      ),
                    ),
                  ],
                ),

                if (finance.budgets.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _sectionHeader(context, 'Budgets'),
                  const SizedBox(height: 12),
                  _BudgetStatusCard(
                    budgets: finance.budgets,
                    transactions: finance.transactions,
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BudgetScreen(),
                          ),
                        ),
                  ),
                ],

                const SizedBox(height: 24),
                _sectionHeader(context, 'Analytics'),
                const SizedBox(height: 12),

                _buildExpenseBreakdownCard(finance),
                const SizedBox(height: 16),
                _buildSpendingTrendCard(finance),
                const SizedBox(height: 16),
                _buildQuickStatsCard(finance),
                const SizedBox(height: 80), // Extra padding for bottom nav
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
            ),
        backgroundColor: Colors.white,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.blue, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        height: 65,
        color: Colors.blue.shade700,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context,
              icon: Icons.account_balance_wallet,
              label: 'Transactions',
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TransactionsScreen(),
                    ),
                  ),
            ),
            _buildNavItem(
              context,
              icon: Icons.credit_card,
              label: 'Loans',
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoansScreen()),
                  ),
            ),
            const SizedBox(width: 48), // Space for FAB
            _buildNavItem(
              context,
              icon: Icons.account_balance_wallet_outlined,
              label: 'Budgets',
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BudgetScreen()),
                  ),
            ),
            _buildNavItem(
              context,
              icon: Icons.school,
              label: 'Fees',
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FeesScreen()),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) => Text(
    title,
    style: Theme.of(context).textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w600,
      color: Colors.grey.shade700,
    ),
  );

  List<String> _getLast7DaysLabels() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][date.weekday -
          1];
    });
  }

  Widget _buildExpenseBreakdownCard(FinanceProvider finance) {
    final breakdown = finance.getCurrentMonthExpenseBreakdown();
    return _InfoCard(
      title: 'Expense Breakdown',
      icon: Icons.pie_chart_outline,
      color: const Color(0xFF7D8C9E),
      child: SizedBox(
        height: 280,
        child:
            breakdown.isEmpty
                ? _emptyPlaceholder('No expenses this month')
                : Column(
                  children: [
                    Expanded(
                      child: ExpensePieChart(
                        categoryData: breakdown,
                        totalAmount: finance.getCurrentMonthTotalExpenses(),
                      ),
                    ),
                    ChartLegend(categoryData: breakdown),
                  ],
                ),
      ),
    );
  }

  Widget _buildSpendingTrendCard(FinanceProvider finance) {
    return _InfoCard(
      title: 'Spending Trend (Last 7 Days)',
      icon: Icons.show_chart_rounded,
      color: const Color(0xFF8CA08C),
      child: SizedBox(
        height: 200,
        child: SpendingTrendChart(
          dailySpending: finance.getDailySpendingLast7Days(),
          labels: _getLast7DaysLabels(),
        ),
      ),
    );
  }

  Widget _buildQuickStatsCard(FinanceProvider finance) {
    return _InfoCard(
      title: 'Quick Stats',
      icon: Icons.insights_rounded,
      color: const Color(0xFF9B9DB4),
      child: Column(
        children: [
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
            value: finance.loans.length.toString(),
          ),
        ],
      ),
    );
  }

  Widget _emptyPlaceholder(String text) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.inbox_outlined, size: 48, color: Colors.grey.shade400),
        const SizedBox(height: 8),
        Text(text, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
      ],
    ),
  );
}

/// Base card style used throughout dashboard
class _InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _InfoCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

/// Main balance display with soft gradient
class _MainBalanceCard extends StatelessWidget {
  final double balance;
  final VoidCallback onTap;

  const _MainBalanceCard({required this.balance, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFBCCCDC), Color(0xFFD9E2EC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _iconBox(Icons.account_balance_wallet_rounded),
                  const Spacer(),
                  Icon(
                    Icons.trending_up,
                    color: Colors.grey.shade800,
                    size: 22,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Current Balance',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                formatCurrency(balance),
                style: TextStyle(
                  color: Colors.grey.shade900,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tap to view transactions',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconBox(IconData icon) => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.6),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, color: Colors.grey.shade800, size: 26),
  );
}

/// Compact summary card
class _CompactCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CompactCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
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
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

/// Budget tracking section with elegant progress bars
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

    final hasOverBudget = activeBudgets.any(
      (b) => b.isOverBudget(transactions),
    );

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color:
                        hasOverBudget
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
              ...activeBudgets
                  .take(3)
                  .map(
                    (budget) => _BudgetProgress(
                      budget: budget,
                      transactions: transactions,
                    ),
                  ),
              if (activeBudgets.length > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Text(
                    '+${activeBudgets.length - 3} more',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetProgress extends StatelessWidget {
  final Budget budget;
  final List<Transaction> transactions;

  const _BudgetProgress({required this.budget, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final percentage = budget.getUsagePercentage(transactions);
    final statusColor = _getStatusColor(budget.getStatusColor(transactions));

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
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'green':
        return Colors.green.shade400;
      case 'orange':
        return Colors.orange.shade400;
      case 'red':
        return Colors.red.shade400;
      default:
        return Colors.grey.shade400;
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
