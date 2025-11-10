import 'package:flutter/material.dart';
import '../../providers/finance_provider.dart';
import '../../widgets/cards/info_card.dart';
import '../../widgets/charts.dart';

/// Spending trend chart card
class SpendingTrendCard extends StatelessWidget {
  final FinanceProvider finance;

  const SpendingTrendCard({
    super.key,
    required this.finance,
  });

  List<String> _getLast7DaysLabels() {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      return [
        'Mon',
        'Tue',
        'Wed',
        'Thu',
        'Fri',
        'Sat',
        'Sun'
      ][date.weekday - 1];
    });
  }

  @override
  Widget build(BuildContext context) {
    return InfoCard(
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
}
