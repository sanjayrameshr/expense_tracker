import 'package:flutter/material.dart';

/// Empty state placeholder widget
class EmptyPlaceholder extends StatelessWidget {
  final String text;
  final IconData? icon;
  final double? iconSize;

  const EmptyPlaceholder({
    super.key,
    required this.text,
    this.icon,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.inbox_outlined,
            size: iconSize ?? 48,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
