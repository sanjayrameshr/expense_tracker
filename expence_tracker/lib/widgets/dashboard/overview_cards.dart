import 'package:flutter/material.dart';
import '../../models/loan.dart';
import '../../models/fees_goal.dart';
import '../../utils/currency_formatter.dart';
import '../../widgets/cards/compact_card.dart';

/// Overview cards showing loans and fees
class OverviewCards extends StatelessWidget {
  final List<Loan> loans;
  final List<FeesGoal> feesGoals;
  final Function(int) onNavigate;

  const OverviewCards({
    super.key,
    required this.loans,
    required this.feesGoals,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final totalLoanRemaining =
        loans.fold(0.0, (sum, l) => sum + l.currentPrincipal);
    final totalMonthlyInterest =
        loans.fold(0.0, (sum, l) => sum + l.calculateMonthlyInterest());
    final totalFeesRemaining =
        feesGoals.fold(0.0, (sum, g) => sum + g.remainingAmount);

    return Row(
      children: [
        Expanded(
          child: CompactCard(
            title: 'Loans',
            value: formatCurrency(totalLoanRemaining),
            subtitle: 'Int: ${formatCurrency(totalMonthlyInterest)}/mo',
            icon: Icons.credit_card_rounded,
            color: const Color(0xFFBFAE8D),
            onTap: () => onNavigate(1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CompactCard(
            title: 'Fees Due',
            value: formatCurrency(totalFeesRemaining),
            subtitle: feesGoals.isNotEmpty
                ? '${formatCurrency(feesGoals.first.requiredMonthlySaving)}/mo'
                : 'No goals',
            icon: Icons.school_rounded,
            color: const Color(0xFFA7B6C2),
            onTap: () => onNavigate(3),
          ),
        ),
      ],
    );
  }
}
