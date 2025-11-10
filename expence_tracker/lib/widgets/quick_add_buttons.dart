import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../providers/finance_provider.dart';
import 'package:provider/provider.dart';

/// Quick-add transaction button widget
class QuickAddButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final double defaultAmount;
  final TransactionCategory category;

  const QuickAddButton({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.defaultAmount,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showQuickAddDialog(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showQuickAddDialog(BuildContext context) async {
    final amountController = TextEditingController(
      text: defaultAmount.toStringAsFixed(0),
    );
    final descriptionController = TextEditingController(text: label);

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Quick Add $label'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '₹',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Add'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) return;

    final transaction = Transaction(
      id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
      amount: amount,
      category: category,
      description: descriptionController.text,
    );

    if (context.mounted) {
      final finance = context.read<FinanceProvider>();
      await finance.addTransaction(transaction);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${descriptionController.text}'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

/// Quick-add buttons row for common transactions
class QuickAddButtonsRow extends StatelessWidget {
  const QuickAddButtonsRow({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          QuickAddButton(
            icon: Icons.restaurant,
            label: 'Food',
            color: Colors.orange,
            defaultAmount: 200,
            category: TransactionCategory.spend,
          ),
          const SizedBox(width: 12),
          QuickAddButton(
            icon: Icons.local_gas_station,
            label: 'Fuel',
            color: Colors.red,
            defaultAmount: 500,
            category: TransactionCategory.spend,
          ),
          const SizedBox(width: 12),
          QuickAddButton(
            icon: Icons.shopping_bag,
            label: 'Shopping',
            color: Colors.purple,
            defaultAmount: 1000,
            category: TransactionCategory.spend,
          ),
          const SizedBox(width: 12),
          QuickAddButton(
            icon: Icons.medication,
            label: 'Medical',
            color: Colors.pink,
            defaultAmount: 300,
            category: TransactionCategory.family,
          ),
          const SizedBox(width: 12),
          QuickAddButton(
            icon: Icons.commute,
            label: 'Transport',
            color: Colors.blue,
            defaultAmount: 100,
            category: TransactionCategory.spend,
          ),
        ],
      ),
    );
  }
}
