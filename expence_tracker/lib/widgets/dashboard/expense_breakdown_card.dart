import 'package:flutter/material.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/cards/info_card.dart';
import '../../widgets/charts.dart';
import '../../widgets/common/empty_placeholder.dart';

/// Expense breakdown chart card
class ExpenseBreakdownCard extends StatelessWidget {
  final FinanceProvider finance;

  const ExpenseBreakdownCard({
    super.key,
    required this.finance,
  });

  @override
  Widget build(BuildContext context) {
    final breakdown = finance.getCurrentMonthExpenseBreakdown();

    return InfoCard(
      title: 'Expense Breakdown',
      icon: Icons.pie_chart_outline,
      color: const Color(0xFF7D8C9E),
      child: SizedBox(
        height: 280,
        child: breakdown.isEmpty
            ? const EmptyPlaceholder(text: 'No expenses this month')
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
}
