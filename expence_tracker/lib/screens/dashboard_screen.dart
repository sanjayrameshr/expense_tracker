import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/finance_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../widgets/widgets.dart';
import 'add_transaction_screen.dart';
import 'budget_screen.dart';
import 'loans_screen.dart';
import 'fees_screen.dart';
import 'transactions_screen.dart';
import 'settings_screen.dart';

/// 🌿 Main dashboard showing financial overview
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        // ✨ NEW: Upgraded AppBar title for a friendlier feel
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome Back',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textPrimary.withOpacity(0.7),
              ),
            ),
            const Text(
              'PocketPlan',
              style: TextStyle(
                fontWeight: FontWeight.w700, // Made it bolder
                fontSize: 20, // Slightly larger
              ),
            ),
          ],
        ),
        // 🎨 MODIFIED: Added toolbarHeight for the new title
        toolbarHeight: 65,
        elevation: 0,
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
      ),

      // 🔹 IndexedStack keeps tab states alive
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _DashboardHome(
            onNavigate: (i) => setState(() => _currentIndex = i),
            onViewTransactions: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TransactionsScreen()),
            ),
          ),
          const LoansScreen(),
          const BudgetScreen(),
          const FeesScreen(),
        ],
      ),

      // 🔹 Floating Action Button
      floatingActionButton: FloatingActionButton(
        heroTag: 'dashboard_fab',
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
        ),
        backgroundColor: AppButtonStyles.fabBackground,
        elevation: 3,
        child: Icon(Icons.add_rounded,
            color: AppButtonStyles.fabIconColor, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 🔹 GPay-style Bottom Navigation
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // 🌿 Rounded bottom bar
  Widget _buildBottomNavBar() {
    final activeColor = AppColors.navActive;
    final inactiveColor = AppColors.navInactive;

    return Container(
      // 🎨 MODIFIED: Increased height for a more modern feel
      height: 75,
      padding: const EdgeInsets.only(bottom: 5), // Added for safe area spacing
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
        ),
        boxShadow: [
          // 🎨 MODIFIED: A softer, more modern shadow
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
              Icons.home_rounded, 'Home', 0, activeColor, inactiveColor),
          _buildNavItem(Icons.credit_card_rounded, 'Loans', 1, activeColor,
              inactiveColor),
          const SizedBox(width: 60),
          _buildNavItem(Icons.account_balance_wallet_outlined, 'Budgets', 2,
              activeColor, inactiveColor),
          _buildNavItem(
              Icons.school_rounded, 'Fees', 3, activeColor, inactiveColor),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index,
      Color activeColor, Color inactiveColor) {
    final bool isActive = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      // ✨ NEW: Added highlight and splash for better feedback
      splashColor: activeColor.withOpacity(0.1),
      highlightColor: activeColor.withOpacity(0.1),
      child: AnimatedContainer(
        // 🎨 MODIFIED: Slightly longer duration and added a curve
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        // ✨ NEW: Add a transform to "pop" the active item
        transform: Matrix4.translationValues(0, isActive ? -4 : 0, 0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withOpacity(0.12) // slightly more visible
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: isActive ? activeColor : inactiveColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : inactiveColor,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
// 🔹 Dashboard Home (default page)
// (This widget remains unchanged)
//
class _DashboardHome extends StatelessWidget {
  final Function(int) onNavigate;
  final VoidCallback onViewTransactions;

  const _DashboardHome({
    required this.onNavigate,
    required this.onViewTransactions,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<FinanceProvider>(
      builder: (context, finance, _) {
        return RefreshIndicator(
          onRefresh: () => finance.loadData(),
          color: Colors.grey.shade600,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Balance Card
              MainBalanceCard(
                balance: finance.cashBalance,
                onTap: onViewTransactions,
                formatCurrency: formatCurrency,
              ),
              const SizedBox(height: 20),

              // Quick Add Buttons
              const QuickAddButtonsRow(),
              const SizedBox(height: 20),

              // Overview Section
              const SectionHeader(title: 'Overview'),
              const SizedBox(height: 12),
              OverviewCards(
                loans: finance.loans,
                feesGoals: finance.feesGoals,
                onNavigate: onNavigate,
              ),

              // Budgets Section
              if (finance.budgets.isNotEmpty) ...[
                const SizedBox(height: 24),
                const SectionHeader(title: 'Budgets'),
                const SizedBox(height: 12),
                BudgetStatusCard(
                  budgets: finance.budgets,
                  transactions: finance.transactions,
                  onTap: () => onNavigate(2),
                ),
              ],

              // Analytics Section
              const SizedBox(height: 24),
              const SectionHeader(title: 'Analytics'),
              const SizedBox(height: 12),
              ExpenseBreakdownCard(finance: finance),
              const SizedBox(height: 16),
              SpendingTrendCard(finance: finance),
              const SizedBox(height: 16),
              QuickStatsCard(finance: finance),
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}
