import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../models/loan.dart';
import '../providers/finance_provider.dart';
import '../utils/currency_formatter.dart';

/// Elegant modern UI for adding new transactions
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
        const SnackBar(
          content: Text('Transaction added successfully'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final background = const Color(0xFFF8F9FB);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: background,
        title: const Text(
          'Add Transaction',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        foregroundColor: Colors.grey.shade800,
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, finance, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildFormCard(finance),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormCard(FinanceProvider finance) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaction Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),

            // Category dropdown
            _buildDropdownField<TransactionCategory>(
              label: 'Category',
              value: _selectedCategory,
              items: TransactionCategory.values,
              displayText: _categoryName,
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

            // Amount
            _buildTextField(
              controller: _amountController,
              label: 'Amount',
              prefix: '₹',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty)
                  return 'Please enter amount';
                if (double.tryParse(value) == null) return 'Enter valid number';
                return null;
              },
              onChanged: (_) {
                if (_selectedCategory == TransactionCategory.loanPayment) {
                  _calculateLoanSplit();
                }
              },
            ),
            const SizedBox(height: 16),

            // Description
            _buildTextField(
              controller: _descriptionController,
              label: 'Description',
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Please enter description'
                          : null,
            ),
            const SizedBox(height: 16),

            // Loan selection
            if (_selectedCategory == TransactionCategory.loanPayment)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDropdownField<Loan>(
                    label: 'Select Loan',
                    value: _selectedLoan,
                    items: finance.loans,
                    displayText:
                        (loan) =>
                            '${loan.name} (${formatCurrency(loan.currentPrincipal)})',
                    onChanged: (value) {
                      setState(() => _selectedLoan = value);
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
                  if (_interestPortion != null && _principalPortion != null)
                    _buildLoanSplitCard(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? prefix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF3F5F8),
        prefixText: prefix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) displayText,
    required ValueChanged<T?> onChanged,
    String? Function(T?)? validator,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFF3F5F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items:
          items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(displayText(item)),
                ),
              )
              .toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildLoanSplitCard() {
    return Card(
      elevation: 1,
      color: const Color(0xFFEEF3F7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Split (Interest-first)',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _splitRow('Interest', formatCurrency(_interestPortion!)),
            _splitRow('Principal', formatCurrency(_principalPortion!)),
          ],
        ),
      ),
    );
  }

  Widget _splitRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade700)),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _submitTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey.shade800,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Add Transaction',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
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
