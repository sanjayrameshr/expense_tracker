import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/finance_provider.dart';
import '../utils/currency_formatter.dart';
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
      backgroundColor: SoftUI.softBackground,
      appBar: AppBar(
        // ✨ Soft UI: Clean gradient title
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                SoftUI.softBackground,
                SoftUI.softBackground.withOpacity(0.95)
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome Back',
              style: SoftUI.caption.copyWith(fontSize: 13),
            ),
            const Text(
              'PocketPlan',
              style: SoftUI.heading2,
            ),
          ],
        ),
        toolbarHeight: 75,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFF2D3142),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              color: SoftUI.softCard,
              shape: BoxShape.circle,
              boxShadow: SoftUI.softShadow,
            ),
            child: IconButton(
              icon: const Icon(Icons.settings_outlined, size: 22),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
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

      // 🔹 Floating Action Button with Soft UI gradient
      floatingActionButton: Container(
        width: 64,
        height: 64,
        decoration: SoftUI.gradientCardDecoration(SoftUI.primaryGradient),
        child: FloatingActionButton(
          heroTag: 'dashboard_fab',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // 🔹 GPay-style Bottom Navigation
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // 🌿 Soft UI Bottom Navigation Bar
  Widget _buildBottomNavBar() {
    return Container(
      height: 75,
      padding: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: SoftUI.softCard,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: SoftUI.softShadowDark.withOpacity(0.15),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_rounded, 'Home', 0),
          _buildNavItem(Icons.credit_card_rounded, 'Loans', 1),
          const SizedBox(width: 60),
          _buildNavItem(Icons.account_balance_wallet_outlined, 'Budgets', 2),
          _buildNavItem(Icons.school_rounded, 'Fees', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isActive = _currentIndex == index;
    final activeColor = const Color(0xFF667EEA);
    final inactiveColor = const Color(0xFF8E9AAF);

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(16),
      splashColor: activeColor.withOpacity(0.1),
      highlightColor: activeColor.withOpacity(0.1),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        transform: Matrix4.translationValues(0, isActive ? -4 : 0, 0),
        decoration: BoxDecoration(
          gradient: isActive ? SoftUI.primaryGradient : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? Colors.white : inactiveColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : inactiveColor,
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
              const SizedBox(height: 80),
            ],
          ),
        );
      },
    );
  }
}
