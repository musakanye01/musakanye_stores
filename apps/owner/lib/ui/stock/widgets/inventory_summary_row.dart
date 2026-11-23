import 'package:flutter/material.dart';
import 'package:shared_core/theme/app_colors.dart';

class InventorySummaryRow extends StatelessWidget {
  const InventorySummaryRow({
    super.key,
    required this.productCount,
    required this.totalUnits,
    required this.lowStockCount,
  });

  final int productCount;
  final int totalUnits;
  final int lowStockCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;

        return Row(
          children: [
            Expanded(
              child: _MetricCard(
                title: 'Products',
                value: productCount,
                icon: Icons.inventory_2_outlined,
                color: AppColors.primary,
                compact: compact,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Units in stock',
                value: totalUnits,
                icon: Icons.widgets_outlined,
                color: AppColors.info,
                compact: compact,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                title: 'Low stock',
                value: lowStockCount,
                icon: Icons.warning_amber_rounded,
                color: AppColors.warning,
                compact: compact,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.compact,
  });

  final String title;
  final int value;
  final IconData icon;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 21),
          SizedBox(height: compact ? 10 : 14),
          Text('$value', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 3),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
