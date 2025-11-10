import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/loan.dart';
import '../providers/finance_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import 'loan_detail_screen.dart';

/// Loan Overview Screen — refined UI for PocketPlan
class LoansScreen extends StatelessWidget {
  const LoansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Loans',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, finance, _) {
          final loans = finance.loans;

          if (loans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.account_balance_rounded,
                      size: 70, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    'No loans yet',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: loans.length,
            itemBuilder: (context, index) {
              final loan = loans[index];
              return _LoanCard(
                loan: loan,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LoanDetailScreen(loan: loan),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'loans_fab',
        backgroundColor: AppButtonStyles.fabBackground,
        icon: Icon(Icons.add_rounded, color: AppButtonStyles.fabIconColor),
        label: Text('Add Loan',
            style: TextStyle(color: AppButtonStyles.fabIconColor)),
        onPressed: () => _showAddLoanDialog(context),
      ),
    );
  }

  /// Dialog for adding a new loan
  void _showAddLoanDialog(BuildContext context) {
    final nameController = TextEditingController();
    final principalController = TextEditingController();
    final rateController = TextEditingController(text: '9.0');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Loan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Loan Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: principalController,
              decoration: const InputDecoration(
                labelText: 'Principal Amount',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: rateController,
              decoration: const InputDecoration(
                labelText: 'Interest Rate (%)',
                border: OutlineInputBorder(),
                suffixText: '%',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final principal = double.tryParse(principalController.text);
              final rate = double.tryParse(rateController.text);

              if (nameController.text.isEmpty ||
                  principal == null ||
                  rate == null) return;

              final loan = Loan(
                id: 'loan_${DateTime.now().millisecondsSinceEpoch}',
                name: nameController.text,
                initialPrincipal: principal,
                currentPrincipal: principal,
                interestRateAnnual: rate,
              );

              final finance = context.read<FinanceProvider>();
              await finance.saveLoan(loan);

              if (context.mounted) Navigator.pop(context);
            },
            style: AppButtonStyles.primaryElevated,
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

/// --- Loan Summary Card ---
class _LoanCard extends StatelessWidget {
  final Loan loan;
  final VoidCallback onTap;

  const _LoanCard({required this.loan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final monthlyInterest = loan.calculateMonthlyInterest();
    final progress = 1 - (loan.currentPrincipal / loan.initialPrincipal);
    final isPaidOff = loan.currentPrincipal <= 0;

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Loan Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loan.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${loan.interestRateAnnual.toStringAsFixed(1)}% p.a.',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Progress Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation(
                    isPaidOff ? Colors.green.shade400 : Colors.blue.shade600,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Principal and Interest Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoColumn(
                    title: 'Remaining',
                    value: formatCurrency(loan.currentPrincipal),
                    color: Colors.blueGrey.shade900,
                  ),
                  _infoColumn(
                    title: 'Monthly Interest',
                    value: formatCurrency(monthlyInterest),
                    color: Colors.orange.shade700,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Paid summary
              Text(
                'Paid: ${formatCurrency(loan.initialPrincipal - loan.currentPrincipal)}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoColumn(
      {required String title, required String value, required Color color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 15.5,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
