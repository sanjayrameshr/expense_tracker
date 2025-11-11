import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

/// Main balance card with gradient background
class MainBalanceCard extends StatelessWidget {
  final double balance;
  final VoidCallback onTap;
  final String Function(double) formatCurrency;

  const MainBalanceCard({
    super.key,
    required this.balance,
    required this.onTap,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias, // Ensures gradient respects border radius
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: AppColors.balanceGradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Balance',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white.withOpacity(0.9),
                        size: 26,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    formatCurrency(balance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tap to view transactions',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
