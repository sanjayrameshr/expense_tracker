import 'package:flutter/material.dart';
import '../models/loan.dart';
import '../utils/currency_formatter.dart';

/// Detailed view of a single loan
class LoanDetailScreen extends StatelessWidget {
  final Loan loan;

  const LoanDetailScreen({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(loan.name)),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Loan Summary Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Loan Summary',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(),
                  _InfoRow(
                    label: 'Initial Principal',
                    value: formatCurrency(loan.initialPrincipal),
                  ),
                  _InfoRow(
                    label: 'Current Principal',
                    value: formatCurrency(loan.currentPrincipal),
                    valueColor: Colors.orange,
                  ),
                  _InfoRow(
                    label: 'Amount Paid',
                    value: formatCurrency(
                      loan.initialPrincipal - loan.currentPrincipal,
                    ),
                    valueColor: Colors.green,
                  ),
                  _InfoRow(
                    label: 'Interest Rate',
                    value: '${loan.interestRateAnnual}% p.a.',
                  ),
                  _InfoRow(
                    label: 'Monthly Interest',
                    value: formatCurrency(loan.calculateMonthlyInterest()),
                  ),
                  _InfoRow(
                    label: 'Start Date',
                    value: formatDate(loan.startDate),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Payment History
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment History',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(),
                  if (loan.payments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: Text('No payments yet')),
                    )
                  else
                    ...loan.payments.reversed.map(
                      (payment) => ListTile(
                        title: Text(formatCurrency(payment.amount)),
                        subtitle: Text(
                          'Interest: ${formatCurrency(payment.interestPortion)} | '
                          'Principal: ${formatCurrency(payment.principalPortion)}',
                        ),
                        trailing: Text(formatDate(payment.date)),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Amortization Helper
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Amortization Helper',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(),
                  Text(
                    'At current rate of ${loan.interestRateAnnual}% per annum:',
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: '1 Month Interest',
                    value: formatCurrency(loan.calculateInterestForMonth()),
                  ),
                  _InfoRow(
                    label: '3 Months Interest',
                    value: formatCurrency(loan.calculateInterestForMonth() * 3),
                  ),
                  _InfoRow(
                    label: '6 Months Interest',
                    value: formatCurrency(loan.calculateInterestForMonth() * 6),
                  ),
                  _InfoRow(
                    label: '1 Year Interest',
                    value: formatCurrency(
                      loan.calculateInterestForMonth() * 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
          ),
        ],
      ),
    );
  }
}
