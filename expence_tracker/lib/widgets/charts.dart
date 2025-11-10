import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/transaction.dart';
import '../utils/currency_formatter.dart';

/// Reusable pie chart widget for expense breakdown
class ExpensePieChart extends StatelessWidget {
  final Map<TransactionCategory, double> categoryData;
  final double totalAmount;

  const ExpensePieChart({
    super.key,
    required this.categoryData,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    if (categoryData.isEmpty || totalAmount == 0) {
      return const Center(child: Text('No expense data to display'));
    }

    return AspectRatio(
      aspectRatio: 1.3,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: _createSections(),
          pieTouchData: PieTouchData(
            touchCallback: (FlTouchEvent event, pieTouchResponse) {
              // Could add touch interactions here
            },
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _createSections() {
    final colors = _getCategoryColors();
    final entries = categoryData.entries.toList();

    return entries.map((entry) {
      final percentage = (entry.value / totalAmount) * 100;
      final isSmall = percentage < 5;

      return PieChartSectionData(
        color: colors[entry.key] ?? Colors.grey,
        value: entry.value,
        title: isSmall ? '' : '${percentage.toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Map<TransactionCategory, Color> _getCategoryColors() {
    return {
      TransactionCategory.spend: Colors.red.shade400,
      TransactionCategory.family: Colors.purple.shade400,
      TransactionCategory.savingsDeposit: Colors.cyan.shade400,
      TransactionCategory.loanPayment: Colors.orange.shade400,
      TransactionCategory.feePayment: Colors.blue.shade400,
      TransactionCategory.income: Colors.green.shade400,
    };
  }
}

/// Legend for the pie chart
class ChartLegend extends StatelessWidget {
  final Map<TransactionCategory, double> categoryData;

  const ChartLegend({super.key, required this.categoryData});

  @override
  Widget build(BuildContext context) {
    final colors = _getCategoryColors();

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      children:
          categoryData.entries.map((entry) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: colors[entry.key] ?? Colors.grey,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${_getCategoryName(entry.key)}: ${formatCurrency(entry.value)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          }).toList(),
    );
  }

  Map<TransactionCategory, Color> _getCategoryColors() {
    return {
      TransactionCategory.spend: Colors.red.shade400,
      TransactionCategory.family: Colors.purple.shade400,
      TransactionCategory.savingsDeposit: Colors.cyan.shade400,
      TransactionCategory.loanPayment: Colors.orange.shade400,
      TransactionCategory.feePayment: Colors.blue.shade400,
      TransactionCategory.income: Colors.green.shade400,
    };
  }

  String _getCategoryName(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.income:
        return 'Income';
      case TransactionCategory.spend:
        return 'Spend';
      case TransactionCategory.family:
        return 'Family';
      case TransactionCategory.savingsDeposit:
        return 'Savings';
      case TransactionCategory.loanPayment:
        return 'Loan';
      case TransactionCategory.feePayment:
        return 'Fees';
    }
  }
}

/// Simple line chart for spending trend
class SpendingTrendChart extends StatelessWidget {
  final List<double> dailySpending;
  final List<String> labels;

  const SpendingTrendChart({
    super.key,
    required this.dailySpending,
    required this.labels,
  });

  @override
  Widget build(BuildContext context) {
    if (dailySpending.isEmpty) {
      return const Center(child: Text('No trend data available'));
    }

    return AspectRatio(
      aspectRatio: 2,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '₹${(value / 1000).toStringAsFixed(0)}k',
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= labels.length)
                    return const Text('');
                  return Text(
                    labels[index],
                    style: const TextStyle(fontSize: 10),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots:
                  dailySpending
                      .asMap()
                      .entries
                      .map((e) => FlSpot(e.key.toDouble(), e.value))
                      .toList(),
              isCurved: true,
              color: Colors.blue,
              barWidth: 3,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Colors.blue.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
