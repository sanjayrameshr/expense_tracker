import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/loan.dart';
import '../providers/finance_provider.dart';
import '../utils/currency_formatter.dart';
import 'loan_detail_screen.dart';

/// Screen showing all loans
class LoansScreen extends StatelessWidget {
  const LoansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loans')),
      body: Consumer<FinanceProvider>(
        builder: (context, finance, _) {
          final loans = finance.loans;

          if (loans.isEmpty) {
            return const Center(child: Text('No loans yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddLoanDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddLoanDialog(BuildContext context) {
    final nameController = TextEditingController();
    final principalController = TextEditingController();
    final rateController = TextEditingController(text: '9.0');

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Loan'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Loan Name'),
                ),
                TextField(
                  controller: principalController,
                  decoration: const InputDecoration(
                    labelText: 'Principal Amount',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: rateController,
                  decoration: const InputDecoration(
                    labelText: 'Interest Rate (%)',
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
              TextButton(
                onPressed: () async {
                  final principal = double.tryParse(principalController.text);
                  final rate = double.tryParse(rateController.text);

                  if (nameController.text.isEmpty ||
                      principal == null ||
                      rate == null) {
                    return;
                  }

                  final loan = Loan(
                    id: 'loan_${DateTime.now().millisecondsSinceEpoch}',
                    name: nameController.text,
                    initialPrincipal: principal,
                    currentPrincipal: principal,
                    interestRateAnnual: rate,
                  );

                  final finance = context.read<FinanceProvider>();
                  await finance.saveLoan(loan);

                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }
}

class _LoanCard extends StatelessWidget {
  final Loan loan;
  final VoidCallback onTap;

  const _LoanCard({required this.loan, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final monthlyInterest = loan.calculateMonthlyInterest();
    final progress = 1 - (loan.currentPrincipal / loan.initialPrincipal);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loan.name,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    '${loan.interestRateAnnual}% p.a.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.orange),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Remaining'),
                      Text(
                        formatCurrency(loan.currentPrincipal),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Monthly Interest'),
                      Text(
                        formatCurrency(monthlyInterest),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Paid: ${formatCurrency(loan.initialPrincipal - loan.currentPrincipal)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
