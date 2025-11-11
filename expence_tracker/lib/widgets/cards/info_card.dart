import 'package:flutter/material.dart';
import '../../utils/app_styles.dart';

/// Soft UI Information card with icon and title
class InfoCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;
  final EdgeInsets? padding;

  const InfoCard({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: SoftUI.cardDecoration(),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color.withOpacity(0.8), color],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: SoftUI.heading2.copyWith(fontSize: 18),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}
