import 'package:flutter/material.dart';
import '../../utils/app_styles.dart';

/// Soft UI Main Balance Card with beautiful gradient
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
    return Container(
      decoration: SoftUI.gradientCardDecoration(SoftUI.primaryGradient),
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
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.trending_up,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Active',
                            style: SoftUI.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'Current Balance',
                  style: SoftUI.subtitle.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  formatCurrency(balance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      color: Colors.white.withOpacity(0.8),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tap to view transactions',
                      style: SoftUI.caption.copyWith(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
