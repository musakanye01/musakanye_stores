import 'package:flutter/material.dart';
import 'package:owner/ui/dashboard/widgets/dashboard_colors.dart';

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Convenience for the low-stock "N left" chip.
class LowStockChip extends StatelessWidget {
  const LowStockChip({super.key, required this.quantity});

  final int quantity;

  @override
  Widget build(BuildContext context) =>
      StatusChip(label: '$quantity left', color: DashboardColors.warning);
}
