import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fees_goal.dart';
import '../providers/finance_provider.dart';
import '../utils/currency_formatter.dart';

/// Modern, elegant Fees & Goals management screen
class FeesScreen extends StatelessWidget {
  const FeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final background = const Color(0xFFF8F9FB);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: background,
        foregroundColor: Colors.grey.shade800,
        title: const Text(
          'Fees & Goals',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Consumer<FinanceProvider>(
        builder: (context, finance, _) {
          final goals = finance.feesGoals;

          if (goals.isEmpty) {
            return _EmptyState(onAdd: () => _showAddGoalDialog(context));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            itemBuilder: (context, index) => _GoalCard(goal: goals[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddGoalDialog(context),
        backgroundColor: Colors.grey.shade800,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Goal'),
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 180));

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: const Text(
                    'Add Fees Goal',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildTextField(
                        controller: nameController,
                        label: 'Goal Name',
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: amountController,
                        label: 'Target Amount (₹)',
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        tileColor: const Color(0xFFF3F5F8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        title: const Text('Due Date'),
                        subtitle: Text(formatDate(selectedDate)),
                        trailing: const Icon(
                          Icons.calendar_today_rounded,
                          color: Colors.grey,
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 3650),
                            ),
                          );
                          if (date != null) setState(() => selectedDate = date);
                        },
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
                        final amount = double.tryParse(amountController.text);
                        if (nameController.text.isEmpty || amount == null)
                          return;

                        final goal = FeesGoal(
                          id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
                          name: nameController.text,
                          targetAmount: amount,
                          dueDate: selectedDate,
                        );

                        final finance = context.read<FinanceProvider>();
                        await finance.saveFeesGoal(goal);

                        if (context.mounted) Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade800,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Add'),
                    ),
                  ],
                ),
          ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
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

/// ----------------------------
/// Elegant Empty State
/// ----------------------------
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_outlined, size: 70, color: Colors.grey.shade400),
            const SizedBox(height: 20),
            Text(
              'No Goals Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start by setting your first fee payment goal.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Create Goal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ----------------------------
/// Goal Card (Modern Styled)
/// ----------------------------
class _GoalCard extends StatelessWidget {
  final FeesGoal goal;

  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final progress = goal.currentAmount / goal.targetAmount;
    final isOverdue = goal.dueDate.isBefore(DateTime.now());
    final color =
        isOverdue
            ? Colors.red.shade400
            : (progress >= 0.9
                ? Colors.orange.shade400
                : Colors.green.shade400);

    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title + Overdue Label
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    goal.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (isOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'OVERDUE',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 10,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 12),

            // Amount section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _labelValue(
                  'Target',
                  formatCurrency(goal.targetAmount),
                  color: Colors.grey.shade800,
                ),
                _labelValue(
                  'Remaining',
                  formatCurrency(goal.remainingAmount),
                  color: color,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Timeline info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Due: ${formatDate(goal.dueDate)}',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                Text(
                  isOverdue
                      ? 'Past due'
                      : '${goal.monthsLeft} month${goal.monthsLeft == 1 ? '' : 's'} left',
                  style: TextStyle(
                    color: isOverdue ? Colors.red : Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Monthly saving info
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F5F8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Required Monthly Saving',
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                  ),
                  Text(
                    formatCurrency(goal.requiredMonthlySaving),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _labelValue(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: color ?? Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}
