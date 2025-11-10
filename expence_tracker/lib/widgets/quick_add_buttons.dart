import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/finance_provider.dart';

/// Elegant quick-add transaction button for PocketPlan
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
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.15), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showQuickAddDialog(BuildContext context) async {
    final amountController =
        TextEditingController(text: defaultAmount.toStringAsFixed(0));
    final descriptionController = TextEditingController(text: label);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 10),
            Text('Quick Add $label',
                style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField(
              controller: amountController,
              label: 'Amount',
              prefixText: '₹',
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 14),
            _buildTextField(
              controller: descriptionController,
              label: 'Description',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
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
      description: descriptionController.text.trim(),
    );

    if (context.mounted) {
      final finance = context.read<FinanceProvider>();
      await finance.addTransaction(transaction);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Added ${descriptionController.text}'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.grey.shade800,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? prefixText,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefixText,
        filled: true,
        fillColor: const Color(0xFFF3F5F8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/// Clean, scrollable quick-add row for common expense shortcuts
class QuickAddButtonsRow extends StatelessWidget {
  const QuickAddButtonsRow({super.key});

  @override
  Widget build(BuildContext context) {
    final buttons = [
      QuickAddButton(
        icon: Icons.restaurant_rounded,
        label: 'Food',
        color: Colors.orange.shade400,
        defaultAmount: 200,
        category: TransactionCategory.spend,
      ),
      QuickAddButton(
        icon: Icons.local_gas_station_rounded,
        label: 'Fuel',
        color: Colors.red.shade400,
        defaultAmount: 500,
        category: TransactionCategory.spend,
      ),
      QuickAddButton(
        icon: Icons.shopping_bag_rounded,
        label: 'Shopping',
        color: Colors.purple.shade400,
        defaultAmount: 1000,
        category: TransactionCategory.spend,
      ),
      QuickAddButton(
        icon: Icons.medical_services_rounded,
        label: 'Medical',
        color: Colors.teal.shade400,
        defaultAmount: 300,
        category: TransactionCategory.family,
      ),
      QuickAddButton(
        icon: Icons.commute_rounded,
        label: 'Transport',
        color: Colors.blue.shade400,
        defaultAmount: 100,
        category: TransactionCategory.spend,
      ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: List.generate(buttons.length * 2 - 1, (index) {
          if (index.isOdd) return const SizedBox(width: 12);
          return buttons[index ~/ 2];
        }),
      ),
    );
  }
}
