import 'package:flutter/material.dart';
import '../models/loan.dart';
import '../utils/currency_formatter.dart';

/// Detailed modern view of a single loan in PocketPlan
class LoanDetailScreen extends StatelessWidget {
  final Loan loan;

  const LoanDetailScreen({super.key, required this.loan});

  @override
  Widget build(BuildContext context) {
    final background = const Color(0xFFF8F9FB);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: background,
        foregroundColor: Colors.grey.shade800,
        title: Text(
          loan.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _SectionCard(
            title: 'Loan Summary',
            icon: Icons.account_balance_wallet_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow(
                    'Initial Principal', formatCurrency(loan.initialPrincipal)),
                _infoRow(
                    'Current Principal', formatCurrency(loan.currentPrincipal),
                    color: Colors.orange.shade700),
                _infoRow(
                    'Amount Paid',
                    formatCurrency(
                        loan.initialPrincipal - loan.currentPrincipal),
                    color: Colors.green.shade700),
                _infoRow('Interest Rate', '${loan.interestRateAnnual}% p.a.'),
                _infoRow('Monthly Interest',
                    formatCurrency(loan.calculateMonthlyInterest())),
                _infoRow('Start Date', formatDate(loan.startDate)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Payment History',
            icon: Icons.history_rounded,
            child: loan.payments.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Center(
                      child: Text(
                        'No payments yet',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  )
                : Column(
                    children: loan.payments.reversed.map((payment) {
                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F5F8),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          title: Text(
                            formatCurrency(payment.amount),
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            'Interest: ${formatCurrency(payment.interestPortion)}  |  '
                            'Principal: ${formatCurrency(payment.principalPortion)}',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade600),
                          ),
                          trailing: Text(
                            formatDate(payment.date),
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey.shade700),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Amortization Helper',
            icon: Icons.calculate_rounded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'At current rate of ${loan.interestRateAnnual}% per annum:',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 12),
                _infoRow('1 Month Interest',
                    formatCurrency(loan.calculateInterestForMonth())),
                _infoRow('3 Months Interest',
                    formatCurrency(loan.calculateInterestForMonth() * 3)),
                _infoRow('6 Months Interest',
                    formatCurrency(loan.calculateInterestForMonth() * 6)),
                _infoRow('1 Year Interest',
                    formatCurrency(loan.calculateInterestForMonth() * 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: color ?? Colors.grey.shade900,
            ),
          ),
        ],
      ),
    );
  }
}

/// Generic section card used for loan summary, payments, and amortization
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.grey.shade700, size: 22),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
