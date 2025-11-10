import 'package:flutter/material.dart';
import '../../providers/finance_provider.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/cards/info_card.dart';
import '../../widgets/common/stat_row.dart';

/// Quick stats card showing summary information
class QuickStatsCard extends StatelessWidget {
  final FinanceProvider finance;

  const QuickStatsCard({
    super.key,
    required this.finance,
  });

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      title: 'Quick Stats',
      icon: Icons.insights_rounded,
      color: const Color(0xFF9B9DB4),
      child: Column(
        children: [
          StatRow(
            label: 'Total Spent',
            value: formatCurrency(finance.totalSpent),
          ),
          StatRow(
            label: 'Family Expenses',
            value: formatCurrency(finance.totalFamily),
          ),
          StatRow(
            label: 'Active Loans',
            value: finance.loans.length.toString(),
          ),
        ],
      ),
    );
  }
}
