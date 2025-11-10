import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../models/loan.dart';
import '../providers/finance_provider.dart';
import '../utils/currency_formatter.dart';

/// Screen for adding new transactions
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  TransactionCategory _selectedCategory = TransactionCategory.spend;
  Loan? _selectedLoan;
  double? _interestPortion;
  double? _principalPortion;

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _calculateLoanSplit() {
    if (_selectedLoan == null || _amountController.text.isEmpty) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null) return;

    final finance = context.read<FinanceProvider>();
    final split = finance.calculateLoanPaymentSplit(_selectedLoan!, amount);

    setState(() {
      _interestPortion = split[0];
      _principalPortion = split[1];
    });
  }

  Future<void> _submitTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final description = _descriptionController.text;

    final transaction = Transaction(
      id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      category: _selectedCategory,
      description: description,
      loanId: _selectedLoan?.id,
      interestPortion: _interestPortion,
      principalPortion: _principalPortion,
    );

    final finance = context.read<FinanceProvider>();
    await finance.addTransaction(transaction);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaction added successfully')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Transaction')),
      body: Consumer<FinanceProvider>(
        builder: (context, finance, _) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Category dropdown
                DropdownButtonFormField<TransactionCategory>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items:
                      TransactionCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(_categoryName(category)),
                        );
                      }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                      _selectedLoan = null;
                      _interestPortion = null;
                      _principalPortion = null;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Amount field
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                    prefixText: '₹',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter valid amount';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    if (_selectedCategory == TransactionCategory.loanPayment) {
                      _calculateLoanSplit();
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Loan selection for loan payments
                if (_selectedCategory == TransactionCategory.loanPayment) ...[
                  DropdownButtonFormField<Loan>(
                    value: _selectedLoan,
                    decoration: const InputDecoration(
                      labelText: 'Select Loan',
                      border: OutlineInputBorder(),
                    ),
                    items:
                        finance.loans.map((loan) {
                          return DropdownMenuItem(
                            value: loan,
                            child: Text(
                              '${loan.name} (${formatCurrency(loan.currentPrincipal)})',
                            ),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedLoan = value;
                      });
                      _calculateLoanSplit();
                    },
                    validator: (value) {
                      if (_selectedCategory ==
                              TransactionCategory.loanPayment &&
                          value == null) {
                        return 'Please select a loan';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Show interest/principal split
                  if (_interestPortion != null && _principalPortion != null)
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Payment Split (Interest-first)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Interest:'),
                                Text(
                                  formatCurrency(_interestPortion!),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Principal:'),
                                Text(
                                  formatCurrency(_principalPortion!),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                ],

                const SizedBox(height: 24),

                // Submit button
                ElevatedButton(
                  onPressed: _submitTransaction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Add Transaction'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _categoryName(TransactionCategory category) {
    switch (category) {
      case TransactionCategory.income:
        return 'Income';
      case TransactionCategory.spend:
        return 'Spend';
      case TransactionCategory.family:
        return 'Family';
      case TransactionCategory.savingsDeposit:
        return 'Savings Deposit';
      case TransactionCategory.loanPayment:
        return 'Loan Payment';
      case TransactionCategory.feePayment:
        return 'Fee Payment';
    }
  }
}
