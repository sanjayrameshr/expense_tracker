import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/fees_goal.dart';
import '../providers/finance_provider.dart';
import '../utils/currency_formatter.dart';

/// Screen for managing fees and goals
class FeesScreen extends StatelessWidget {
  const FeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fees & Goals')),
      body: Consumer<FinanceProvider>(
        builder: (context, finance, _) {
          final goals = finance.feesGoals;

          if (goals.isEmpty) {
            return const Center(child: Text('No goals yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              return _GoalCard(goal: goal);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddGoalDialog(context),
        child: const Icon(Icons.add),
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
                  title: const Text('Add Fees Goal'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Goal Name',
                        ),
                      ),
                      TextField(
                        controller: amountController,
                        decoration: const InputDecoration(
                          labelText: 'Target Amount',
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      ListTile(
                        title: const Text('Due Date'),
                        subtitle: Text(formatDate(selectedDate)),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 3650),
                            ),
                          );
                          if (date != null) {
                            setState(() => selectedDate = date);
                          }
                        },
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
                        final amount = double.tryParse(amountController.text);

                        if (nameController.text.isEmpty || amount == null) {
                          return;
                        }

                        final goal = FeesGoal(
                          id: 'goal_${DateTime.now().millisecondsSinceEpoch}',
                          name: nameController.text,
                          targetAmount: amount,
                          dueDate: selectedDate,
                        );

                        final finance = context.read<FinanceProvider>();
                        await finance.saveFeesGoal(goal);

                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
          ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  final FeesGoal goal;

  const _GoalCard({required this.goal});

  @override
  Widget build(BuildContext context) {
    final progress = goal.currentAmount / goal.targetAmount;
    final isOverdue = goal.dueDate.isBefore(DateTime.now());

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(goal.name, style: Theme.of(context).textTheme.titleLarge),
                if (isOverdue)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'OVERDUE',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              color: isOverdue ? Colors.red : Colors.blue,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Target'),
                    Text(
                      formatCurrency(goal.targetAmount),
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
                    const Text('Remaining'),
                    Text(
                      formatCurrency(goal.remainingAmount),
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
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Due: ${formatDate(goal.dueDate)}'),
                Text(
                  '${goal.monthsLeft} months left',
                  style: TextStyle(color: isOverdue ? Colors.red : Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Required monthly saving:'),
                  Text(
                    formatCurrency(goal.requiredMonthlySaving),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
