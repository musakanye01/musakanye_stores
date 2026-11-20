import 'package:flutter/material.dart';

class StockChip extends StatelessWidget {
  const StockChip({super.key, required this.stockOnHand});

  final int stockOnHand;

  @override
  Widget build(BuildContext context) {
    final color = stockOnHand == 0
        ? Theme.of(context).colorScheme.error
        : stockOnHand <= 5
        ? Colors.orange.shade800
        : Colors.green.shade700;

    final label = stockOnHand == 0
        ? 'Out of stock'
        : stockOnHand <= 5
        ? 'Low: $stockOnHand'
        : '$stockOnHand available';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}
